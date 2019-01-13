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

Your email template should handle the following fields: `creator`, `subject`, `body`, `url`, and `timestamp`.

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

Notifications can be invoked _from_ any instance of a class within an application, and they can report _about_ any other class instance _to_ any other class instance. You can create a new notification simply using:

```ruby
FiatNotifications::Notification.create(notifier: notifier, creator: creator, observable: observable, action: action)
```

The preferred way to create a notification is by using the `CreateNotificationJob` class. For example, from a `Comment` class with an associated author and recipient record, you could invoke a notification using a delayed job by calling:

```ruby
after_commit -> {
  FiatNotifications::Notification::CreateNotificationJob.set(wait: 5.seconds).perform_later(
    self,
    self.author,
    self.recipient,
    action: "mentioned",
    creator_name: self.author.username,
    observable_name: self.recipient.username,
    url: "https://example.com/comments/#{self.id}",
    email_body: self.body
  )}, on: :create
```

The `notifier`, `creator`, and `observable` arguments are required. `CreateNotificationJob` accepts a number of optional parameters, too.

| Argument   |      Question?      | Format | Required?
|----------|-------------|:----|:---|
| `notifier` |  What generated the notification? | Active Record object (polymorphic) | Yes
| `creator` |    Who created the notification?   | Active Record object (polymorphic) | Yes
| `observable` | What's being reported on? | Active Record object (polymorphic) | Yes
| `action` | What's the verb that describes what happened between the `creator` and the `observable`? | String | Optional
| `notifiable_type` | What type of thing / person should be notified about this? | String (model name) | Optional
| `notifiable_ids` | What are the IDs for those things / people under that class? | Array | Optional
| `notifier_name` | What's the `notifier`'s nice name? | String | Optional
| `creator_name` | What's the `creator`'s nice name? | String | Optional
| `observable_name` | What's the `observable`'s nice name? | String | Optional
| `url` | What's the URL to access a record? | String | Optional
| `sms_body` | What's the full SMS message? | String | Optional
| `email_body` | What's the full email message? | String | Optional
| `email_template_id` | What's the email template ID? | String | Optional

Creating a notification with `CreateNotificationJob` always saves a record on the `fi_notifications` table, which can be reported back to users in your app, e.g.:

```
<%= i.creator.name %> <%= i.action %> you on <%= link_to "this comment", notification_path(id: i.id), method: :patch %>
```

### Notification preferences

Passing values to the `notified_type` and `notified_ids` arguments allows you to invoke notification preferences, stored on the `fi_notification_preferences` table. These can be created and stored for any class in your application (typically a `User`). For example, in the same example, you could put:

```ruby
after_commit -> {
  FiatNotifications::Notification::CreateNotificationJob.set(wait: 5.seconds).perform_later(
    self,
    self.author,
    self.recipient,
    action: "mentioned",
    notified_type: "User",
    notified_ids: self.team_members.pluck(:id),
    creator_name: self.author.username,
    observable_name: self.recipient.username,
    url: "https://example.com/comments/#{self.id}",
    sms_body: self.body,
    email_body: self.body
  )}, on: :create
```

## Development

To build this gem for the first time, run `gem build fiat_notifications.gemspec` from the project folder.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/fiatinsight/fiat_notifications.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
