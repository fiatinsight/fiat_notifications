# Fiat Notifications

> Currently installed on [Parish.es](https://github.com/fiatinsight/parish-app) and [Cleveland Mixer](https://github.com/fiatinsight/cleveland-mixer/).

This engine is designed to be used by [@fiatinsight](https://fiatinsight.com) developers on Rails projects that need to handle complex notifications. It encourages offloading notification creation to highly configurable background jobs that produce in-app, SMS, and email output. It also provides resources for managing flexible, granular notification preferences.

## Getting started

Add this line to your application's `Gemfile`:

```ruby
gem 'fiat_notifications'
```

Then `bundle` and run the required migrations directly by typing:

    $ rake db:migrate

Create an initializer at `config/initializers/fiat_notifications.rb` to set some required variables for your implementation:

```ruby
FiatNotifications.postmark_api_token = "123abc-xyz"
FiatNotifications.from_email_address = "test@email.com"
FiatNotifications.reply_to_email_address = "abcdefg@inbound.email.com"
FiatNotifications.email_template_id = "1234567"
FiatNotifications.twilio_auth_token = "123abc-xyz"
FiatNotifications.twilio_account_sid = "123abc-xyz"
FiatNotifications.from_phone_number = "+15555551234"
FiatNotifications.slack_api_token = "xyz-123abc"
```

> Note: Currently, the above variables are all required to be set at least to `nil`

Finally, mount the engine in your `routes.rb` file:

```ruby
mount FiatNotifications::Engine => "/notifications"
```

### Postmark / transactional email

To enable transactional emails through Postmark, install and set up the [postmark-rails](https://github.com/wildbit/postmark-rails) gem as normal.

The following keys are made available to use with your email template: `creator`, `subject`, `body`, `url`, and `timestamp`.

### Twilio / SMS

To enable sending SMS messages through Twilio, instatll and set up the [twilio-ruby](https://github.com/twilio/twilio-ruby) gem as normal. Make sure your Twilio API keys are stored in a `credentials.yml` file with the following format:

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

## Usage

### Creating notifications

Notifications can be invoked _from_ any instance of a class within an application, and report _about_ any other class instance _to_ any other class instance. You can create a new notification simply using:

```ruby
FiatNotifications::Notification.create(notifier: notifier, creator: creator, observable: observable, action: action)
```

They accept the following parameters:

| Parameter   |      Purpose      | Format | Required?
|----------|-------------|:----|:---|
| `notifier` |  What generated the notification? | Active Record object (polymorphic) | Yes
| `creator` |    Who created the notification?   | Active Record object (polymorphic) | Yes
| `observable` | What's being reported on? | Active Record object (polymorphic) | Yes
| `action` | What's the verb that describes what happened between the `creator` and the `observable`? | String | No
| `hidden` |  Should this notification be marked as hidden? | Boolean | No

### Using a job

The preferred way to create a notification is by using the [`CreateNotificationJob`](https://github.com/fiatinsight/fiat_notifications/blob/master/app/jobs/fiat_notifications/notification/create_notification_job.rb) class. Not only does this allow for delayed execution, but it also triggers a series of conditional actions based on the arguments passed.

For example, from a `Comment` class with an associated author and recipient record, you could invoke a notification using a delayed job by calling:

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

The `notifier`, `creator`, and `observable` arguments are required, as before. `CreateNotificationJob` also accepts a number of optional parameters.

| Argument   |      Question?      | Format
|----------|-------------|:----|
| `action` | What's the verb that describes what happened between the `creator` and the `observable`? | String
| `notifiable_type` | What type of thing / person should be notified about this? | String (model name)
| `notifiable_ids` | What are the IDs for those things / people under that class? | Array
| `notifier_name` | What's the `notifier`'s nice name? | String
| `creator_name` | What's the `creator`'s nice name? | String
| `observable_name` | What's the `observable`'s nice name? | String
| `url` | What's the URL to access a record? | String
| `sms_body` | What's the full SMS message? | String
| `email_body` | What's the full email message? | String
| `email_template_id` | What's the email template ID? | String

Creating a notification with `CreateNotificationJob` always saves a new notification record on the `fi_notifications` table, which can be reported back to users in your app, e.g.:

```
<%= i.creator.name %> <%= i.action %> you on <%= link_to "this comment", notification_path(id: i.id), method: :patch %>
```

### Notification preferences

Passing values to the `notified_type` and `notified_ids` arguments with `CreateNotificationJob` allows you to invoke notification preferences, stored on the `fi_notification_preferences` table. These can be created and stored for any class in your application (typically a `User`) as `notifiable`. Notification preferences also refer to a `noticeable`, which maps to the `observable` argument for `CreateNotificationJob`. And the accept boolean values for `email`, `sms`, and `push`.

Per the example, above, you could put:

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

This would try to locate notification preferences for any `User` among the relevant `team_members` and execute the Twilio and/or Postmark blocks in `CreateNotificationJob`, depending on which service(s) you've set up. Notified recipients would receive whatever type of notifications are indicated on their preferences.

> Note: Push notifications aren't yet controlled in `CreateNotificationJob`. However, future implementations using something like the currently-suppressed `RelayJob` will facilitate this.

### Hiding notifications

To hide a notification, you can pass:

```ruby
link_to fiat_notifications.notification_path(i, hide: true), method: :patch, remote: true
```

This runs via JavaScript, and will also attempt to remove the page element tagged with `data-notification-id` and with the value of the notification's ID.

## Development

To build this gem for the first time, run `gem build fiat_notifications.gemspec` from the project folder.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/fiatinsight/fiat_notifications.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
