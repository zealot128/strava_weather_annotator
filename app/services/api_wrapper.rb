class ApiWrapper
  attr_reader :user
  def initialize(user)
    @user = user
  end

  def fetch_description(trip)
  end

  class ApiWrapper::StravaApiWrapper < ApiWrapper

    def get_activities(after: 8.weeks.ago)
      activities = user.strava_client.list_athlete_activities after: 12.week.ago.to_i, per_page: 100
      log 'GET list_athlete_activities'
      activities
    end

    def fetch_description(trip)
      response = api.retrieve_an_activity(trip.strava_id)
      log "GET retrieve_an_activity #{trip.strava_id}"
      text = response['description']
      trip.description = text
      trip.save
      text
    end

    def update_description(trip, text)
      data = api.update_an_activity(trip.strava_id, description: text)
      log "PUT update_an_activity #{trip.strava_id}"
      trip.description = data['description']
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
