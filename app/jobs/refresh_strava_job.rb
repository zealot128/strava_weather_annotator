class RefreshStravaJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    refresh = StravaRefresh.new(current_user)
    refresh.get_recent(date: 7.days.ago)
  end
end
