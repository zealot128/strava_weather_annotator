class Trip < ActiveRecord::Base
  belongs_to :user
  has_many :weather_informations, dependent: :destroy

end
