import "./style.css";

import GpxMap from "./map";
import { initialize } from "./ui";

function app() {
  const trips = JSON.parse(
    document.getElementById("background-map").dataset.ids
  );
  const map = new GpxMap();
  initialize(map, trips);
}

// Safari (and probably some other older browsers) don't support canvas.toBlob,
// so polyfill it in.
//
// https://developer.mozilla.org/en-US/docs/Web/API/HTMLCanvasElement/toBlob#Polyfill
if (!HTMLCanvasElement.prototype.toBlob) {
  Object.defineProperty(HTMLCanvasElement.prototype, "toBlob", {
    value(callback, type, quality) {
      const binStr = atob(this.toDataURL(type, quality).split(",")[1]);
      const len = binStr.length;
      const arr = new Uint8Array(len);

      for (let i = 0; i < len; i++) {
        arr[i] = binStr.charCodeAt(i);
      }

      callback(new Blob([arr], { type: type || "image/png" }));
    }
  });
}

document.addEventListener("DOMContentLoaded", app);
