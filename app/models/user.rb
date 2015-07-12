class User < ActiveRecord::Base
  has_many :trips

  def self.create_with_omniauth(auth)
    create! do |user|
      user.provider = auth['provider']
      user.uid = auth['uid']
      if auth['info']
         user.name = auth['info']['name'] || ""
      end
    end
  end

  def strava_client
    @strava_client ||= Strava::Api::V3::Client.new(:access_token => access_token)
  end

end
