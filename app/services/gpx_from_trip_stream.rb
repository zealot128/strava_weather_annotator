class GpxFromTripStream
  def initialize(trip)
    @trip = trip
  end

  def saved_gpx
    unless @trip.gpx_file.attached?
      tf = Tempfile.new(['gpx', '.gpx'])
      tf.write gpx
      tf.flush
      tf.rewind
      @trip.gpx_file.attach(io: tf, filename: 'trip.gpx')
    end
    @trip.gpx_file.blob
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
            next if pt['latlng'].nil?

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
    data = ApiWrapper::StravaApiWrapper.new(@trip.user).activity_streams(@trip.strava_id, 'time,distance,altitude,latlng,heartrate,cadence,temp')

    @trip.user.add_log 'strava', "GET retrieve_activity_streams #{@trip.strava_id}"
    per_point = data.to_h[data.keys.first]['data'].count.times.map { |i| data.transform_values { |v| v['data'][i] } }
    stream = @trip.build_trip_stream(data: per_point)
    stream.save
    stream.data
  rescue StandardError => e
    binding.pry
    []
  end
end
