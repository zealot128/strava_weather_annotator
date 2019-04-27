# == Schema Information
#
# Table name: api_logs
#
#  id         :integer          not null, primary key
#  date       :date
#  provider   :string
#  title      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :integer
#
# Indexes
#
#  index_api_logs_on_user_id_and_date_and_provider  (user_id,date,provider)
#

class ApiLog < ActiveRecord::Base
  belongs_to :user

  scope :strava, -> { where(provider: 'strava') }
  scope :forecast, -> { where(provider: 'forecast') }
  scope :last_day, -> { where('date > ?', 1.day.ago) }
end
