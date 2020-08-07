class ApiWrapper
  attr_reader :user
  def initialize(user)
    @user = user
  end

  def fetch_description(trip)
  end

  class ApiWrapper::StravaApiWrapper < ApiWrapper
    def activity_streams(trip_id, keys)
      log "GET activity"
      api.activity_streams(trip_id, keys: keys)
    end

    def get_activities(after: 8.weeks.ago, page: 1)
      activities = api.athlete_activities(after: after, per_page: 100, page: page)
      log 'GET list_athlete_activities'
      activities
    end

    def fetch_description(trip)
      response = api.activity(trip.strava_id)
      log "GET retrieve_an_activity #{trip.strava_id}"
      trip.description = response['description']
      trip.name = response['name']
      trip.save if trip.changed?
      trip.description
    end

    def update_description(trip, text, name)
      data = api.update_activity(id: trip.strava_id, description: text, name: name)
      log "PUT update_an_activity #{trip.strava_id}"
      trip.description = data['description']
      trip.name = data['name']
      trip.save
    end

    protected

    def api
      user.strava_client
    end

    def log(msg)
      user.add_log 'strava', msg
    end
  end
end
