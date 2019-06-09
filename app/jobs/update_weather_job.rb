class UpdateWeatherJob < ApplicationJob
  queue_as :default

  def perform(trip_id)
    trip = Trip.find(trip_id)
    WeatherRefresh.new(trip).run
    trip.update weather_enqueued_on: nil
  end
end
