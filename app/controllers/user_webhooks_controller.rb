class UserWebhooksController < SignedInController
  def create
    Webhooks.new.create_subscription(current_user)
    redirect_to '/user/edit', notice: "Subscription added."
  end

  def destroy
    Webhooks.new.delete_subscription(current_user)
    redirect_to '/user/edit', notice: "Subscription removed."
  end
end
