source 'https://rubygems.org'

# Core rails gems.  Don't mess with these unless you really know what you're
# doing.
gem 'rails', '~> 4.0.0'
gem 'sass-rails',   '~> 4.0.0'
gem 'coffee-rails', '~> 4.0.0'
gem 'uglifier', '>= 1.3.0'
gem 'jquery-rails'

# Library that defines the basic look and feel of the site
gem 'twitter-bootstrap-rails'

# Library that fixes some weird Javascript bug that I don't recall.  May no
# longer be necessary
gem 'jquery-migrate-rails'

platforms :ruby_20, :ruby_21 do
  # Database driver for Postgresql
  gem 'pg'
  # JSON parsing library
  gem 'oj'
end
platforms :jruby do
  # Javascript engine that may not be necessary if node.js is installed, but
  # I'm not certain.
  gem 'therubyrhino'
  # Database driver for Postgresql
  gem 'activerecord-jdbcpostgresql-adapter', '~> 1.3.0'
  # JSON parsing library
  gem 'jrjackson'
  # Fixes some threading bug.  May not be necessary in future JRubies
  gem 'thread_safe', '0.1.2'
end

# Makes it somewhat easier to do bulk loading of data to the database.
# Normally ActiveRecord will make a separate transaction for each insert.
gem 'activerecord-import', '~> 0.5.0'

# Alternative to ERB/HTML for building views.
gem 'haml-rails'

# Allows you to define an interface in the controller for the view to call to.
# Replaces variable assignment that makes up the bulk of controllers.
gem 'decent_exposure'

# Library for user authentication
gem 'devise', github: 'plataformatec/devise', branch: 'rails4'

# Library for making page numbering for large data sets
gem 'kaminari'

# Library that sends out emails when there are errors in production
gem 'airbrake'

# Multi-thread application server
gem 'puma'

# Libraries to simplify form building and object representation on web pages.
gem 'simple_form', '~> 3.0.0.rc'
gem 'show_for', '~> 0.3.0.rc'

# Library that makes it easy to include static pages (in the pages directory in
# the views folder).
gem 'high_voltage'

# Library for managing file uploads
gem 'carrierwave'

# Background processing.  Asynchronous and parallel.
gem 'sidekiq'

# Track failed jobs in a nice way on the sidekiq page.
gem 'sidekiq-failures'

# I believe this is a requirement of twitter bootstrap.
gem 'slim'

# Requirements of sidekiq
gem 'sinatra', :require => nil
gem 'celluloid'

# Library for deploying to production (see config/deploy.rb)
gem 'capistrano', '~>2.15.5'

# Library for creating upstart processes in production (see Procfile)
gem 'foreman'

# Library for scheduling periodic jobs (see clockwork.rb)
gem 'clockwork'

group :development do
  # Gets rid of cruft in the console when running the development server
  gem 'quiet_assets'
  # Provides more useful error information in development (on the web page)
  gem 'better_errors', github: 'charliesome/better_errors'
end

group :test, :development do
  # Testing framework
  gem 'rspec-rails'
end

group :test do
  # Makes it possible to open a web page in tests to see the failure state
  gem 'launchy'
  # Tracks test coverage
  gem 'simplecov', :require => false
  # Library that works with rspec to allow testing views/web behavior
  gem 'capybara'
  # Library that works with phantom.js to act as a headless browser
  gem 'poltergeist'
  # Library for creating testing factories
  gem 'factory_girl_rails'
  # Ensures that the database is reset between tests
  gem 'database_cleaner'
  # Simulates the passage of time
  gem 'timecop'
end

gem 'js_cookie_rails', '~> 1.0', '>= 1.0.1'
