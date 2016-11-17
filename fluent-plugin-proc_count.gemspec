# -*- encoding: utf-8 -*-

Gem::Specification.new do |gem|
  gem.name          = "fluent-plugin-proc_count"
  gem.version       = "0.0.1"
  gem.summary       = %q{process count check plugin for fluentd.}
  gem.description   = %q{process count check plugin for fluentd.}
  gem.license       = "MIT"
  gem.authors       = ["toyama0919"]
  gem.email         = "toyama0919@gmail.com"
  gem.homepage      = "https://github.com/toyama0919/fluent-plugin-proc_count"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_runtime_dependency 'ffi'
  gem.add_runtime_dependency 'sys-proctable'

  gem.add_development_dependency 'bundler'
  gem.add_development_dependency 'fluentd'
  gem.add_development_dependency 'pry'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rubocop'
  gem.add_development_dependency 'rubygems-tasks'
  gem.add_development_dependency 'yard'
end
