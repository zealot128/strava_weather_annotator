class StravaRefresh
  attr_reader :user
  def initialize(user)
    @user = user
  end

  def run
    activities = ApiWrapper::StravaApiWrapper.new(user).get_activities(after: 12.weeks.ago)
    max = 3
    activities.reverse.each do |activity|
      trip = user.trips.where(strava_id: activity['id'].to_s).first_or_initialize
      trip.name = activity['name']
      trip.start_datetime = Time.zone.parse( activity['start_date'])
      trip.activity_type = activity['type']
      trip.distance = activity['distance']
      trip.polyline = activity['map']['summary_polyline']
      if trip.new_record?
        max -= 1
      end
      trip.save!
      update_weather(trip)
      summarize_weather(trip)
      break if max == 0
    end
  end

  def summarize_weather(trip)
    wc = WeatherComment.new(trip)
    trip.temperature = wc.temperature
    trip.icon = trip.weather_informations.map{|i| i.image_classes}.group_by{|c| c}.sort_by{|a,b| -b.count}.first.first
    trip.save
  end

  def update_weather(trip)
    response = user.strava_client.retrieve_activity_streams(trip.strava_id, 'latlng,time')
    user.add_log 'strava', "GET retrieve_activity_streams #{trip.strava_id}"

    positions = response.find{|i| i['type'] == 'latlng' }['data']
    time_offsets = response.find{|i| i['type'] == 'time' }['data']

    both = time_offsets.zip(positions)
    samples = both.in_groups_of( 30.minutes ).map{|i| i.first }
    base = trip.start_datetime
    samples.each do |offset, coords|
      time = base + offset
      wi = trip.weather_informations.where(offset: offset).first_or_initialize
      if wi.new_record? and user.quota.can_forecast?
        fc = ForecastIO.forecast(coords.first, coords.last,
                                 time: time.to_i,
                                 params: {
                                   units: 'si',
                                   exclude: 'minutely,hourly,daily'})
        user.add_log('forecast', "GET Forecast #{coords.first.round(2)},#{coords.last.round(2)}")
        wi.data = fc
        wi.datetime = time
        wi.lat = coords.first
        wi.lon = coords.last
        wi.save
      end
    end
  end
end
