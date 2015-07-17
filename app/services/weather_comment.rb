class WeatherComment
  def initialize(trip)
    @trip = trip
    @wi = trip.weather_informations
  end

  def render
    <<-DOC.strip_heredoc
      Weather summary: #{summary.join('/')}
      Temperature: #{temperature},
      rel.Hum.: #{humidity},
      Wind: #{wind}, #{wind_bearing.join('/')}

      #{@wi.map{|i|i.data['flags']['metno-license']}.uniq.to_sentence}
    DOC
  end

  protected

  def wind
    bfts = @wi.map{|i| i.bft}.uniq.sort
    if bfts.count == 1
      "#{bfts.first} Bft"
    else
      "#{bfts.first}-#{bfts.last} Bft"
    end
  end

  def wind_bearing
    @wi.map(&:wind_bearing).group_by{|a|a}.sort_by{|a,b| -b.count }.map(&:first)
  end

  def humidity
    hums = @wi.map{|i| i.data['currently']['humidity'].round(2)}.uniq.sort
    if hums.count == 1
      "#{(hums.first * 100).round}%"
    else
      "#{(hums.first * 100).round}%-#{(hums.last * 100).round}%"
    end
  end

  def summary
    @wi.map{|i| i.data['currently']['summary']}.uniq
  end

  def temperature
    temperatures = @wi.map{|i| i.data['currently']['temperature'].round}.uniq
    if temperatures.count == 0
      temperatures.first.to_s + "°C"
    else
      "#{temperatures.min}°C to #{temperatures.max}°C"
    end
  end
end
