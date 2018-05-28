require "glitchtools/version"
require 'aviglitch'
require 'streamio-ffmpeg'
require 'escort'

include FFMPEG


module Glitchtools
  
  AVI_ENCODING_OPTIONS = %w(-r 25 -c:v libxvid -bf 2 -level 5 -an)
  # GIF_ENCODING_OPTIONS = 

  class AviEncoder
    def encode_avi f
      fn = File.basename( f, '.*' )
      m = Movie.new( f )
      m.transcode( "#{ fn }.avi", AVI_ENCODING_OPTIONS)
      return "#{ fn }.avi"
    end
  end

  class KeyframeLister < ::Escort::ActionCommand::Base
    def list_keyframes
      file = AviGlitch.open( arguments[0] )
      # frame_types = []
      file.frames.each_with_index { |frame, i| puts "#{ i } is keyframe" if frame.is_iframe? }
    end
  end
  
  class JoinerAndMosher < ::Escort::ActionCommand::Base
    def join_and_mosh
      files = arguments
      files.each_with_index do |f, i|
        unless File.extname( f ) == ".avi"
          files[i] = AviEncoder.new.encode_avi(f)
        end
      end
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
        a1.frames.concat( a2.frames )
        o = AviGlitch.open a1.frames
        # Check to see if file exists, increment filename
        outpath = "#{ File.basename( files[0], '.*' ) }_#{ File.basename( files[1], '.*' ) }_mosh_"
        files = Dir.glob( "#{ outpath }*.avi" )
        if files.any?
          @outfile = files.sort.last
        else
          @outfile = "#{ outpath }01"
        end
        if File.exists?( @outfile )
          outpath = File.basename( @outfile, ".*" )
          outpath = outpath.next!
          @outfile = "#{ outpath }"
        end
        o.output "#{ @outfile }.avi"
      }
      #Progress thread
      t2 = Thread.new{
        progress = 'plz wait, joining & moshing...'
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
      return puts "\n#{ @outfile }.avi was saved."
    end
  end

  class Framerepeater < ::Escort::ActionCommand::Base
    def repeat_frames
      filename = arguments[0]
      unless File.extname( filename ) == ".avi"
        filename = AviEncoder.new.encode_avi(filename)
      end
      file = AviGlitch.open( filename )
      last_buffer_frame = command_options[:last_buffer_frame].to_i
      frame_to_repeat = command_options[:frame_to_repeat].to_i
      trailing_frames = command_options[:trailing_frames].to_i
      repetitions = command_options[:repetitions].to_i  
      # Glitching thread
      t1 = Thread.new {
        # Get rid of file ext for later
        filename = File.basename( filename, '.*' )
        # Get the last frame
        last_frame = file.frames.size
        # Put all non-keyframes in d
        d = []
        file.frames.each_with_index { |f, i| d.push( i ) if f.is_deltaframe? }
        # Keep frames up until last_buffer_frame
        f = file.frames[0, last_buffer_frame].to_avi.frames.concat( file.frames[d[frame_to_repeat], trailing_frames] * repetitions )
        # Add the rest of the frames to y and stick it to the end of q
        y = file.frames[d[last_buffer_frame + repetitions], last_frame - last_buffer_frame - 1]
        y = AviGlitch.open( y )
        y.remove_all_keyframes!
        f.concat( y.frames )
        # New AviGlitch instance with the glitched file
        o = AviGlitch.open( f )
        # Save glitched file
        @outfile = "#{ filename }_0-#{ last_buffer_frame }_#{ frame_to_repeat }-#{ trailing_frames }x#{ repetitions }"
        o.output "#{ @outfile }.avi"
        }
      #Progress thread
      t2 = Thread.new{
        progress = 'plz wait, repeating frames...'
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
      return puts "\n#{ @outfile }.avi was saved."
    end
  end

  class Randomrepeater < ::Escort::ActionCommand::Base
    # attr_accessor :file, :repetitions, :length

    # def initialize command_options, arguments
    #   # random_repeat file
    #   # p command_options
    #   self.file = arguments[0]
    #   self.repetitions = command_options[:repetitions]
    #   self.length = command_options[:length]
    # end

    def random_repeat
      # Glitching thread
      file = arguments[0]
      repetitions = command_options[:repetitions]
      length = command_options[:length]
      queue = Queue.new
      t1 = Thread.new {
        # Thread.current[:r] = 0
        filename = File.basename( file , '.*')
        a = AviGlitch.open( file )
        d = []
        a.frames.each_with_index do | f, i |
          d.push(i) if f.is_deltaframe?
        end
        q = a.frames[0, 5]
        begin
          repetitions.times do | r |
            x = a.frames[d[rand(d.size)], 1]
            q.concat(x * rand(length))
            Thread.current[:r] = r.to_f / repetitions
          end
        ensure
          queue.push(repetitions)
        end
        o = AviGlitch.open( q )
        o.output "#{ filename }_random.avi"
      }
      # Progress thread
      t2 = Thread.new {
        progress = 'plz wait, randomly repeating frames...'
        while t1.status
          # move the cursor to the beginning of the line with \r
          print "\r"
          # puts add \n to the end of string, use print instead
          print progress + " #{(t1[:r]*100).to_i if t1[:r]} %"
          # force the output to appear immediately when using print
          # by default when \n is printed to the standard output, the buffer is flushed.
          $stdout.flush
          sleep 1
        end
      }
      t1.join
      t2.join
      return puts "\nrandomly repeated frames"
    end
  end

  class GifExporter < ::Escort::ActionCommand::Base
    def export_gif
      file = arguments[0]
      unless Dir.exists?( "gif" )
        Dir.mkdir( "gif" )
      end
      fn = File.basename(file, '.*')
      m = Movie.new(file)
      m.duration.round.times do |i|
        options = %W(-ss #{i} -t #{i + 1} -pix_fmt rgb24 -s hvga)
        m.transcode("gif/#{ fn }_0#{ i + 1 }.gif", options)
      end
    end
  end
  
  class Reverser < ::Escort::ActionCommand::Base
    def reverse
      file = arguments[0]
      fn = File.basename(file, '.*')
      a = AviGlitch.open file
      ar = a.frames.reverse_each
      ar.each_with_index do |f, i|
        if a.frames[i].is_deltaframe?
          a.frames[i] = f
        end
      end
      a.output "#{fn}-rev.avi"
    end
  end
end