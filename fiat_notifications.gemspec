$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "fiat_notifications/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "fiat_notifications"
  s.version     = FiatNotifications::VERSION
  s.authors     = ["Andrew Haines"]
  s.email       = ["andrew@fiatinsight.com"]
  s.summary       = "Fiat Insight handling for notifications"
  s.description   = "This gem is designed to be used by Fiat Insight developers on Rails projects that need to manage notifications."
  s.homepage      = "https://github.com/fiatinsight/fiat_notifications"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", ">= 5.2.1"
  s.add_dependency "twilio-ruby"
  s.add_dependency "postmark-rails"

  s.add_development_dependency "sqlite3"
end
