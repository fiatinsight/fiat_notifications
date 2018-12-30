# Fiat Notifications

This gem is designed to be used by Fiat Insight developers on Rails projects that need to handle complex notifications. It allows you to offload notification creation to highly configurable background jobs, including email and SMS delivery. It also provides resources for managing flexible, granular notification preferences.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'fiat_notifications'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install fiat_notifications

## Setup

Run the migrations from the engine by typing:

    $ rake db:migrate

Create an initializer at `config/initializers/fiat_notifications.rb` to set required variables for your implementation:

```ruby
FiatNotifications.from_email_address = "test@something.com"
FiatNotifications.email_template_id = "1234567"
FiatNotifications.from_phone_number = "+12025551234"
```

## Postmark / transactional email

To enable transactional emails through Postmark, set up the [postmark-rails](https://github.com/wildbit/postmark-rails) gem as normal in your main app. Make sure your Postmark server API token is stored in a `credentials.yml` file as:

```ruby
postmark_api_token: postmark-token
```

## Twilio / SMS

To enable sending SMS messages through Twilio, set up the [twilio-ruby](https://github.com/twilio/twilio-ruby) gem as normal in your main app. Make sure your Twilio API keys are stored in a `credentials.yml` file with the following format:

```ruby
twilio:
  auth_token: twilio-auth-token
  account_sid: twilio-account-sid
```

Also, make sure to include a `config/initializers/twilio.rb` file in your main app with your account keys:

```ruby
Twilio.configure do |config|
  config.account_sid = Rails.application.secrets.twilio_account_sid
  config.auth_token = Rails.application.secrets.twilio_auth_token
end
```

## How to use

### Creating notifications

Notifications can be invoked from any class within an application (i.e, the `notifier`). They can be assigned to any other class as a `creator`, and they can accept any class as `observable`. These are all validated, polymorphic fields. Notifications can also accept an action type / verb.

For example, on a `Comment` class with an author and recipient, you could invoke a notification using a delayed job by calling:

```ruby
after_commit -> { FiatNotifications::Notification::CreateNotificationJob.set(wait: 5.seconds).perform_later(self, self.author, self.recipient, "mentioned", nil, nil) }, on: :create
```

From the database, notifications can be reported to users with the same information. For example, you might write:

```
<%= i.creator.name %> <%= i.action %> you on <%= link_to "this comment", notification_path(id: i.id), method: :patch %>
```

### Notification preferences

When creating a notification, you can also pass in a further set of arguments for `notified_type` and `notified_ids`. This pertains to notification preferences, which can be created and stored for any class in your application. For example, in the same example, you could put:

```ruby
after_commit -> { FiatNotifications::Notification::CreateNotificationJob.set(wait: 5.seconds).perform_later(self, self.author, self.recipient, "mentioned", "User", self.attendable.person.eligible_users_to_notify.pluck(:id)) }, on: :create
```

## Development

To build this gem for the first time, run `gem build fiat_notifications.gemspec` from the project folder.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/fiatinsight/fiat_notifications.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
