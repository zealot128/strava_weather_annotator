<template>
  <LMap
    ref="map"
    style="overflow: hidden; height: 80vh"
    :zoom="10"
  >
    <LTileLayer
      url="https://tiles.pludoni.de/osm/{z}/{x}/{y}.png"
      :attribution="attribution"
      ></LTileLayer>
    <LPolyline
      ref="gpsPath"
      :lat-lngs="decodedLatPath"
      color="#ff0000"
      />
  </LMap>
</template>

<script>
import Vue from "vue";
import { LMap, LTileLayer, LPolyline } from 'vue2-leaflet';
import L from 'leaflet'

import WHATEVER from './leaflet-windbarb'
import 'leaflet-polylinedecorator'
console.log(WHATEVER)

const googlePolyline = require("@mapbox/polyline");


const components = { LMap, LTileLayer, LPolyline }

const weatherPopup = (weather) => {
  const windKmH = Math.round(weather.data.currently.windSpeed * 3.6)
  return `
    <table>
    <tr>
      <th>Wind Speed:</th>
      <td> ${windKmH} km/h</td>
    </tr>
    <tr>
      <th>Temperature</th>
      <td> ${weather.data.currently.temperature}ºC <br>
      <small>
      Apparent:
      ${weather.data.currently.apparentTemperature}ºC
      </small>

      </td>
    </tr>
    <tr>
      <th>Pressure</th>
      <td> ${weather.data.currently.pressure}hPa</td>
    </tr>
    <tr>
      <th>Humidity</th>
      <td> ${weather.data.currently.humidity * 100}%</td>
    </tr>
    <tr>
      <th>UV-Index (1..12)</th>
      <td> ${weather.data.currently.uvIndex}</td>
    </tr>
    </table>
    `;
}

export default Vue.extend({
  components,
  props: {
    trip: { type: Object, required: true },
    weatherPoints: { type: Array, required: true }
  },
  computed: {
    attribution() {
      return '&copy; OpenStreetMap contributors'
    },
    decodedLatPath() {
      return googlePolyline.decode(this.trip.polyline);
    }
  },
  methods: {
    addWindToMap(map) {
      this.weatherPoints.forEach((weather) => {
        const icon = L.WindBarb.icon({
          lat: weather.lat,
          deg: weather.data.currently.windBearing,
          speed: weather.data.currently.windSpeed * 1.94384,
          pointRadius: 5,
          strokeWidth: 3,
          forceDir: true,
          strokeLength: 20
        });
        const marker = L.marker([weather.lat,weather.lon], {icon}).addTo(map)
          .bindPopup(weatherPopup(weather))
        ;
      })
    },
    addArrowToPath() {
      const map = this.$refs.map.mapObject
      const arrow = this.$refs.gpsPath.mapObject
      L.polylineDecorator(arrow, {
        patterns: [
          {
            repeat: '50px',
            symbol: L.Symbol.arrowHead({pixelSize: 10, headAngle: 30, polygon: false, pathOptions: {stroke: true, color: 'red'}})
          }
        ]
      }).addTo(map);
    }
  },
  mounted() {
    const map = this.$refs.map.mapObject
    map.fitBounds(this.decodedLatPath)

    this.$nextTick(() => this.addArrowToPath())
    this.$nextTick(() => this.addWindToMap(map))
  }
});
</script>
