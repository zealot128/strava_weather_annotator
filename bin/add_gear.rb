# update all activities after to a date to bike
user = User.first
api = user.strava_client
response = api.retrieve_current_athlete
primary_bike = response['bikes'].find{|i| i['primary'] }

if primary_bike.blank?
  raise ArgumentError.new("No Primary Bike given")
end

from_date = Date.parse('2012-03-22').to_time
activities = api.list_athlete_activities after: from_date.to_i, per_page: 200
if activities.blank?
  raise ArgumentError.new("activities empty")
end

activities.each do |activity|
  next if activity['gear_id']
  next if activity['type'] != 'Ride'
  api.update_an_activity activity['id'], gear_id: primary_bike['id']
  puts "Updated #{activity['id']}"
end


