const polyline = require("@mapbox/polyline");

const mercatorProject = (lat, lng) => {
  return {
    x: (lng + 180) * (256 / 360),
    y:
      256 / 2 -
      (256 * Math.log(Math.tan(Math.PI / 4 + (lat * Math.PI) / 180 / 2))) /
        (2 * Math.PI)
  };
};

const pathsToSvgProps = gmPath => {
  const svgPaths = [];
  let minX = 256;
  let minY = 256;
  let maxX = 0;
  let maxY = 0;

  gmPath.forEach(([lat, lon]) => {
    const point = mercatorProject(lat, lon);
    minX = Math.min(minX, point.x);
    minY = Math.min(minY, point.y);
    maxX = Math.max(maxX, point.x);
    maxY = Math.max(maxY, point.y);
    svgPaths.push([point.x, point.y]);
  });
  const lines = svgPaths.
    map(([x, y]) => [(x-minX) / (maxX - minX) * 100, (y-minY) / (maxY - minY) * 100]).
    map(([x, y]) => `${x},${y}`);
  return {
    path: "M" + lines.join(" ") + "z",
    x: -1,
    y: -1,
    width: 102,
    height: 102,
  };
};

const drawPoly = (node, props) => {
  const svg = node.cloneNode(false);
  const g = document.createElementNS("http://www.w3.org/2000/svg", "g");
  const path = document.createElementNS("http://www.w3.org/2000/svg", "path");
  node.parentNode.replaceChild(svg, node);
  path.setAttribute("d", props.path);
  g.appendChild(path);
  svg.appendChild(g);
  svg.setAttribute(
    "viewBox",
    [props.x, props.y, props.width, props.height].join(" ")
  );
};

export default function(path, element) {
  const decodedPath = polyline.decode(path);
  const svgProps = pathsToSvgProps(decodedPath);
  drawPoly(element, svgProps);
}
