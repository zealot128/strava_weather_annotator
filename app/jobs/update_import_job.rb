class UpdateImportJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    StravaRefresh.new(User.find(user_id)).get_recent
  end
end
