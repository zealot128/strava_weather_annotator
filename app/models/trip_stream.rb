# == Schema Information
#
# Table name: trip_streams
#
#  id         :bigint           not null, primary key
#  data       :json
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  trip_id    :bigint
#
# Indexes
#
#  index_trip_streams_on_trip_id  (trip_id)
#
# Foreign Keys
#
#  fk_rails_...  (trip_id => trips.id)
#

class TripStream < ActiveRecord::Base
  belongs_to :trip
end
