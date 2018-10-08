# Fiat Notifications

This gem is designed to be used by Fiat Insight developers on Rails projects that need to handle notifications.

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

Install the migrations in your app root folder by running:

    $ rails fiat_notifications:install:migrations
    $ rake db:migrate

Notifications can be invoked from any class within an application. They can be assigned to any other class as a recipient, and they can take any class as a creator. They also accept an action type / verb:

For example, on a `Comment` class with an author and recipient, you could invoke a notification using a delayed job by calling:

```ruby
after_commit -> { FiatNotifications::Notification::CreateNotificationJob.set(wait: 5.seconds).perform_later(self, self.author, self.recipient, "mentioned") }, on: :create
```

Notifications can be reported to application recipients using the same information. For example, you might write:

```
<%= i.creator.name %> <%= i.action %> you on <%= link_to "this comment", notification_path(id: i.id), method: :patch %>
```

## Development

To build this gem for the first time, run `gem build fiat_notifications.gemspec` from the project folder.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/fiatinsight/fiat_notifications.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
