var oneToSix = [1, 2, 3, 4, 5, 6];
var sectionIdArr = oneToSix.map(function (num) { return "#section-" + num});
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

