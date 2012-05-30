# -*- encoding: utf-8 -*-
require File.expand_path('../lib/charles/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Jason Ling Xiaowei"]
  gem.email         = ["jason@jeyel.com"]
  gem.description   = 'Charles the Content Extractor'
  gem.summary       = 'Charles the Content Extractor'
  gem.homepage      = "https://github.com/jlxw/charles"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "charles"
  gem.require_paths = ["lib"]
  gem.version       = Charles::VERSION
  
  gem.add_dependency "ferret"
  gem.add_dependency "nokogiri"
  gem.add_dependency "htmlentities"
  gem.add_dependency "mechanize"
  gem.add_dependency "activesupport"
  gem.add_dependency "rack"
  gem.add_dependency "imagesize"
end
