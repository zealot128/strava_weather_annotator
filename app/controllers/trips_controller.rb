class TripsController < ApplicationController
  before_action :authenticate_user!

  def index
    @trips = current_user.trips.order('start_datetime desc')

    @api_allowance = ApiAllowance.new current_user
  end

  def heatmap
    @trips = current_user.trips.pluck(:id)
    render layout: false
  end

  def gpx
    @trip = current_user.trips.find params[:id]
    xml = GpxFromTripStream.new(@trip).gpx
    render xml: xml
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
