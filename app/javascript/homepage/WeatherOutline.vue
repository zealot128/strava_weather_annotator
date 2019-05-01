<template>
  <svg
    ref="target"
    style="height: 50px"
    preserveAspectRatio="xMinYMin meet"
  ></svg>
</template>

<script>
import createSvg from "homepage/functions";

export default {
  props: { polyline: { type: String, default: null } },
  mounted() {
    createSvg(this.polyline, this.$refs.target);
  }
};
</script>

<style>
g {
  fill: none;
}
path {
  stroke: #000000;
  stroke-width: 1;
}
</style>
