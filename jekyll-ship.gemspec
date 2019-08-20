lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "jekyll/ship/version"

Gem::Specification.new do |spec|
  spec.name          = "jekyll-ship"
  spec.version       = Jekyll::Ship::VERSION
  spec.authors       = ["Andrew Myers"]
  spec.email         = ["andrew_myers@wgbh.org"]

  spec.summary       = %q{Build a Jekyll site and ship it.}
  spec.description   = %q{Build a Jekyll site and ship it.}
  spec.license       = "MIT"

  spec.metadata["allowed_push_host"] = "http://rubygems.org"

  spec.metadata["homepage_uri"] = "https://github.com/afred/jekyll-ship"
  spec.metadata["source_code_uri"] = "https://github.com/afred/jekyll-ship"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"

  spec.add_dependency "jekyll", ">= 3.8", "< 5"
  spec.add_dependency 'activesupport', '~> 5.2'
  spec.add_dependency 'aws-sdk-s3', '~> 1.46'
end
