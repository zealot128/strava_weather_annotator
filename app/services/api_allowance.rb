class ApiAllowance
  attr_reader :user
  def initialize(user)
    @user = user
  end

  def strava_api_calls
    user.api_logs.strava.last_day.count
  end

  def forecast_calls
    user.api_logs.forecast.last_day.count
  end

  def max_strava_calls
    25000 / (User.count + 1)
  end

  def max_forecast_calls
    1000 / (User.count + 1)
  end

  def can_strava?
    strava_api_calls < max_strava_calls
  end

  def can_forecast?
    forecast_calls < max_forecast_calls
  end
end
