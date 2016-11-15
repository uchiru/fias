# coding: utf-8
$:.push File.expand_path("../lib", __FILE__)

require 'fias/version'

Gem::Specification.new do |spec|
  spec.name          = "fias"
  spec.version       = Fias::VERSION
  spec.authors       = ["Dmitry Korotin"]
  spec.email         = ["soxat73rus@gmail.com"]

  spec.summary       = %q{Write a short summary, because Rubygems requires one.}
  spec.description   = %q{Write a longer description or delete this line.}
  spec.homepage      = "TODO: Put your gem's website or public repo URL here."
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'bundler', '>= 1.7'
  spec.add_runtime_dependency 'rake', '>= 10.0'
  spec.add_runtime_dependency 'savon', '~> 2.11'
  spec.add_runtime_dependency 'progressbar', '~> 0.21'
  spec.add_runtime_dependency 'rails', '4.1.8'
end
