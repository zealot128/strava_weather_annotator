import picoModal from "picomodal";
import Image from "./image";

import { addAllTripsToMap } from 'heatmap_addons/functions'
import { extractTracks } from "./track.js"

const AVAILABLE_THEMES = [
  "CartoDB.DarkMatter",
  "CartoDB.DarkMatterNoLabels",
  "CartoDB.Positron",
  "CartoDB.PositronNoLabels",
  "Esri.WorldImagery",
  "OpenStreetMap.Mapnik",
  "OpenStreetMap.BlackAndWhite",
  "OpenTopoMap",
  "Stamen.Terrain",
  "Stamen.TerrainBackground",
  "Stamen.Toner",
  "Stamen.TonerLite",
  "Stamen.TonerBackground",
  "Stamen.Watercolor"
];

const MODAL_CONTENT = {
  help: `
<h1>dérive</h1>
<p>All imported strava activities will be imported</p>
<p>Algorithm by <a href='https://github.com/erik/derive'>Derive</a></p>
<p>You can close this window</p>
`,

  exportImage: `
<h3>Export Image</h3>

<form id="export-settings">
    <div class="form-row">
        <label>Format:</label>
        <select name="format">
            <option selected value="png">PNG</option>
            <option value="svg">SVG (no background map)</option>
        </select>
    </div>

    <div class="form-row">
        <label></label>
        <input id="render-export" type="button" value="Render">
    </div>
</form>

<p id="export-output"></p>
`
};

// Adapted from: http://www.html5rocks.com/en/tutorials/file/dndfiles/
function handleFileSelect(map, evt) {
  evt.stopPropagation();
  evt.preventDefault();

  const tracks = [];
  const files = Array.from(evt.dataTransfer.files);
  const modal = buildUploadModal(files.length);

  modal.show();

  const handleImage = async file => {
    const image = new Image(file);
    const hasGeolocationData = await image.hasGeolocationData();
    if (!hasGeolocationData) {
      throw "No geolocation data";
    }
    await map.addImage(image);
    modal.addSuccess();
  };

  const handleTrackFile = async file => {
    for (const track of await extractTracks(file)) {
      track.filename = file.name;
      tracks.push(track);
      map.addTrack(track);
      modal.addSuccess();
    }
  };

  const handleFile = async file => {
    try {
      if (/\.jpe?g$/i.test(file.name)) {
        return await handleImage(file);
      }

      return await handleTrackFile(file);
    } catch (err) {
      console.error(err);
      modal.addFailure({ name: file.name, error: err });
    }
  };

  Promise.all(files.map(handleFile)).then(() => {
    map.center();

    modal.finished();
  });
}

function handleDragOver(evt) {
  evt.dataTransfer.dropEffect = "copy";
  evt.stopPropagation();
  evt.preventDefault();
}

function buildUploadModal(numFiles) {
  let numLoaded = 0;
  const failures = [];
  const failureString = failures.length
    ? `, <span class='failures'>${failures.length} failed</span>`
    : "";
  const getModalContent = () => `
        <h1>Reading files...</h1>
        <p>${numLoaded} loaded${failureString} of <b>${numFiles}</b></p>`;

  const modal = picoModal({
    content: getModalContent(),
    escCloses: false,
    overlayClose: false,
    overlayStyles: styles => {
      styles.opacity = 0.1;
    }
  });

  modal.afterCreate(() => {
    // Do not allow the modal to be closed before loading is complete.
    // PicoModal does not allow for native toggling
    modal.closeElem().style.display = "none";
  });

  modal.afterClose(() => modal.destroy());

  // Override the content of the modal, without removing the close button.
  // PicoModal does not allow for native content overwriting.
  modal.setContent = body => {
    Array.from(modal.modalElem().childNodes).forEach(child => {
      if (child !== modal.closeElem()) {
        modal.modalElem().removeChild(child);
      }
    });

    modal.modalElem().insertAdjacentHTML("afterbegin", body);
  };

  modal.addFailure = failure => {
    failures.push(failure);
    modal.setContent(getModalContent());
  };

  modal.addSuccess = () => {
    numLoaded++;
    modal.setContent(getModalContent());
  };

  // Show any errors, or close modal if no errors occurred
  modal.finished = () => {
    if (failures.length === 0) {
      return modal.close();
    }

    const failedItems = failures.map(failure => `<li>${failure.name}</li>`);
    modal.setContent(`
            <h1>Files loaded</h1>
            <p>
                Loaded ${numLoaded},
                <span class="failures">
                    ${failures.length} failure${
      failures.length === 1 ? "" : "s"
    }:
                </span>
            </p>
            <ul class="failures">${failedItems.join("")}</ul>`);
    // enable all the methods of closing the window
    modal.closeElem().style.display = "";
    modal.options({
      escCloses: true,
      overlayClose: true
    });
  };

  return modal;
}

