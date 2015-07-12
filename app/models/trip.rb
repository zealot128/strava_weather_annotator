class Trip < ActiveRecord::Base
  belongs_to :user
  has_many :weather_informations

  def self.refresh(user)
    activities = user.strava_client.list_athlete_activities after: 1.week.ago.to_i
    activities.each do |activity|
      trip = user.trips.where(strava_id: activity['id'].to_s).first_or_initialize
      trip.name = activity['name']
      trip.date = Time.zone.parse( activity['start_date'])
      trip.activity_type = activity['type']
      trip.distance = activity['distance']
      trip.polyline = activity['map']['summary_polyline']
      trip.save!
    end
  end


  def update_weather
    response = user.strava_client.retrieve_activity_streams(strava_id, 'latlng,time')

    positions = response.find{|i| i['type'] == 'latlng' }['data']
    time_offsets = response.find{|i| i['type'] == 'time' }['data']

    both = time_offsets.zip(positions)
    samples = both.in_groups_of( 30.minutes ).map{|i| i.first }
    base = Time.parse(date)
    samples.each do |offset, coords|
      time = base + offset
      wi = self.weather_informations.where(offset: offset).first_or_initialize
      if wi.new_record?
        fc = ForecastIO.forecast(coords.first, coords.last, time: time.to_i, params: { units: 'auto', exclude: 'minutely,hourly,daily'})
        wi.data = fc
        wi.datetime = time
        wi.lat = coords.first
        wi.lon = coords.last
        wi.save
      end
    end
  end
end
