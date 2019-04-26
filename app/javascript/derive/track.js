// This file is adapted from taterbase/gpx-parser
//
// https://github.com/taterbase/gpx-parser

import xml2js from 'xml2js';
import EasyFit from 'easy-fit';
import Pako from 'pako';

export const parser = new xml2js.Parser();


export function extractGPXTracks(gpx) {
    if (!gpx.trk) {
        console.log('GPX file has no tracks!', gpx);
        throw new Error('Unexpected gpx file format.');
    }

    const parsedTracks = [];

    gpx.trk.forEach(trk => {
        const name = trk.name && trk.name.length > 0 ? trk.name[0] : 'untitled';

        trk.trkseg.forEach(trkseg => {
            const points = trkseg.trkpt.map(trkpt => {return {
                lat: parseFloat(trkpt.$.lat),
                lng: parseFloat(trkpt.$.lon),
                // These are available to us, but are currently unused
                // elev: parseFloat(trkpt.ele) || 0,
                // time: new Date(trkpt.time || '0')
            }});

            parsedTracks.push({points, name});
        });
    });

    return parsedTracks;
}

function extractTCXTracks(tcx, name) {
    if (!tcx.Activities) {
        console.log('TCX file has no activities!', tcx);
        throw new Error('Unexpected tcx file format.');
    }

    const parsedTracks = [];

    for (const act of tcx.Activities[0].Activity) {
        for (const lap of act.Lap) {
            const points = lap.Track[0].Trackpoint
                .filter(trkpt => trkpt.Position)
                .map(trkpt => {return {
                    lat: parseFloat(trkpt.Position[0].LatitudeDegrees[0]),
                    lng: parseFloat(trkpt.Position[0].LongitudeDegrees[0]),
                    // These are available to us, but are currently unused
                    // elev: parseFloat(trkpt.ElevationMeters[0]) || 0,
                    // time: new Date(trkpt.Time[0] || '0')
                }});

            parsedTracks.push({points, name});
        }
    }

    return parsedTracks;
}

function extractFITTracks(fit, name) {
    if (!fit.records || fit.records.length === 0) {
        console.log('FIT file has no records!', fit);
        throw new Error('Unexpected FIT file format.');
    }

    const points = [];
    for (const record of fit.records) {
        if (record.position_lat && record.position_long) {
            points.push({
                lat: record.position_lat,
                lng: record.position_long,
                // Other available fields: timestamp, distance, altitude, speed, heart_rate
            });
        }
    }


    return [{points, name}];
}


function readFile(file, encoding, isGzipped) {
    return new Promise((resolve, reject) => {
        const reader = new FileReader();
        reader.onload = (e) => {
            const {result} = e.target;
            try {
                return resolve(isGzipped ? Pako.inflate(result) : result);
            } catch (e) {
                return reject(e);
            }
        };

        if (encoding === 'binary') {
            reader.readAsArrayBuffer(file);
        } else {
            reader.readAsText(file);
        }
    });
}

export function extractTracks(file) {
    const isGzipped = /\.gz$/i.test(file.name);
    const strippedName = file.name.replace(/\.gz$/i, '');
    const format = strippedName.split('.').pop().toLowerCase();

    switch (format) {
    case 'gpx':
    case 'tcx': /* Handle XML based file formats the same way */

        return readFile(file, 'text', isGzipped)
            .then(textContents => new Promise((resolve, reject) => {
                parser.parseString(textContents, (err, result) => {
                    if (err) {
                        reject(err);
                    } else if (result.gpx) {
                        resolve(extractGPXTracks(result.gpx));
                    } else if (result.TrainingCenterDatabase) {
                        resolve(extractTCXTracks(result.TrainingCenterDatabase, strippedName));
                    } else {
                        reject(new Error('Invalid file type.'));
                    }
                });
            }));

    case 'fit':
        return readFile(file, 'binary', isGzipped)
            .then(contents => new Promise((resolve, reject) => {
                const parser = new EasyFit({
                    force: true,
                    mode: 'list',
                });

                parser.parse(contents, (err, result) => {
                    if (err) {
                        reject(err);
                    } else {
                        resolve(extractFITTracks(result, strippedName));
                    }
                });
            }));

    default:
        throw `Unsupported file format: ${format}`;
    }
}

