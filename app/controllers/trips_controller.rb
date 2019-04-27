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
    blob = GpxFromTripStream.new(@trip).saved_gpx
    redirect_to blob
  end

  def weather
    @trip = current_user.trips.find params[:id]
    if current_user.quota.can_forecast?
      WeatherRefresh.new(@trip).run
      redirect_to @trip
    else
      redirect_to :trips, alert: 'Your daily Forecast Quota is exhausted!'
    end
  end

  def show
    @trip = current_user.trips.find params[:id]
  end

  def refresh
    if current_user.quota.can_strava?
      refresh = StravaRefresh.new(current_user)
      refresh.get_recent(date: 7.days.ago)
      redirect_to :trips, notice: "#{refresh.updated} old and #{refresh.created} new activities found. #{refresh.weather > 0 ? 'Weather information will be added in background' : ''}"
    else
      redirect_to :trips, alert: 'Your daily Strava Quota is exhausted!'
    end
  end
end
