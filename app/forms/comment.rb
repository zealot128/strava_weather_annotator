class Comment
  include ActiveModel::Model
  attr_accessor :trip, :text


  def fetch_description
    response = user.strava_client.retrieve_an_activity(trip.strava_id)
    user.add_log 'strava', "GET retrieve_an_activity #{trip.strava_id}"
    self.text = response['description']
  end

  def add_weather_information
    weather = WeatherComment.new(trip).render
    weather = "Weather summary for this trip:\n#{weather}"
    if self.text.blank?
      self.text = weather
    else
      self.text += "\n\n" + weather
    end
    self.text += "by http://#{Rails.application.secrets.domain_name}/"
  end

  def user
    trip.user
  end

  def save
    api = user.strava_client
    api.update_an_activity(trip.strava_id, description: text)
    user.add_log 'strava', "PUT update_an_activity #{trip.strava_id}"
  end
end
