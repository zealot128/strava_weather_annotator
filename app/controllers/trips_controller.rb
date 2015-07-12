class TripsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @trips = current_user.trips.order('date desc')
  end

  def show
  end

  def refresh
    Trip.refresh(current_user)
    redirect_to :trips
  end

end
