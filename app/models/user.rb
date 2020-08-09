# == Schema Information
#
# Table name: users
#
#  id                      :integer          not null, primary key
#  access_token            :string
#  access_token_expires_at :datetime
#  name                    :string
#  profile_picture_url     :string
#  provider                :string
#  refresh_token           :string
#  uid                     :string
#  weather_template        :text
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  strava_webhook_id       :string
#

class User < ActiveRecord::Base
  has_many :trips, dependent: :destroy
  has_many :api_logs, dependent: :destroy
  has_many :strava_webhook_events, dependent: :destroy

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
      {{summary-icon}}
      {%- if true %}🌡️{{temperature}} {% endif %}
      {%- if true %}🌬️ {{wind}}bft{{bearing-arrow}} {%- endif %}
      {%- if resistance < 100 || resistance > 101 %}{{resistance}}% Resistance{%- endif %}

      Pressure: {{pressure | divided_by: 1000.0 | round: 1}}bar
      Humidity: {{humidity}}%
      Conditions: {{summary}}
    DOC
  end

  def quota
    @quota ||= ApiAllowance.new(self)
  end

  def add_log(provider, title)
    api_logs.create(provider: provider, title: title, date: Time.zone.now)
  end

  def strava_client
    if access_token_expires_at && access_token_expires_at.past?
      refresh_token!
    end
    @strava_client ||= Strava::Api::Client.new(access_token: access_token)
  end

  def refresh_token!
    client = Strava::OAuth::Client.new(
      client_id: Rails.application.secrets.strava_client_id,
      client_secret: Rails.application.secrets.strava_api_key
    )
    response = client.oauth_token(
      refresh_token: refresh_token,
      grant_type: 'refresh_token'
    )
    @strava_client = nil
    self.refresh_token = response.refresh_token
    self.access_token = response.access_token
    self.access_token_expires_at = response.expires_at
    save(validate: false)
  end
end
