# Decidim Sms Direct Verifier

A decidim package to provice user authorizations via SMS (mobile phone).


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'decidim-verifications-sms_direct'
```

And then execute:

```bash
bundle install
```

Finally install the required migrations:

```bash
bin/rake decidim_verifications_sms_direct:install:migrations
bin/rake db:migrate
```

## Configuration

Once installed, the following env variables can be configured:

????????????????

### Run tests

Create a dummy app in your application (if not present):

```bash
bin/rails decidim:generate_external_test_app
```

And run tests:

```bash
bundle exec rspec spec
```

## License

AGPLv3 (same as Decidim)
