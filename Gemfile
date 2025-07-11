# frozen_string_literal: true

source "https://rubygems.org"

ruby RUBY_VERSION
DECIDIM_VERSION = { git: "https://github.com/CodiTramuntana/decidim", branch: "release/0.28-stable" }.freeze

gem "decidim", DECIDIM_VERSION
gem "decidim-cdtb", git: "https://github.com/CodiTramuntana/decidim-module-cdtb.git", branch: "main"
gem "decidim-file_authorization_handler", "~> 0.28.2.0"
gem "decidim-initiatives", DECIDIM_VERSION
gem "decidim-term_customizer", "~> 0.28.0", git: "https://github.com/mainio/decidim-module-term_customizer.git"
gem "decidim-verifications-sms_direct", path: "."
gem "decidim-verify_wo_registration", "~> 0.3.0"

# Solve: You have already activated uri 0.13.0, but your Gemfile requires uri 0.10.1.
gem "uri", ">= 0.13.0"

gem "daemons"
gem "delayed_job_active_record"
gem "execjs", "~> 2.7.0"
gem "figjam"
gem "matrix"
gem "puma"
gem "puma_worker_killer"
gem "uglifier", ">= 1.3.0"
gem "virtus-multiparams"
gem "whenever"
gem "wicked_pdf"

group :development, :test do
  gem "byebug", platform: :mri
  gem "decidim-dev", DECIDIM_VERSION
  gem "faker"
  # Set versions because Property AutoCorrect errors.
  gem "rspec-rails", "~> 6.0.4"
  gem "rubocop-factory_bot", "2.25.1"
  gem "rubocop-rspec", "2.26.1"
end

group :development do
  gem "letter_opener_web"
  gem "listen"
  gem "spring"
  gem "spring-watcher-listen", "~> 2.0.0"
  gem "web-console"
end

group :production do
  gem "aws-sdk-s3", require: false
  gem "dalli"
  gem "fog-aws"
  gem "sendgrid-ruby"
  gem "sentry-raven"
  gem "sidekiq"
end
