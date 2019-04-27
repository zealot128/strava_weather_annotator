class WeatherComment
  def initialize(trip)
    @trip = trip
    @wi = trip.weather_informations
  end

  def render
    tp = @trip.user.weather_template || User.default_weather_template
    license = @wi.map { |i| i.data['flags']['metno-license'] }.uniq.to_sentence
    tp.gsub(/{{([^{]+)}}/) do |_|
      case $1
      when 'summary' then summary.join(', ')
      when 'temperature' then temperature
      when 'humidity' then humidity
      when 'wind' then wind
      when 'bearing' then wind_bearing.join('/')
      when 'rain'
        if rain
          "☔#{rain}"
        end
      else
        ""
      end
    end + "\n\n" + license
  end

  def wind
    bfts = @wi.map(&:bft).uniq.sort
    if bfts.count == 1
      "#{bfts.first} Bft"
    else
      "#{bfts.first}-#{bfts.last} Bft"
    end
  end

  def rain
    per_datapoint = @wi.map { |i| i.data['currently']['precipIntensity'] }.compact
    return nil if per_datapoint.length == 0 || per_datapoint.uniq == [0]

    rain = per_datapoint.max
    "#{rain}mm/h"
  end

  def wind_bearing
    @wi.map(&:wind_bearing).group_by { |a| a }.sort_by { |_a, b| -b.count }.map(&:first)
  end

  def humidity
    hums = @wi.map { |i| i.data['currently']['humidity'].round(2) }.uniq.sort
    if hums.count == 0
      ""
    elsif hums.count == 1
      "#{(hums.first * 100).round}%"
    else
      mean = (hums.sum.to_f / hums.length) * 100
      "#{mean.round}%"
    end
  end

  def summary
    @wi.map { |i| i.data['currently']['summary'] }.uniq
  end

  def temperature
    temperatures = @wi.map { |i| i.data['currently']['temperature'].round }.map(&:round).uniq
    if temperatures.count == 0 || temperatures.min == temperatures.max
      temperatures.first.to_s + "°C"
    else
      "#{temperatures.min}-#{temperatures.max}°C"
    end
  end
end
