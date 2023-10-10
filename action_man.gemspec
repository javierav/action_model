# frozen_string_literal: true

require_relative "lib/action_man/version"

Gem::Specification.new do |spec|
  #
  ## INFORMATION
  #
  spec.name = "action_man"
  spec.version = ActionMan.version
  spec.summary = "Simple actions for your models"
  spec.homepage = "https://github.com/javierav/action_man"
  spec.license = "MIT"

  #
  ## OWNERSHIP
  #
  spec.authors = ["Javier Aranda"]
  spec.email = ["aranda@hey.com"]

  #
  ## METADATA
  #
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/javierav/action_man/tree/v#{spec.version}"
  spec.metadata["changelog_uri"] = "https://github.com/javierav/action_man/blob/v#{spec.version}/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  #
  ## GEM
  #
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test)/|\.git)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  #
  ## DOCUMENTATION
  #
  spec.extra_rdoc_files = %w[LICENSE README.md]
  spec.rdoc_options     = ["--charset=UTF-8"]

  #
  ## REQUIREMENTS
  #
  spec.required_ruby_version = ">= 3.1"

  #
  ## DEPENDENCIES
  #
  spec.add_dependency "activesupport", ">= 6.1", "< 8.0"
end
