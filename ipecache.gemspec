$:.push File.expand_path('../lib', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = 'ipecache'
  gem.version       = '0.0.16'
  gem.authors       = ["Jon Cowie"]
  gem.email         = 'jonlives@gmail.com'
  gem.homepage      = 'https://github.com/jonlives/ipecache'
  gem.summary       = "An extensible tool for purging urls from caches and CDNs"
  gem.description   = "An extensible tool for purging urls from caches and CDNs"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "ipecache"
  gem.require_paths = ["lib"]

  gem.add_runtime_dependency 'app_conf', '>= 0.4.0'
  gem.add_runtime_dependency 'choice', '>= 0.1.6'
  gem.add_runtime_dependency 'faraday_middleware', '>= 0.9.0'
  gem.add_runtime_dependency 'public_suffix', '>= 1.4.2'
  gem.add_runtime_dependency 'aws-sdk-v1', '>= 1.0'
  gem.add_runtime_dependency 'maxcdn', '>= 0.2.1'
  gem.add_runtime_dependency 'akamai-edgegrid', '>= 1.0.7'
end
