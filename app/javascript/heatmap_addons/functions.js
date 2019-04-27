import axios from 'axios'
import {parser, extractGPXTracks } from 'derive/track'

export const extractAndAddGPXFromUrl = (url) => new Promise((resolve, reject) => {
    axios.get(url).then(r => {
      parser.parseString(r.data, (err, result) => {
        if (err) {
          reject(err);
        } else if (result.gpx) {
          try {
            resolve(extractGPXTracks(result.gpx)[0]);
          } catch(e) {
            reject(e)
          }
        } else {
          reject(new Error('Invalid file type.'));
        }
      });
    })
  })

const pLimit = require('p-limit');

export function addAllTripsToMap(tripIds, map, helpModal) {
  const progress = document.getElementById('progress')
  progress.max = tripIds.length
  document.getElementById('progress-help-text').innerHTML = `Importing GPX files from ${tripIds.length} trips. This can take a while, especially, if run first time - Then we must download the whole data from Strava.`
  const limit = pLimit(5);

  if (tripIds && tripIds.length === 0) {
    return
  }
  const extractTripAndAddToMapPromise = (trip) => {
    return extractAndAddGPXFromUrl(`/trips/${trip}/gpx.xml`).
      then(track => {
        progress.value += 1
        if (progress.value % 10 === 0) {
          map.center()
        }
        try {
          return map.addTrack(track)
        } catch(e) {
          return Promise.resolve(true)
        }
      }).
      catch(e => {
        progress.value += 1
        return Promise.resolve(true)
      })
  }

  const allPromises = tripIds.map(t => {
    return limit(() => extractTripAndAddToMapPromise(t) )
  })

  Promise.all(allPromises).then(() => {
    console.log('finished loading')
    map.center()
    map.map.invalidateSize()
    helpModal.close()
  })
}
