# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'whitepaper/version'

Gem::Specification.new do |gem|
  gem.name          = "whitepaper"
  gem.version       = Whitepaper::VERSION
  gem.authors       = ["wilkie"]
  gem.email         = ["wilkie05@gmail.com"]
  gem.description   = %q{Finds metadata on scholarly works and is able to download pdfs of whitepapers.}
  gem.summary       = %q{Finds whitepaper metadata and pdf download links with a basic keyword query using web-based databases such as Google and CiteSeerX.}
  gem.homepage      = "https://github.com/wilkie/whitepaper"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency "nokogiri"
  gem.add_dependency "mechanize"
end
