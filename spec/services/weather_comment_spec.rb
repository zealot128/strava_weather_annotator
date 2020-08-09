RSpec.describe WeatherComment do
  specify 'Weather Comment rendering' do
    user = User.create!(weather_template: User.default_weather_template)
    trip = user.trips.create!
    trip.weather_informations.create!(
      "offset" => 0,
      "data" => { "latitude" => 50.058792,
                  "longitude" => 8.519161,
                  "timezone" => "Europe/Berlin",
                  "currently" =>
         { "time" => 1_596_743_956,
           "summary" => "Clear",
           "icon" => "clear-night",
           "precipIntensity" => 0,
           "precipProbability" => 0,
           "temperature" => 25.41,
           "apparentTemperature" => 25.41,
           "dewPoint" => 13.43,
           "humidity" => 0.47,
           "pressure" => 1020.4,
           "windSpeed" => 1.28,
           "windGust" => 1.89,
           "windBearing" => 72,
           "cloudCover" => 0.05,
           "uvIndex" => 0,
           "visibility" => 16.093,
           "ozone" => 304.3 },
                  "flags" => { "sources" => ["cmc", "gfs", "icon", "isd", "madis"], "nearest-station" => 4.027, "units" => "si" },
                  "offset" => 2 },
      "lat" => 50.058792,
      "lon" => 8.519161
    )
    comment = WeatherComment.new(trip).render
    expect(comment).to include "25°C"
    puts comment

  end
end
