class GpxFromTripStream
  def initialize(trip)
    @trip = trip
  end

  def gpx
    require 'builder'
    xml = Builder::XmlMarkup.new
    xml.gpx(
      creator: "StravaGPX",
      'xmlns:xsi' => "http://www.w3.org/2001/XMLSchema-instance",
      'xsi:schemaLocation' => "http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd http://www.garmin.com/xmlschemas/GpxExtensions/v3 http://www.garmin.com/xmlschemas/GpxExtensionsv3.xsd http://www.garmin.com/xmlschemas/TrackPointExtension/v1 http://www.garmin.com/xmlschemas/TrackPointExtensionv1.xsd",
      version: "1.1",
      xmlns: "http://www.topografix.com/GPX/1/1",
      'xmlns:gpxtpx' => "http://www.garmin.com/xmlschemas/TrackPointExtension/v1",
      'xmlns:gpxx' => "http://www.garmin.com/xmlschemas/GpxExtensions/v3"
    ) do
      xml.metadata do
        xml.time do
          @trip.start_datetime.utc.iso8601
        end
      end
      xml.trk do
        xml.name @trip.name
        xml.type 1
        xml.trkseg do
          point_data.each do |pt|
            xml.trkpt(lat: pt['latlng'][0], lon: pt['latlng'][1]) do
              xml.ele pt['altitude']
              xml.time((@trip.start_datetime + pt['time'].seconds).utc.iso8601)
              xml.extensions do
                xml.tag!('gpxtpx:TrackPointExtension') do
                  xml.tag!('gpxtpx:atemp', pt['temp']) if pt['temp']
                  xml.tag!('gpxtpx:hr', pt['heartrate']) if pt['heartrate']
                  xml.tag!('gpxtpx:cad', pt['cadence']) if pt['cadence']
                end
              end
            end
          end
        end
      end
    end
    xml.target!
  end

  def point_data
    @trip.trip_stream&.data || download_stream_data
  end

  def download_stream_data
    data = @trip.user.strava_client.retrieve_activity_streams(@trip.strava_id, 'time,distance,altitude,latlng,heartrate,cadence,temp')
    per_point = data.first['data'].count.times.map { |i| data.map { |j| [j['type'], j['data'][i]] }.to_h }
    stream = @trip.build_trip_stream(data: per_point)
    stream.save
    stream.data
  rescue Strava::Api::V3::ClientError
    []
  end
end
