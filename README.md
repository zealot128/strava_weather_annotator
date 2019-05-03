# Weather annotator for Strava trips

- Connect with your Strava account
- Retrieve weather information for recent trips, Powered by Dark Sky Forecast API
- Annotate your trips with weather information, see wind directions alongside the trip
- Create Heatmap of all trips (Powered by [Derive](https://erik.github.io/derive/))

- visit https://strava-weather.stefanwienert.de for live demo

## Ideas for future development

I have NO plan to make a product or anything out of it. If you just want to know a future trips weather condition go ahead and use Epic Ride Weather.


My research area:

- Phase 1: Based on physics formular make assumption about wind and air resistance difficulty and wattage,
  - Things to factor in: humidity/air pressure/temperature, wind direction and angle, speed
- Phase 2: Try integrating OpenStreetMap data into the mix:
  - Check, if there is: forest, open flat terrain, tunnel, gradient etc. that influences air resistance and wind difficulty
- Phase 3: providing a couple of favorite routes, Try calculating difficulty with current weather conditions and find route that makes most "fun" (less wind in the face, better from behind)


## Used libraries/stuff:

(besides the "usual" stuff, Rails, Webpack, Vue etc.)

- Derive, for Heatmap
- Leaflet
- Strava API
- Dark Sky API
- Wind Barb Leaflet plugin by JoranBeaufort https://github.com/JoranBeaufort/Leaflet.windbarb
- Climacons icons and webfonts
