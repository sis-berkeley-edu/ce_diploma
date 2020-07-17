require_relative 'lib/ce_diploma/version'

Gem::Specification.new do |spec|
  spec.name          = "ce_diploma"
  spec.version       = CeDiploma::VERSION
  spec.authors       = ["Jason Miller"]
  spec.email         = ["jason@redconfetti.com"]

  spec.summary       = %q{Ruby support for CeDiploma integration}
  spec.description   = %q{Provides support Ruby support for CeDiploma integration}
  spec.homepage      = "https://github.com/sis-berkeley-edu/ce_diploma"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "https://github.com/sis-berkeley-edu/ce_diploma/blob/master/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
