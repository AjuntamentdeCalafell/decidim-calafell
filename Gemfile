# frozen_string_literal: true

source "https://rubygems.org"

ruby RUBY_VERSION
DECIDIM_VERSION = { git: "https://github.com/CodiTramuntana/decidim", branch: "release/0.27-stable" }

gem "decidim", DECIDIM_VERSION
gem "decidim-cdtb", git: "https://github.com/CodiTramuntana/decidim-module-cdtb.git"
gem "decidim-initiatives", DECIDIM_VERSION
gem "decidim-file_authorization_handler", git: "https://github.com/CodiTramuntana/decidim-file_authorization_handler.git", tag: "v0.27.1.3"
gem "decidim-verify_wo_registration", "~> 0.2.0"
gem "decidim-verifications-sms_direct", path: '.'

# temporal solution while gems embrace new psych 4 (the default in Ruby 3.1) behavior.
gem "psych", "< 4"

gem "seven_zip_ruby", git: "https://github.com/andrewhamon/seven_zip_ruby", branch: "ah/install-so-in-gem-lib"

gem "puma"
gem "matrix"

gem "uglifier", ">= 1.3.0"
gem "virtus-multiparams"
gem "wicked_pdf"

# Remove this nokogiri forces version at any time but make sure that no __truncato_root__ text appears in the cards in general.
# More exactly in comments in the homepage and in processes cards in the processes listing
gem "nokogiri", "1.13.6"

gem "execjs", "~> 2.7.0"

group :development, :test do
  gem "byebug", platform: :mri
  gem "decidim-dev", DECIDIM_VERSION
  gem "faker"
  gem "rspec-rails"
  # Load Environment variables through an .env file
  gem "dotenv-rails", "~> 2.7.5"
end

group :development do
  gem "letter_opener_web"
  gem "listen"
  gem "spring"
  gem "spring-watcher-listen", "~> 2.0.0"
  gem "web-console"
end

group :production do
  gem 'fog-aws'
  gem "aws-sdk-s3", require: false
  gem 'dalli'
  gem 'sendgrid-ruby'
  gem 'newrelic_rpm'
  gem 'sentry-raven'
  gem 'sidekiq'
end
