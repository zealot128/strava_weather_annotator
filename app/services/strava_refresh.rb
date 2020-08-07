class StravaRefresh
  attr_reader :user
  def initialize(user)
    @user = user
    @created = 0
    @updated = 0
    @weather = 0
  end

  attr_reader :created, :updated, :weather

  def create_or_update_activity(activity)
    trip = user.trips.where(strava_id: activity['id'].to_s).first_or_initialize
    trip.name = activity['name']
    trip.start_datetime = activity['start_date']
    trip.activity_type = activity['type']
    trip.distance = activity['distance']
    trip.polyline = activity['map']['summary_polyline']
    if trip.new_record?
      @created += 1
    else
      @updated += 1
    end
    trip.save! if trip.changed?
    if trip.start_datetime > 2.weeks.ago and trip.weather_informations.blank?
      trip.update_weather_async
      @weather += 1
    end
    trip
  end

  def get_recent(date: user.api_logs.where(provider: 'strava', title: "GET list_athlete_activities").maximum(:created_at) || 1.month.ago)
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
end
