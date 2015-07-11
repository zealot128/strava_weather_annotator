class TripsController < ApplicationController
  before_filter :authenticate_user!

  def index
  end

  def show
  end

  def refresh
    Trip.refresh(current_user)
    redirect_to :trips
  end

end
