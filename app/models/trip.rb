class Trip < ActiveRecord::Base
  belongs_to :user
  has_many :weather_informations, dependent: :destroy

  def strava_url
    "https://www.strava.com/activities/#{strava_id}"
  end

  def has_weather_comment?
    description && (
      description.include?('Weather summary') ||
      description.include?('rel.Hum')
    )
  end

  def as_comment
    WeatherComment.new(self).render
  end
end
