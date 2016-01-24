require "glitchtools/version"
require 'aviglitch'
require 'streamio-ffmpeg'
include FFMPEG
module Glitchtools

  class KeyframeLister
    def list_keyframes file
      file = AviGlitch.open(file)
      frame_types = []
      file.frames.each { |frame| frame_types << frame.is_iframe? }
      frame_types.each_with_index { |i, n| puts "#{n} is_iframe" if i }
    end
  end

  class JoinerAndMosher
    def initialize *files
      # Check to see of given file is avi, otherwise convert it
      files.each_with_index do |f, i|
        unless File.extname(f) == ".avi"
          fn = File.basename(f, '.*')
          f = Movie.new(f)
          f.transcode("#{fn}.avi", "-r 25 -c:v libxvid -bf 2 -level 5 -an")
          files[i] = "#{fn}.avi"
        end
      end
      join_and_mosh(*files)
    end
    def join_and_mosh(*files)
      k = 0
      a1 = AviGlitch.open files[0]
      a2 = AviGlitch.open files[1]
      # Keep frames from first file, end on keyframe
      a1.frames.each_with_index do |f, i|
        k = i if f.is_keyframe?
      end
      a1.frames = a1.frames[k, 1]
      #Glitching thread
      t1 = Thread.new{
        a2.remove_all_keyframes!
        a1.frames.concat(a2.frames)
        o = AviGlitch.open a1.frames
        # Check to see if file exists, increment filename
        outpath = "#{File.basename(files[0], '.*')}_#{File.basename(files[1], '.*')}_mosh_"
        files = Dir.glob("#{outpath}*.avi")
        if files.any?
          @outfile = files.sort.last
        else
          @outfile = "#{outpath}01"
        end
        if File.exists?(@outfile)
          outpath = File.basename(@outfile, ".*")
          outpath = outpath.next!
          @outfile = "#{outpath}"
        end
        o.output "#{@outfile}.avi"
        gif = FFMPEG::Movie.new("#{@outfile}.avi")
        gif.transcode("#{@outfile}.gif", "-pix_fmt rgb24 -s hvga")
      }
      #Progress thread
      t2 = Thread.new{
        progress = '|* plz wait, joining & moshing'
        while t1.status
          progress << "."
          print "\r"
          print progress
          $stdout.flush
          sleep 1.2
        end
      } 
      t1.join
      t2.join
      return puts "\n#{@outfile}.avi & #{@outfile}.gif was saved."
    end
  end

  class Framerepeater
    def initialize *params
      options = Hash.new 
      options = { 
        :file => params[0],
        :last_buffer_frame => params[1],
        :frame_to_repeat => params[2],
        :trailing_frames => params[3],
        :repetitions => params[4]
      }
      unless File.extname( options[:file] ) == ".avi"
          fn = File.basename( options[:file], '.*' )
          f = FFMPEG::Movie.new(options[:file])
          f.transcode( "#{ fn }.avi", "-r 25 -c:v libxvid -bf 2 -level 5" )
          options[:file] = "#{ fn }.avi"
        end
      repeat_frames options
    end
    def repeat_frames options
      file = AviGlitch.open(options[:file])
      last_buffer_frame = options[:last_buffer_frame].to_i
      frame_to_repeat = options[:frame_to_repeat].to_i
      trailing_frames = options[:trailing_frames].to_i
      repetitions = options[:repetitions].to_i  
      # Glitching thread
      t1 = Thread.new {
        # Get rid of file ext for later
        filename = File.basename( options[:file], '.*' )
        # Get the last frame
        last_frame = file.frames.size
        # Put all non-keyframes in d
        d = []
        file.frames.each_with_index { |f, i| d.push(i) if f.is_deltaframe? }
        # Keep frames up until last_buffer_frame
        f = file.frames[0, last_buffer_frame].to_avi.frames.concat( file.frames[d[frame_to_repeat], trailing_frames] * repetitions )
        # Add the rest of the frames to y and stick it to the end of q
        y = file.frames[d[last_buffer_frame + 1], last_frame - last_buffer_frame - 1]
        y = AviGlitch.open(y)
        y.remove_all_keyframes!
        f.concat(y.frames)
        # New AviGlitch instance with the glitched file
        o = AviGlitch.open(f)
        # Save glitched file
        @outfile = "#{filename}_[0-#{last_buffer_frame}_((#{frame_to_repeat}-#{trailing_frames})x#{repetitions})]"
        o.output "#{@outfile}.avi"
        gif = FFMPEG::Movie.new("#{@outfile}.avi")
        gif.transcode("#{@outfile}.gif", "-pix_fmt rgb24 -s hvga")
      }
      #Progress thread
      t2 = Thread.new{
        progress = '|* plz wait, repeating frames'
        while t1.status
          progress << "."
          # move the cursor to the beginning of the line with \r
          print "\r"
          # puts add \n to the end of string, use print instead
          print progress #+ " #{r / 100} %"
          # force the output to appear immediately when using print
          # by default when \n is printed to the standard output, the buffer is flushed.
          $stdout.flush
          sleep 1.2
        end
      }
      t1.join
      t2.join
      return puts "#{@outfile}.avi & #{@outfile}.gif was saved."
    end
  end
end

Dir.chdir("/home/linus/Videos/glitch/lejon_andy/")
Glitchtools::Framerepeater.new(*%w"andy_02.avi 3 3 1 15")