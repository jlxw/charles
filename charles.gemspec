# -*- encoding: utf-8 -*-
require File.expand_path('../lib/charles/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Jason Ling Xiaowei"]
  gem.email         = ["jason@jeyel.com"]
  gem.description   = 'Charles the Content Extractor in Ruby'
  gem.summary       = 'Charles the Content Extractor in Ruby'
  gem.homepage      = "https://github.com/jlxw/charles"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "charles"
  gem.require_paths = ["lib"]
  gem.version       = Charles::VERSION
end
