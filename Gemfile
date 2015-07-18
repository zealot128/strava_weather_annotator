source 'https://rubygems.org'

gem 'rails', '~> 4.2.2'
gem 'backport_new_renderer' # TODO Rails 5
gem 'pg'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'jquery-rails'
gem 'turbolinks'

group :development, :test do
  gem 'web-console', '~> 2.0'
end
gem 'bootstrap-sass'
gem 'bootswatch-rails'

gem 'omniauth'
gem 'strava-api-v3', github: 'zealot128-os/strava-api-v3'
gem 'omniauth-strava', github: 'zealot128-os/omniauth-strava'
gem 'forecast_io'
gem 'polylines'

gem 'simple_form'
gem 'slim-rails'

group :production do
  gem 'exception_notification'
end

group :development do
  gem 'capistrano'
  gem 'capistrano-bundler'
  gem 'capistrano-rails'
  gem 'capistrano-rails-console'
  gem 'capistrano-rvm'
  gem "airbrussh", require: false
  gem 'quiet_assets'
end
group :development, :test do
  gem 'faker'
  gem 'pry-rails'
  gem 'pry-rescue'
  gem 'rspec-rails'
end
group :test do
  gem 'capybara'
  gem 'database_cleaner'
end
