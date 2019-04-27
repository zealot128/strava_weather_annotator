class WeatherRefresh
  def initialize(trip)
    @trip = trip
  end
  attr_reader :trip

  def run
    update_weather
    summarize_weather
  end

  delegate :user, to: :@trip

  # every 15 minutes
  def resolution
    15
  end

  def update_weather
    data = GpxFromTripStream.new(trip).point_data
    both =  data.map { |i| [i['time'], i['latlng']] }

    samples = both.group_by { |i, _| ((i / 60.0) / resolution).round }.values.map(&:first)
    base = trip.start_datetime
    samples.each do |offset, coords|
      time = base + offset
      wi = trip.weather_informations.where(offset: offset).first_or_initialize
      next unless wi.new_record? and user.quota.can_forecast?

      fc = ForecastIO.forecast(
        coords.first, coords.last,
        time: time.to_i,
        params: {
          units: 'si',
          exclude: 'minutely,hourly,daily'
        }
      )
      user.add_log('forecast', "GET Forecast #{coords.first.round(2)},#{coords.last.round(2)}")
      wi.data = fc
      wi.datetime = time
      wi.lat = coords.first
      wi.lon = coords.last
      wi.save
    end
  end

  def summarize_weather
    wc = WeatherComment.new(trip)
    trip.temperature = wc.temperature
    trip.icon = trip.weather_informations.map(&:image_classes).group_by { |c| c }.min_by { |_a, b| -b.count }.first
    trip.save
  end
end
