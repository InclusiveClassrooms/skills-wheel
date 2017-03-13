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

function reverse_toggle(id) {
  var new_student_button = document.getElementById(`button${id}`);
  new_student_button.className = new_student_button.className.replace(" hidden", "");
  var new_student_form = document.getElementById(`form${id}`);
  new_student_form.className += " hidden"
}

export var App = {
  toggle_visibility: toggle_visibility,
  reverse_toggle: reverse_toggle,
  collapse: collapse,
  addLabelListeners: addLabelListeners,
  disableSubmitUnlessAllAreChecked: disableSubmitUnlessAllAreChecked
}

function collapse () {
  var oneToSix = [1, 2, 3, 4, 5, 6];
  var headingIdArr = oneToSix.map(function (num) { return "#heading-" + num});

  function hiddenToggle(headingId) {
    var section = "#section" + headingId.slice(8);
    $(".glyphicon").addClass("glyphicon-chevron-down");
    $(".glyphicon").removeClass("glyphicon-chevron-up");

    if ($(section).hasClass("active")){
      $(section).removeClass("active");
      $(section).addClass("collapsed");
    } else {
      $(".section").addClass("collapsed");
      $(".section").removeClass("active");
      $(section).addClass('active');
      $(section).removeClass('collapsed');
      $(section + " .glyphicon").removeClass("glyphicon-chevron-down");
      $(section + " .glyphicon").addClass("glyphicon-chevron-up");
    }
  }

  (function expandListener(){
    headingIdArr.forEach(function(sectionId) {
      var section = document.querySelector(sectionId);
      section.addEventListener('click', function() {
        hiddenToggle(sectionId);
      });
    });
  })();
}

function addLabelListeners() {
  [].forEach.call(
    document.querySelectorAll('.answers label'),
    function (label_elem) {
      label_elem.addEventListener('click', function () {
        var id = label_elem.getAttribute('for');
        var input_elem = document.querySelector('#' + id);
        input_elem.checked = !input_elem.checked;
        disableSubmitUnlessAllAreChecked();
      })
    }
  )
}

function disableSubmitUnlessAllAreChecked() {
  var inputs = document.querySelectorAll('.answers input')
  var answered = [].filter.call(inputs, function (sel) {
    return sel.checked
  })

  var submit = document.querySelector('#survey_submit_button');
  submit.disabled = answered.length !== 30
}

