import Vue from 'vue'

export default (selector, vueclass, mappings, options = {}) => {
  const elements = document.querySelectorAll(selector)
  elements.forEach(el => {
    const props = {}
    mappings.forEach((mapping) => {
      if (mapping in el.dataset)
      props[mapping] = JSON.parse(el.dataset[mapping])
    })
    new Vue({
      el,
      render: h => h(vueclass, { ...options, props } )
    })
  })
}
