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
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

class User < ActiveRecord::Base
  has_many :trips
  has_many :api_logs

  def self.create_with_omniauth(auth)
    create! do |user|
      user.provider = auth['provider']
      user.uid = auth['uid']
      if auth['info']
         user.name = auth['info']['name'] || ""
      end
    end
  end

  def quota
    @quota ||= ApiAllowance.new(self)
  end

  def add_log(provider, title)
    self.api_logs.create(provider: provider, title: title, date: Time.now)
  end

  def strava_client
    @strava_client ||= Strava::Api::V3::Client.new(:access_token => access_token)
  end

end
