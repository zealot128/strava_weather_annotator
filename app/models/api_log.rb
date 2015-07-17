class ApiLog < ActiveRecord::Base
  belongs_to :user

  scope :strava, -> { where(provider: 'strava') }
  scope :forecast, -> { where(provider: 'forecast') }
  scope :last_day, -> { where('date > ?', 1.day.ago) }
end
