class TripsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @trips = current_user.trips.order('start_datetime desc')

    @api_allowance = ApiAllowance.new current_user
  end

  def show
    @trip = current_user.trips.find params[:id]
  end

  def refresh
    if current_user.quota.can_strava?
      StravaRefresh.new(current_user).run
      redirect_to :trips
    else
      redirect_to :trips, alert: 'Your daily Strava Quota is exhausted!'
    end
  end

end
