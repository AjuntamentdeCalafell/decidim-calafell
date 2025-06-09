# frozen_string_literal: true

source "https://rubygems.org"

ruby RUBY_VERSION
DECIDIM_VERSION = { git: "https://github.com/CodiTramuntana/decidim", branch: "release/0.28-stable" }


gem "decidim", DECIDIM_VERSION
gem "decidim-cdtb", git: "https://github.com/CodiTramuntana/decidim-module-cdtb.git", branch: "main"
gem "decidim-initiatives", DECIDIM_VERSION
gem 'decidim-file_authorization_handler', '~> 0.28.2.0'
gem 'decidim-verify_wo_registration', '~> 0.3.0'
gem "decidim-verifications-sms_direct", path: '.'
gem 'decidim-idcat_mobil'

# Solve: You have already activated uri 0.13.0, but your Gemfile requires uri 0.10.1.
gem "uri", ">= 0.13.0"

gem "daemons"
gem "delayed_job_active_record"
gem "execjs", "~> 2.7.0"
gem "figjam"
gem "uglifier", ">= 1.3.0"
gem "puma"
gem "puma_worker_killer"
gem "matrix"
gem "virtus-multiparams"
gem "wicked_pdf"
gem "whenever"

group :development, :test do
  gem "byebug", platform: :mri
  gem "decidim-dev", DECIDIM_VERSION
  gem "faker"
  gem "rspec-rails"
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
  gem 'sentry-raven'
  gem 'sidekiq'
end
