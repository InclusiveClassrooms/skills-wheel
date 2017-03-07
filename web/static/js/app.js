// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

// import socket from "./socket"

function toggle_visibility(id) {
  var new_student_button = document.getElementById(`button${id}`);
  new_student_button.className += " hidden";
  var new_student_form = document.getElementById(`form${id}`);
  new_student_form.className = new_student_form.className.replace(" hidden", "");
}

export var App = {
  run: function () {
    console.log("hello")
  },
  toggle_visibility: toggle_visibility
}
