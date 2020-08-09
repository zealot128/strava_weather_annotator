class ApiWrapper
  attr_reader :user
  def initialize(user)
    @user = user
  end

  class ApiWrapper::StravaApiWrapper < ApiWrapper
    def activity_streams(trip_id, keys)
      log "GET activity"
      call_api(:activity_streams, trip_id, keys: keys)
    rescue Faraday::ResourceNotFound
      []
    rescue Strava::Errors::Fault
      @user.refresh_token!
      activity_streams(trip_id, keys)
    end

    def get_activities(after: 8.weeks.ago, page: 1)
      activities = call_api(:athlete_activities, after: after, per_page: 100, page: page)
      log 'GET list_athlete_activities'
      activities
    rescue Strava::Errors::Fault
      @user.refresh_token!
      get_activities(after: after, page: page)
    end

    def fetch_description(trip)
      response = call_api(:activity, trip.strava_id)
      log "GET retrieve_an_activity #{trip.strava_id}"
      trip.description = response['description']
      trip.name = response['name']
      trip.save if trip.changed?
      trip.description
    end

    def update_description(trip, text, name)
      data = call_api(:update_activity, id: trip.strava_id, description: text, name: name)
      log "PUT update_an_activity #{trip.strava_id}"
      trip.description = data['description']
      trip.name = data['name']
      trip.save
    end

    protected

    def api
      user.strava_client
    end

    def call_api(api_method, *args)
      api.send(api_method, *args)
    rescue Strava::Errors::Fault
      @user.refresh_token!
      api.send(api_method, *args)
    end

    def log(msg)
      user.add_log 'strava', msg
    end
  end
end
