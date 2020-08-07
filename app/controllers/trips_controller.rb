class TripsController < SignedInController
  include Pagy::Backend
  helper Pagy::Frontend

  def index
    @pagy, @trips = pagy current_user.trips.order('start_datetime desc')

    @api_allowance = ApiAllowance.new current_user
    last_refresh = current_user.api_logs.where(provider: 'strava').order('created_at desc').where(title: 'GET list_athlete_activities').maximum(:created_at)
    if last_refresh < 6.hours.ago and @api_allowance.can_strava?
      flash.now[:notice] = "Welcome back! your trips are refreshed in Background. Please refresh soon"
      UpdateImportJob.perform_later(current_user.id)
    end
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
    @weather = @trip.weather_informations.order('datetime').group_by(&:datetime).values.map(&:first)
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
