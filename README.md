# Glitchtools

Glitchtools being a CLI with some tools to glitch your avi files, heavily based on the AviGlitch gem (https://github.com/ucnv/aviglitch). A frame repeater (`./framerepeater`), a JoinerAndMosher (`./join_and_mosh`)
and a KeyframeLister (`./list_keyframes`) are what's available at the moment.

It should probably be said that the project is mostly for my own pleasure and coding practice. It's not really user friendly right now if you're not me.

## Installation

Clone repository, go to glitchtools directory and run `rake install` should do the trick.

## Usage

### KeyframeLister

The KeyframeLister takes a file as an argument. It needs to be an avi file and I haven't been bothered to put in a converter.

### JoinerAndMosher

The JoinerAndMosher takes two arguments, both files. (If they're not avi files, it will try to convert them using FFMPEG, so make sure you've got that. (Seems like you should if you're into video glitching.)) The script will then
* keep the frames up to and including the first keyframe of the first file (so, in most cases just the first but you never know)
* remove all keyframes from the second file
* mosh the two files together

### Framerepeater

The Framerepeater takes five arguments, the first being the file, and then:
* the number of frames to keep before repeating
* the frame to repeat
* the number of additional frames to repeat
* the number of repetitions to make

## Development

This is something of a mess at the moment and I'm really not counting on anyone jumping in. Do get in thouch if I'm wrong.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/schizoakustik/glitchtools.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

