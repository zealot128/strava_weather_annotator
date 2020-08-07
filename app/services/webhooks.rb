class Webhooks
  def client
    @client ||= Strava::Webhooks::Client.new(
      client_id: Rails.application.secrets.strava_client_id,
      client_secret: Rails.application.secrets.strava_api_key
    )
  end

  def create_subscription(user)
    subscription = client.create_push_subscription(
      callback_url: "https://strava-weather.stefanwienert.de/webhook/#{user.uid}",
      verify_token: Digest::MD5.hexdigest(Rails.application.secrets.strava_client_id)
    )
    user.update_column(:strava_webhook_id, subscription.id)
  end

  def delete_subscription(user)
    client.delete_push_subscription(user.strava_webhook_id.to_i)
    user.update_column(:strava_webhook_id, nil)
  end
end
