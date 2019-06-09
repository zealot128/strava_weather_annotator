# == Schema Information
#
# Table name: trips
#
#  id                    :integer          not null, primary key
#  activity_type         :string
#  commented_posted      :boolean
#  date                  :string
#  description           :text
#  distance              :float
#  icon                  :string
#  link                  :string
#  name                  :string
#  polyline              :text
#  start_datetime        :datetime
#  temperature           :string
#  weather_comment_added :boolean          default(FALSE)
#  weather_enqueued_on   :datetime
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  strava_id             :string
#  user_id               :integer
#
# Indexes
#
#  index_trips_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#

class Trip < ActiveRecord::Base
  belongs_to :user
  has_many :weather_informations, dependent: :destroy
  has_one :trip_stream, dependent: :destroy

  has_one_attached :gpx_file

  def strava_url
    "https://www.strava.com/activities/#{strava_id}"
  end

  def update_weather_async
    return if weather_enqueued_on? and weather_enqueued_on > 10.minutes.ago

    update(weather_enqueued_on: Time.zone.now)
    UpdateWeatherJob.perform_later(id)
  end

  def has_weather_comment?
    weather_comment_added || (description && (
      description.include?('Weather summary') ||
      description.include?('rel.Hum')
    ))
  end

  def as_comment
    WeatherComment.new(self).render
  end
end
