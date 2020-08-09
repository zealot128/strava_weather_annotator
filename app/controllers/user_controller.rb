class UserController < SignedInController
  def edit
    @user = current_user
    @user.weather_template ||= @user.class.default_weather_template
  end

  def update
    @user = current_user
    @user.update(params.require(:user).permit(:weather_template))
    redirect_to '/', notice: "Update complete."
  end

  def preview
    current_user.weather_template = params[:weather_template]
    trip = current_user.
      trips.
      joins(:weather_informations).
      group(:id).
      order(Arel.sql('random()')).
      first || Trip.order(Arel.sql('random()')).joins(:weather_informations).group(:id).first
    render json: {
      comment: WeatherComment.new(trip).render
    }
  end
end
