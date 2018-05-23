# Glitchtools

Glitchtools being a CLI with some tools to glitch your avi files, heavily based on the [AviGlitch gem](https://github.com/ucnv/aviglitch) and [Streamio FFMPEG](https://github.com/streamio/streamio-ffmpeg).

A Frame Repeater (`framerepeater`), a Random Frame Repeater (`randomrepeater`), a Joiner And Mosher (`join_and_mosh`), a Keyframe Lister (`list_keyframes`) and a Gif Exporter (`gif_export`) are what's available at the moment.

It should probably be said that the project is mostly for my own pleasure and coding practice. It's not really user friendly right now if you're not me.

## Installation

Cloning the repository, going to glitchtools directory and running `rake install` should do the trick.
Also, streamio-ffmpeg requires [FFMPEG](http://www.ffmpeg.org) so make sure you've got that.

## Usage

#### Keyframe Lister

`list_keyframes file`

The Keyframe Lister takes a file as an argument. It needs to be an avi file and I haven't been bothered to put in a converter.

#### Gif Exporter

`gif_export file`

The Gif Exporter takes a video file and exports animated gifs, split into 1 second clips to make them smaller and to-tumblr-uploadable. This solution is far from optimal and will probably be tweaked in a near future.

#### Joiner And Mosher

`join_and_mosh file1 file2`

The Joiner And Mosher takes two arguments, both files. (If they're not avi files, it will try to convert them.) The script will then
* keep the frames up to and including the first keyframe of the first file (so, in most cases just the first but you never know)
* remove all keyframes from the second file
* mosh the two files together

#### Frame Repeater

`framerepeater file frames_to_keep frame_to_repeat trailing_frames repetitions`

The Frame Repeater takes five arguments, the first being the file (which it will try to convert if it's not an avi file), and then:
* the number of frames to keep before repeating
* the frame to repeat
* the number of additional frames to repeat
* the number of repetitions to make

#### Random Frame Repeater

`randomrepeater file` 

The Random Frame Repeater takes one argument, the file on which to perform the Random Frame Repeating. Currently it is hard coded to perform 100 repetitions of taking a random non-keyframe and repeating it somewhere between 1 and 50 times. This one is taken directly from the [short AviGlitch guide](https://ucnv.github.io/aviglitch/).

## Development

This is something of a mess at the moment and I'm really not counting on anyone jumping in. Do get in touch if I'm wrong.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/schizoakustik/glitchtools.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

