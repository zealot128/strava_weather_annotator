import Vue from 'vue'
import WeatherOutline from 'homepage/WeatherOutline'

document.addEventListener('DOMContentLoaded', () => {
  const elements = document.querySelectorAll('weather-outline')
  elements.forEach(el => {
    const polyline = JSON.parse(el.dataset.polyline)
    new Vue({
      el,
      render: h => h(WeatherOutline, { props: { polyline } })
    })
  })
})

