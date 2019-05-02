import automount from 'utils/automount'
import WeatherOutline from 'homepage/WeatherOutline'
import DetailsMap from 'homepage/DetailsMap'

import 'utils/leaflet'

document.addEventListener('DOMContentLoaded', () => {
  automount('weather-outline', WeatherOutline, ['polyline'])
  automount('details-map', DetailsMap, ['trip', 'weatherPoints'])
})

