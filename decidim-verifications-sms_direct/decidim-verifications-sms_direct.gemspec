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
  s.homepage = "https://github.com/AjuntamentdeCalafell/decidim-calafell"
  s.license = "AGPLv3"

  s.files = Dir["{app,config,db,lib}/**/*", "LICENSE", "Rakefile", "README.md"]

  s.required_ruby_version = ">= 3.1.7"

  # rubocop: disable Lint/ConstantDefinitionInBlock
  DECIDIM_VERSION = "~> #{Decidim::Verifications::SmsDirect::DECIDIM_VERSION}".freeze
  # rubocop: enable Lint/ConstantDefinitionInBlock

  s.add_dependency "decidim", DECIDIM_VERSION
  s.add_dependency "decidim-admin", DECIDIM_VERSION
  s.add_dependency "decidim-core", DECIDIM_VERSION
  s.add_dependency "decidim-verifications", DECIDIM_VERSION
  s.add_dependency "phonelib", ">= 0.8.3"
  s.add_dependency "rails", ">= 6.0"

  s.metadata["rubygems_mfa_required"] = "true"
end
