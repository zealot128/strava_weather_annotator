class WeatherInformation < ActiveRecord::Base
  belongs_to :trip


  def image_classes
    case data['currently']['icon']
    when 'clear-day' then 'sun'
    when 'clear-night' then 'moon'
    when 'rain' then 'rain'
    when 'snow' then 'snow'
    when 'sleet' then 'sleet'
    when 'wind' then 'wind'
    when 'fog' then 'fog'
    when 'cloudy' then 'cloud'
    when 'partly-cloudy-day' then 'sun cloud'
    when 'partly-cloudy-night' then 'moon cloud'
    else data['currently']['icon']
    end
  end

  def precip_intensity
    if data['currently']['precipIntensity'] > 0
      "#{data['currently']['precipIntensity'].round(2)}mm/h"
    end
  end

  def precip_probability
    (data['currently']['precipProbability'] * 100).round
  end

  def humidity
    "#{(data['currently']['humidity'] * 100).round}% (rel.)"
  end

  def summary
    data['currently']['Summary']
  end

  def pressure
    standard = 1013.25
    p = data['currently']['pressure']
    "#{(p).round}hPa <small>(#{ (p / standard).round(3)}x Norm)</small>"
  end

  def wind_speed
    s = data['currently']['windSpeed']
    "#{s.round(1)} m/s (#{bft} Bft)"
  end

  def bft
    s = data['currently']['windSpeed']
    ((s / 0.8360 )**(Rational(2,3))).round
  end

  def wind_bearing
    matrix = [
      [0, 'N'],
      [45, 'NE'],
      [90, 'E'],
      [135, 'SE'],
      [180, 'S'],
      [225, 'SW'],
      [270, 'W'],
      [315, 'NW'],
      [360, 'N'],
    ]
    if s=data['currently']['windBearing']
      matrix.sort_by{|degree, _| (degree - s).abs }.first[1]
    end
  end

  def si?
    data['flags']['units'] == 'si'
  end

  def temperature
    unit = si? ? "°C" : "°F"
    data['currently']['temperature'].round(1).to_s + unit
  end
end
