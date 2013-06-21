ENV["RAILS_ENV"] ||= 'test'
require 'simplecov'
SimpleCov.start
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require 'database_cleaner'
require 'capybara/rspec'
require 'capybara/poltergeist'
require 'capybara/rails'
require 'sidekiq/testing/inline'
Capybara.javascript_driver = :poltergeist
# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

Rails.logger.level = 4

RSpec.configure do |config|
  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  config.order = "random"
  config.include(MailerMacros)
  config.include(SessionHelpers, type: :feature)

  config.before(:each) do
    reset_email
  end

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each, :js => true) do
    DatabaseCleaner.strategy = :truncation, {:pre_count => true}
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end

SCHEDULER_CLASSES = [GameScheduler, DeviationScheduler, DprDeviationScheduler, DprScheduler, GenericScheduler, HierarchicalDeviationScheduler, HierarchicalScheduler]
NONGENERIC_SCHEDULER_CLASSES = SCHEDULER_CLASSES-[GenericScheduler]