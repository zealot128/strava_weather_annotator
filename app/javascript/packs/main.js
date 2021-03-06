import $ from 'jquery'

if (!('jQuery' in window)) {
  window.jQuery = $
  window.$ = $
}

import 'style.scss'

import 'bootstrap/js/dist/util';
import 'bootstrap/js/dist/collapse';
import 'bootstrap/js/dist/tooltip';
import 'bootstrap/js/dist/dropdown';
import 'bootstrap/js/dist/button';
import 'bootstrap/js/dist/alert';

import Rails from 'rails-ujs/lib/assets/compiled/rails-ujs.js';

if (!('Rails' in window)) {
  window.Rails = Rails
  Rails.start();
}
