class StravaRefresh
  attr_reader :user
  def initialize(user)
    @user = user
  end

  def create_or_update_activity(activity)
    trip = user.trips.where(strava_id: activity['id'].to_s).first_or_initialize
    trip.name = activity['name']
    trip.start_datetime = Time.zone.parse(activity['start_date'])
    trip.activity_type = activity['type']
    trip.distance = activity['distance']
    trip.polyline = activity['map']['summary_polyline']
    trip.save! if trip.changed?
    # update_weather(trip)
    # summarize_weather(trip)
    trip
  end

  def get_recent
    date = user.api_logs.where(provider: 'strava', title: "GET list_athlete_activities").maximum(:created_at) || 1.month.ago
    activities = ApiWrapper::StravaApiWrapper.new(user).get_activities(after: date)
    activities.reverse_each do |activity|
      next unless activity['type'].in?(['Run', 'Ride'])

      create_or_update_activity(activity)
    end
  end

  def get_all
    get_page(1)
  end

  def get_page(page)
    activities = ApiWrapper::StravaApiWrapper.new(user).get_activities(after: 5.years.ago, page: page)
    activities.reverse_each do |activity|
      next unless activity['type'].in?(['Run', 'Ride'])

      create_or_update_activity(activity)
    end
    if activities.count == 100
      get_page(page + 1)
    end
  end

  def summarize_weather(trip)
    wc = WeatherComment.new(trip)
    trip.temperature = wc.temperature
    trip.icon = trip.weather_informations.map(&:image_classes).group_by { |c| c }.min_by { |_a, b| -b.count }.first
    trip.save
  end

  def update_weather(trip)
    response = user.strava_client.retrieve_activity_streams(trip.strava_id, 'latlng,time')
    user.add_log 'strava', "GET retrieve_activity_streams #{trip.strava_id}"

    positions = response.find { |i| i['type'] == 'latlng' }['data']
    time_offsets = response.find { |i| i['type'] == 'time' }['data']

    both = time_offsets.zip(positions)
    samples = both.in_groups_of(30.minutes).map(&:first)
    base = trip.start_datetime
    samples.each do |offset, coords|
      time = base + offset
      wi = trip.weather_informations.where(offset: offset).first_or_initialize
      next unless wi.new_record? and user.quota.can_forecast?

      fc = ForecastIO.forecast(coords.first, coords.last,
        time: time.to_i,
        params: {
          units: 'si',
          exclude: 'minutely,hourly,daily'
        })
      user.add_log('forecast', "GET Forecast #{coords.first.round(2)},#{coords.last.round(2)}")
      wi.data = fc
      wi.datetime = time
      wi.lat = coords.first
      wi.lon = coords.last
      wi.save
    end
  end
end
