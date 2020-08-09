class WeatherComment
  def initialize(trip)
    @trip = trip
    @wi = trip.weather_informations
  end

  def render(template: @trip.user.weather_template || User.default_weather_template)
    output = Liquid::Template.parse(template).render(parameters.stringify_keys, filters: [])
    license = @wi.map { |i| i.data['flags']['metno-license'] }.uniq.to_sentence
    "#{output}\n\n#{license}".strip
  end

  def parameters
    {
      summary: -> { @wi.map { |i| i.data['currently']['summary'] }.uniq },
      "summary-icon": -> {
        s = @wi.map { |i| i.data['currently']['icon'] }.group_by { |i| i }.sort_by { |_,b| -b.length }.first[0]
        case s
        when 'clear-day' then '🌞'
        when 'clear-night' then '🌃🌙'
        when 'rain' then '🌧️'
        when 'snow' then '🌨️'
        when 'sleet' then '🌨️'
        when 'wind' then ' 🌬️'
        when 'fog' then '🌁'
        when 'cloudy' then '⛅'
        when 'partly-cloudy-day' then '⛅'
        when 'partly-cloudy-night' then '🌑'
        end
      },
      temperature: -> { temperature },
      humidity: -> { humidity },
      pressure: -> {
        hpa = mean(@wi.map { |i| i.data['currently']['pressure'] })
        hpa.round
      },
      wind: -> { wind },
      bearing: -> { wind_bearing.take(3).join('/') },
      "bearing-arrow": -> {
        bearings = wind_bearing.take(3)
        bearings.map { |dir|
          case dir
          when "N" then "↑"
          when "NE" then "↗"
          when "E" then "→ "
          when "SE" then "↘"
          when "S" then "↓"
          when "SW" then "↙"
          when "W" then "← "
          when "NW" then "↖"
          else
            ""
          end
        }.join("")
      },
      resistance: -> {
        m = mean(@wi.map { |i| i.density_of_air[:difficulty] })
        (m * 100).round
      },
      rain: -> {
        if rain
          "☔#{rain}"
        end
      }
    }
  end

  def wind
    bfts = @wi.map(&:bft).uniq.sort
    if bfts.count == 1
      "#{bfts.first}"
    else
      "#{bfts.first}-#{bfts.last}"
    end
  end

  def rain
    per_datapoint = @wi.map { |i| i.data['currently']['precipIntensity'] }.compact
    return nil if per_datapoint.length == 0 || per_datapoint.uniq == [0]

    rain = per_datapoint.max
    "#{rain.round(2)}mm/h"
  end

  def wind_bearing
    @wi.map(&:wind_bearing).group_by { |a| a }.sort_by { |_a, b| -b.count }.map(&:first)
  end

  def humidity
    hums = @wi.map { |i| i.data['currently']['humidity'].round(2) }.uniq.sort
    if hums.count == 0
      ""
    elsif hums.count == 1
      (hums.first * 100).round
    else
      (mean(hums) * 100).round
    end
  end

  def summary
    @wi.map { |i| i.data['currently']['summary'] }.uniq
  end

  def temperature
    temperatures = @wi.map { |i| i.data['currently']['temperature'].round }.map(&:round).uniq
    if temperatures.count == 0 || temperatures.min == temperatures.max
      temperatures.first.to_s + "°C"
    elsif temperatures.min + 2 >= temperatures.max
      (temperatures.sum / temperatures.count).round
    else
      "#{temperatures.min}-#{temperatures.max}°C"
    end
  end

  def mean(array)
    return 0 if array.length == 0

    array.sum.to_f / array.length
  end
end
