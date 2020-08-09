class WebhookController < ApplicationController
  skip_before_action :verify_authenticity_token

  def challenge
    challenge = Strava::Webhooks::Models::Challenge.new(params.permit!.to_h.except('user_id', :user_id))
    render json: challenge.response.as_json
  end

  def callback
    user = User.find_by(uid: params[:user_id])
    Rails.logger.info("WEBHOOK: #{request.body}")
    File.write("tmp/#{Digest::MD5.hexdigest(request.body)}.webhook", request.body)
    event = Strava::Webhooks::Models::Event.new(JSON.parse(request.body))
    ev = StravaWebhookEvent.new(user: user)
    ev.assign_attributes(event.to_h)
    ev.save!

    render json: {
      ok: true
    }
  end
end
