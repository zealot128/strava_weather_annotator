import axios from 'axios'
import {parser, extractGPXTracks } from 'derive/track'

export const extractAndAddGPXFromUrl = (url) => new Promise((resolve, reject) => {
    axios.get(url).then(r => {
      parser.parseString(r.data, (err, result) => {
        if (err) {
          reject(err);
        } else if (result.gpx) {
          resolve(extractGPXTracks(result.gpx)[0]);
        } else {
          reject(new Error('Invalid file type.'));
        }
      });
    })
  })

export function addAllTripsToMap(tripIds, map, helpModal) {
  if (tripIds && tripIds.length > 0) {
    const allPromises = tripIds.map(t => {
      return extractAndAddGPXFromUrl(`/trips/${t}/gpx.xml`).then(track => {
        try {
          map.addTrack(track);
        } catch(e) {
          console.log("SKIP")
        }
      }).catch((e) => {
        console.log("ERROR CATCHED");
        return Promise.resolve(123)
      })
    })
    Promise.all(allPromises).then(() => {
      console.log('finished loading')
      map.center()
      map.map.setZoom(10)
      map.map.invalidateSize()
      helpModal.close()
      window.map = map
    })
  }
}
