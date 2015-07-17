class CommentsController < ApplicationController
  before_filter :authenticate_user!
  def new
    @comment = Comment.new
    @comment.trip = trip
    @comment.fetch_description
    @comment.add_weather_information
  end

  def create
    @comment = Comment.new(params[:comment])
    @comment.trip = trip
    @comment.save
    redirect_to trip, notice: "Comment updated successfully!"
  end


  protected
  def trip
    @trip ||= current_user.trips.find(params[:trip_id])
  end
end
