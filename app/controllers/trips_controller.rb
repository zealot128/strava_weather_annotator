class TripsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @trips = current_user.trips.order('date desc')
  end

  def show
    @trip = current_user.trips.find params[:id]
  end

  def refresh
    StravaRefresh.new(current_user).run
    redirect_to :trips
  end

end
