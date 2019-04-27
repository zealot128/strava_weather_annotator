class Comment
  include ActiveModel::Model
  attr_accessor :trip, :text, :name
  delegate :user, to: :trip

  def fetch_description
    ApiWrapper::StravaApiWrapper.new(user).fetch_description(trip)
    self.text = trip.description
    self.name = trip.name
  end

  def add_weather_information
    weather = WeatherComment.new(trip).render
    if text.blank?
      self.text = weather
    else
      self.text += "\n\n" + weather
    end
    self.text += "Weather summary powered by http://#{Rails.application.secrets.domain_name}/ + Dark Sky"
  end

  def save
    ApiWrapper::StravaApiWrapper.new(user).update_description(trip, text, name)
    trip.update(weather_comment_added: true)
  end
end
