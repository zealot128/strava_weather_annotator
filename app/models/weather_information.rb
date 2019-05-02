# == Schema Information
#
# Table name: weather_informations
#
#  id         :integer          not null, primary key
#  data       :json
#  datetime   :datetime
#  lat        :float
#  lon        :float
#  offset     :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  trip_id    :integer
#
# Indexes
#
#  index_weather_informations_on_trip_id  (trip_id)
#
# Foreign Keys
#
#  fk_rails_...  (trip_id => trips.id)
#

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
    if data['currently']['precipIntensity'].to_f > 0
      "#{data['currently']['precipIntensity'].round(2)}mm/h"
    end
  end

  def precip_probability
    (data['currently']['precipProbability'].to_f * 100).round
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
    if p
      "#{p.round}hPa <small>(#{(p / standard).round(3)}x Norm)</small>"
    end
  end

  def wind_speed
    s = data['currently']['windSpeed']
    "#{s.round(1)} m/s (#{bft} Bft)"
  end

  def cloud_cover
    s = data['currently']['cloudCover']
    if s
      "#{(s * 100).round}%"
    end
  end

  def bft
    s = data['currently']['windSpeed']
    ((s / 0.8360)**Rational(2, 3)).round
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
    if s = data['currently']['windBearing']
      matrix.min_by { |degree, _| (degree - s).abs }[1]
    end
  end

  def si?
    data['flags']['units'] == 'si'
  end

  def temperature
    unit = si? ? "°C" : "°F"
    real = data['currently']['temperature'].round(1)
    apparent = data['currently']['apparentTemperature'].try(:round, 1)
    if apparent and apparent != real
      "#{real}#{unit} <small>(feel: #{apparent}#{unit})</small>".html_safe
    else
      "#{real}#{unit}"
    end
  end
end