export function buildSettingsModal(tracks, opts, finishCallback) {
  let overrideExisting = opts.lineOptions.overrideExisting ? "checked" : "";

  if (tracks.length > 0) {
    const allSameColor = tracks.every(trk => trk.options.color === tracks[0].options.color);

    if (!allSameColor) {
      overrideExisting = false;
    } else {
      opts.lineOptions.color = tracks[0].options.color;
    }
  }

  const detect = opts.lineOptions.detectColors ? "checked" : "";
  const themes = AVAILABLE_THEMES.map(t => {
    const selected = t === opts.theme ? "selected" : "";

    return `<option ${selected} value="${t}">${t}</option>`;
  });

  const modalContent = `
<h3>Options</h3>

<form id="settings">
    <span class="form-row">
        <label>Theme</label>
        <select name="theme">
            ${themes}
        </select>
    </span>

    <fieldset class="form-group">
        <legend>GPS Track Options</legend>

        <div class="row">
            <label>Color</label>
            <input name="color" type="color" value=${opts.lineOptions.color}>
        </div>

        <div class="row">
            <label>Opacity</label>
            <input name="opacity" type="range" min=0 max=1 step=0.01
                value=${opts.lineOptions.opacity}>
        </div>

        <div class="row">
            <label>Width</label>
            <input name="weight" type="number" min=1 max=100
                value=${opts.lineOptions.weight}>
        </div>

    </fieldset>

    <fieldset class="form-group">
        <legend>Image Marker Options</legend>

        <div class="row">
            <label>Color</label>
            <input name="markerColor" type="color" value=${
              opts.markerOptions.color
            }>
        </div>

        <div class="row">
            <label>Opacity</label>
            <input name="markerOpacity" type="range" min=0 max=1 step=0.01
                value=${opts.markerOptions.opacity}>
        </div>

        <div class="row">
            <label>Width</label>
            <input name="markerWeight" type="number" min=1 max=100
                value=${opts.markerOptions.weight}>
        </div>

        <div class="row">
            <label>Radius</label>
            <input name="markerRadius" type="number" min=1 max=100
                value=${opts.markerOptions.radius}>
        </div>

    </fieldset>

    <span class="form-row">
        <label>Override existing tracks</label>
        <input name="overrideExisting" type="checkbox" ${overrideExisting}>
    </span>

    <span class="form-row">
        <label>Detect color from Strava bulk export</label>
        <input name="detectColors" type="checkbox" ${detect}>
    </span>
</form>`;

  const modal = picoModal({
    content: modalContent,
    closeButton: true,
    escCloses: true,
    overlayClose: true,
    overlayStyles: styles => {
      styles.opacity = 0.1;
    }
  });

  modal.afterClose(modal => {
    const {elements} = document.getElementById("settings");
    const options = Object.assign({}, opts);

    for (const opt of ["theme"]) {
      options[opt] = elements[opt].value;
    }

    for (const opt of ["color", "weight", "opacity"]) {
      options.lineOptions[opt] = elements[opt].value;
    }

    for (const opt of [
      "markerColor",
      "markerWeight",
      "markerOpacity",
      "markerRadius"
    ]) {
      const optionName = opt.replace("marker", "").toLowerCase();
      options.markerOptions[optionName] = elements[opt].value;
    }

    for (const opt of ["overrideExisting", "detectColors"]) {
      options.lineOptions[opt] = elements[opt].checked;
    }

    finishCallback(options);
    modal.destroy();
  });

  return modal;
}

export function showModal(type) {
  const modal = picoModal({
    content: MODAL_CONTENT[type],
    overlayStyles: styles => {
      styles.opacity = 0.01;
    }
  });

  modal.show();

  return modal;
}

export function initialize(map, tripIds) {
  const modal = showModal("help");

  window.addEventListener("dragover", handleDragOver, false);

  window.addEventListener(
    "drop",
    e => {
      if (!modal.destroyed) {
        modal.destroy();
        modal.destroyed = true;
      }
      handleFileSelect(map, e);
    },
    false
  );
  addAllTripsToMap(tripIds, map, modal)
}
