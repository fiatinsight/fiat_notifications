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

Notifications can be invoked from a class within the application. For example, on a `Comment` class you could call:

```ruby
after_commit -> { Notification::CommentMentionJob.set(wait: 5.seconds).perform_later(self) }, on: :create
```

## Development

To build this gem for the first time, run `gem build fiat_notifications.gemspec` from the project folder.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/fiatinsight/fiat_notifications.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
