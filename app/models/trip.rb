class Trip < ActiveRecord::Base
  belongs_to :user


  def self.refresh(user)

  end
end
