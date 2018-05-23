# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'glitchtools/version'

Gem::Specification.new do |spec|
  spec.name          = "glitchtools"
  spec.version       = Glitchtools::VERSION
  spec.authors       = ["schizoakustik"]
  spec.email         = ["schizoakustik@schizoakustik.se"]

  spec.summary       = %q{"Various tools for glitching avi files."}
  spec.description   = %q{"Various tools for glitching avi files, based on AviGlitch gem and streamio-ffmpeg."}
  spec.homepage      = "https://github.com/schizoakustik/glitchtools"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "bin"
  spec.executables   = ["join_and_mosh", "framerepeater", "list_keyframes", "gif_export", "randomrepeater"]
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"

  spec.add_runtime_dependency "aviglitch"
  spec.add_runtime_dependency "streamio-ffmpeg"
end
