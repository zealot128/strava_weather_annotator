class Trip < ActiveRecord::Base
  belongs_to :user
  has_many :weather_informations, dependent: :destroy

  def strava_url
    "https://www.strava.com/activities/#{strava_id}"
  end

  def as_comment
    WeatherComment.new(self).render
  end
end
