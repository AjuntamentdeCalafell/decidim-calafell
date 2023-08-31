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

Remember to remove the expired codes. To do it see "Clean expired codes" in this document.

## Configuration

To configure the module, the following env variables should be set:

- `SMS_SERVICE_URL`: The base url to the Parlem API, without any path.
- `SMS_CONFIGURATION_NAME`: The name of the configuration to be used in the fix token.
- `SMS_API_TOKEN`: The fix token.

### The Parlem SMS API

API documentation can be found at https://sms.parlem.com/docs/ejemplos-api/1026.

This module uses the fix token, not the temporal token.

### Clean expired codes

To clean the expired codes a cron job should be scheduled. This cron must run the sms_direct:clean_expired_codes rake task. It is recommended to schedule the cron once evey night.

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
