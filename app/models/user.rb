# == Schema Information
#
# Table name: users
#
#  id                  :integer          not null, primary key
#  access_token        :string
#  name                :string
#  profile_picture_url :string
#  provider            :string
#  uid                 :string
#  weather_template    :text
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

class User < ActiveRecord::Base
  has_many :trips, dependent: :destroy
  has_many :api_logs, dependent: :destroy

  def self.create_with_omniauth(auth)
    create! do |user|
      user.provider = auth['provider']
      user.weather_template = self.class.default_weather_template
      user.uid = auth['uid']
      if auth['info']
        user.name = auth['info']['name'] || ""
      end
    end
  end

  def self.default_weather_template
    <<-DOC.strip_heredoc
      {{summary}}
      🌡️{{temperature}} – 💧Hum {{humidity}} – 🌬️ {{wind}}  {{bearing}} – {{rain}}
    DOC
  end

  def quota
    @quota ||= ApiAllowance.new(self)
  end

  def add_log(provider, title)
    api_logs.create(provider: provider, title: title, date: Time.zone.now)
  end

  def strava_client
    @strava_client ||= Strava::Api::V3::Client.new(access_token: access_token)
  end
end
