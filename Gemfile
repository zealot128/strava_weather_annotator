source 'https://rubygems.org'

git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem 'rails', '~> 5.2.1'
gem 'pg'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'jquery-rails'
gem 'pagy'

gem 'bootstrap-sass', '~> 3.4.0'
gem 'bootswatch-rails'

gem 'omniauth'
gem 'strava-api-v3', '~> 0.8'
gem 'omniauth-strava', github: 'thogg4/omniauth-strava'
gem 'forecast_io'
gem 'polylines'
gem 'sucker_punch', '~> 2.0'

gem 'simple_form'
gem 'slim-rails'
gem 'bootsnap'
gem 'webpacker', '~> 4.x'

group :production do
  gem 'exception_notification'
end

group :development, :test do
  gem 'faker'
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
