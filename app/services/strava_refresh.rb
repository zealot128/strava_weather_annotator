class StravaRefresh
  attr_reader :user
  def initialize(user)
    @user = user
  end

  def run
    activities = user.strava_client.list_athlete_activities after: 1.week.ago.to_i
    activities.each do |activity|
      trip = user.trips.where(strava_id: activity['id'].to_s).first_or_initialize
      trip.name = activity['name']
      trip.start_datetime = Time.zone.parse( activity['start_date'])
      trip.activity_type = activity['type']
      trip.distance = activity['distance']
      trip.polyline = activity['map']['summary_polyline']
      trip.save!
      update_weather(trip)
    end
  end

  def update_weather(trip)
    response = user.strava_client.retrieve_activity_streams(trip.strava_id, 'latlng,time')

    positions = response.find{|i| i['type'] == 'latlng' }['data']
    time_offsets = response.find{|i| i['type'] == 'time' }['data']

    both = time_offsets.zip(positions)
    samples = both.in_groups_of( 30.minutes ).map{|i| i.first }
    base = trip.start_datetime
    samples.each do |offset, coords|
      time = base + offset
      wi = trip.weather_informations.where(offset: offset).first_or_initialize
      if wi.new_record?
        fc = ForecastIO.forecast(coords.first, coords.last,
                                 time: time.to_i,
                                 params: {
                                   units: 'si',
                                   exclude: 'minutely,hourly,daily'})
        wi.data = fc
        wi.datetime = time
        wi.lat = coords.first
        wi.lon = coords.last
        wi.save
      end
    end
  end
end
