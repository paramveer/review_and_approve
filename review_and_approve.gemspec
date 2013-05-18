# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'review_and_approve/version'

Gem::Specification.new do |gem|
  gem.name          = "review_and_approve"
  gem.version       = ReviewAndApprove::VERSION
  gem.authors       = ["Paramveer Singh"]
  gem.email         = ["paramveer.singh@hikeezee.com"]
  gem.description   = %q{Adds Review and Approval functionality for content sites.}
  gem.summary       = %q{Adds Review and Approval functionality for content sites.}
  gem.homepage      = ""

  gem.files         = Dir["{app,lib}/**/*"] + ["Rakefile", "README.md"]
                      #`git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_development_dependency "rspec", "~>2.0"
  gem.add_development_dependency "rake"#, "0.8.7"
  gem.add_runtime_dependency "supermodel" 
  gem.add_development_dependency "mocha"
  gem.add_runtime_dependency "rails"
  gem.add_runtime_dependency "cancan"
  gem.add_development_dependency "debugger"
end
