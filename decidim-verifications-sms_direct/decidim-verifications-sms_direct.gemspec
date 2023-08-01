# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "decidim/verifications/sms_direct/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name = "decidim-verifications-sms_direct"
  s.version = Decidim::Verifications::SmsDirect::VERSION
  s.authors = ["Laura Jaime", "Oliver Valls"]
  s.email = ["laura.jv@coditramuntana.com"]
  s.summary = "SMS code verifier"
  # s.homepage = "calafell"
  s.license = "AGPLv3"

  s.files = Dir["{app,config,db,lib}/**/*", "LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["spec/**/*"]

  s.required_ruby_version = ">= 2.7.5"

  # rubocop: disable Lint/ConstantDefinitionInBlock
  DECIDIM_VERSION = "~> #{Decidim::Verifications::SmsDirect::DECIDIM_VERSION}"
  # rubocop: enable Lint/ConstantDefinitionInBlock

  s.add_dependency "decidim", DECIDIM_VERSION
  s.add_dependency "decidim-core", DECIDIM_VERSION
  s.add_dependency "decidim-admin", DECIDIM_VERSION
  s.add_dependency "decidim-verifications", DECIDIM_VERSION
  s.add_dependency "rails", ">= 5.2"

  s.add_development_dependency "decidim-cdtb"
  s.add_development_dependency "decidim-dev", DECIDIM_VERSION
  s.add_development_dependency "faker"
  s.add_development_dependency "letter_opener_web", "~> 1.3.3"
end
