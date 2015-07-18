class Comment
  include ActiveModel::Model
  attr_accessor :trip, :text


  def fetch_description
    ApiWrapper::StravaApiWrapper.new(user).fetch_description(trip)
    self.text = trip.description
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
    ApiWrapper::StravaApiWrapper.new(user).update_description(trip, text)
  end
end
