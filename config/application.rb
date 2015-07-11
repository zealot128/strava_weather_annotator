require File.expand_path('../boot', __FILE__)

require 'rails/all'

Bundler.require(*Rails.groups)

module StravaWeather
  class Application < Rails::Application

    config.generators do |g|
      g.test_framework :rspec,
        fixtures: false,
        view_specs: false,
        helper_specs: false,
        routing_specs: false,
        controller_specs: false,
        request_specs: false
    end
    config.time_zone = 'Europe/Berlin'
    config.active_record.raise_in_transactional_callbacks = true
  end
end
