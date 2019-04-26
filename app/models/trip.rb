class Trip < ActiveRecord::Base
  belongs_to :user
  has_many :weather_informations, dependent: :destroy
  has_one :trip_stream

  has_one_attached :original_route_file
  has_one_attached :converted_gpx_file

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
