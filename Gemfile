source 'https://rubygems.org'

git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem 'rails', '~> 5.2.1'
gem 'pg'
gem 'pagy'

gem 'omniauth'
gem 'strava-ruby-client'
gem 'omniauth-strava', github: 'thogg4/omniauth-strava'
gem 'forecast_io'
gem 'sucker_punch', '~> 2.0'

gem 'simple_form'
gem 'slim-rails'
gem 'bootsnap'
gem 'webpacker', '~> 4.x'

group :production do
  gem 'exception_notification'
  gem "whenever", require: false
end

group :development, :test do
  gem 'faker'
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'pry-rails'
  gem 'pry-rescue'
  gem 'rspec-rails'
  gem 'puma'
end

group :development do
  gem 'listen'
  gem 'annotate'
end

group :test do
  gem 'capybara'
  gem 'database_cleaner'
end

