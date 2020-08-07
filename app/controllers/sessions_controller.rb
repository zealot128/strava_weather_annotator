class SessionsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:create, :backdoor]

  def new
    redirect_to '/auth/strava'
  end

  def create
    auth = request.env["omniauth.auth"]
    user = User.where(provider: auth['provider'],
                      uid: auth['uid'].to_s).first || User.create_with_omniauth(auth)
    user.profile_picture_url = auth.extra.raw_info.profile_medium
    user.access_token = auth.credentials.token
    user.refresh_token = auth.credentials.refresh_token
    user.save if user.changed?
    reset_session
    session[:user_id] = user.id
    if user.created_at > 5.minutes.ago
      InitialImportJob.perform_later(user.id)
      redirect_to trips_url, notice: 'Signed in! All Trips will be imported in the background.'
    else
      redirect_to trips_url, notice: 'Signed in! All recent trips since last login will be imported.'
    end
  end

  def destroy
    reset_session
    redirect_to root_url, notice: 'Signed out!'
  end

  def failure
    redirect_to root_url, alert: "Authentication error: #{params[:message].humanize}"
  end

  def backdoor
    raise unless Rails.env.development?

    user = User.first!
    session[:user_id] = user.id
    redirect_to trips_url, notice: 'Signed in! All recent trips since last login will be imported.'
  end
end
