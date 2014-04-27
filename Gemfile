source 'https://rubygems.org'

gem 'rails', '~> 4.0.0'

gem 'sass-rails',   '~> 4.0.0'
gem 'coffee-rails', '~> 4.0.0'
gem 'twitter-bootstrap-rails'
gem 'jquery-migrate-rails'

platforms :ruby_20, :ruby_21 do
  gem 'pg'
  gem 'oj'
end
platforms :jruby do
  gem 'therubyrhino'
  gem 'activerecord-jdbcpostgresql-adapter', '~> 1.3.0'
  gem 'jrjackson'
  gem 'thread_safe', '0.1.2'
end
gem 'uglifier', '>= 1.3.0'
gem 'activerecord-import', '~> 0.5.0'
gem 'jquery-rails'
gem 'haml-rails'
gem 'decent_exposure'
gem 'devise', github: 'plataformatec/devise', branch: 'rails4'
gem 'kaminari'
gem 'airbrake'
gem 'puma'

gem 'simple_form', '~> 3.0.0.rc'
gem 'show_for', '~> 0.3.0.rc'
gem 'high_voltage'
gem 'carrierwave'
gem 'sidekiq'
gem 'sidekiq-failures'
gem 'slim'
gem 'sinatra', :require => nil
gem 'celluloid'
gem 'capistrano', '~>2.15.5'
gem 'foreman'
gem 'clockwork'

group :development do
  gem 'quiet_assets'
  gem 'better_errors', github: 'charliesome/better_errors'
end

group :test, :development do
  gem 'rspec-rails'
end

group :test do
  gem 'launchy'
  gem 'simplecov', :require => false
  gem 'capybara'
  gem 'poltergeist'
  gem 'factory_girl_rails'
  gem 'database_cleaner'
  gem 'timecop'
end
