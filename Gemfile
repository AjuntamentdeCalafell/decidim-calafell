# frozen_string_literal: true

source "https://rubygems.org"

ruby RUBY_VERSION
DECIDIM_VERSION = { git: "https://github.com/CodiTramuntana/decidim.git", branch: "release/0.29-stable" }.freeze

gem "decidim", DECIDIM_VERSION
gem "decidim-cdtb", "~> 0.5.5"
gem "decidim-file_authorization_handler",
    git: "https://github.com/CodiTramuntana/decidim-file_authorization_handler.git",
    tag: "v0.29.2"
gem "decidim-idcat_mobil"
gem "decidim-initiatives", DECIDIM_VERSION
gem "decidim-term_customizer", git: "https://github.com/CodiTramuntana/decidim-module-term_customizer.git", branch: "upgrade/decidim_0.29"
gem "decidim-verifications-sms_direct", path: "."
gem "decidim-verify_wo_registration", "~> 0.3.0"
gem "decidim-decidim_awesome", "~> 0.12.3"

# Solve: You have already activated uri 0.13.0, but your Gemfile requires uri 0.10.1.
gem "uri", ">= 0.13.0"

gem "daemons"
gem "delayed_job_active_record"
gem "execjs", "~> 2.7.0"
gem "figjam", "2.0.0"
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
  gem "rubocop-factory_bot"
  gem "rubocop-rspec"
  gem "rubocop-rspec_rails"
end

group :development do
  gem "letter_opener_web"
  gem "listen"
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
