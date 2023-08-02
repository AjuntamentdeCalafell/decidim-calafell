# frozen_string_literal: true

source "https://rubygems.org"

ruby RUBY_VERSION
DECIDIM_VERSION = { git: "https://github.com/CodiTramuntana/decidim", branch: "release/0.26-stable" }

gem "decidim", DECIDIM_VERSION
gem "decidim-cdtb", path: "/home/oliver/prog/decidim/modules/decidim-cdtb"
gem "decidim-initiatives", DECIDIM_VERSION
gem "decidim-file_authorization_handler", git: "https://github.com/CodiTramuntana/decidim-file_authorization_handler.git", tag: "v0.26.2.7"
gem "decidim-verify_wo_registration", git: "https://github.com/CodiTramuntana/decidim-verify_wo_registration", tag: "v0.0.2"
gem 'decidim-verifications-sms_direct', path: '.'

gem "puma"
gem "uglifier", ">= 1.3.0"
gem "virtus-multiparams"
gem "wicked_pdf"

# Remove this nokogiri forces version at any time but make sure that no __truncato_root__ text appears in the cards in general.
# More exactly in comments in the homepage and in processes cards in the processes listing
gem "nokogiri", "1.13.3"

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
  gem "listen", "~> 3.1.0"
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
