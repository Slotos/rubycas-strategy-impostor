# -*- encoding: utf-8 -*-
require File.expand_path('../lib/rubycas-strategy-impostor/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Dmitriy Soltys"]
  gem.email         = ["slotos@gmail.com"]
  gem.description   = %q{Identity thief}
  gem.summary       = %q{Provides ability to switch intendity to any desired one, given you have certain role defined}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "rubycas-strategy-impostor"
  gem.require_paths = ["lib"]
  gem.version       = CASServer::Strategy::Impostor::VERSION

  gem.add_dependency "sequel"
  gem.add_dependency "rubycas-server"

  gem.add_development_dependency "sqlite3"
  gem.add_development_dependency "rspec"
  gem.add_development_dependency "rack-test"
end
