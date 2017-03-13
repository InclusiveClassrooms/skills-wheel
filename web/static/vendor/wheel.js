var Wheel = {
  draw: function (formAnswers, element, assets_path, config) {
    function fillWheel(formAnswers, unique_string){
      var colours = ["fabb4d","e5007d","672a99", "75bb49", "50b9a7", "009ee3"];
      formAnswers.forEach(function(elem, index){
        var questionClass = "segment" + unique_string + "-" + index;
        var colour = colours[Math.floor(index/5)];
        for (var i = 0; i<=elem.answer; i++){
          var target = (index + 1) + "-" + i;
          d3.select("#segment" + unique_string + "-" + target)
            .attr("fill", "#" + colour)
            .classed(questionClass, true);
        }
      });
      highlightWheel(unique_string)
      // createPDF();
    }

    function highlightWheel(unique_string){
      $("." + "segment" + unique_string).on("mouseover", function(){
        var value = this.className.baseVal.split(" ")[1];
        $("."+ value).addClass("highlight");
      });
      $("." + "segment" + unique_string).on("mouseout", function(){
        var value = this.className.baseVal.split(" ")[1];
        $("."+ value).removeClass("highlight");
      });
    }

    // function createPDF(callback) {
    //   var wheel = '<head><link href="https://fonts.googleapis.com/css?family=Open+Sans:700" rel="stylesheet" type="text/css"><link href="https://fonts.googleapis.com/css?family=Varela+Round" rel="stylesheet" type="text/css"></head><body><header style="background-color: #E5007D; width: 100%; height: 4em;"><a href="http://inclusiveclassrooms.co.uk"><img class="home-link" src="../assets/inclusive-classrooms-300x126.png" alt="inclusive classrooms" height="100%"/></a></header>' +  $('#wheel-container').html() + '</body>';
    //   var request = $.ajax({
    //     url: "https://inclusive-classrooms.herokuapp.com/pdf",
    //     type: "post",
    //     data: wheel
    //   });
    //   request.done(function(response){
    //     $('#pdf').removeClass("inactive");
    //   });
    //   highlightWheel();
    // }

    var vis = d3.select(element).append("svg").attr("id", "wheel-svg");
    var segmentClass;
    var textPathID;
    var segmentID;
    var faceImages = ["face-never.svg", "face-rarely.svg", "face-sometimes.svg", "face-always.svg"];
    var outerTextArray = ["SELF-AWARENESS & SELF-ESTEEM", "MANAGING FEELINGS", "NON-VERBAL COMMUNICATION", "VERBAL COMMUNICATION", "PLANNING & PROBLEM SOLVING", "RELATIONSHIPS, LEADERSHIP & ASSERTIVENESS"];
    var centre = config.centre;
    var height = config.height;
    var width = config.width || height;
    var ratio = config.ratio;
    var unique_string = config.unique_string;
    var arc;

    var oneSliceWidth = (360 * (Math.PI / 180) / 32); // converted from degrees to radians

    var childDetails = ['Teaching Assistant',  'Student', 'School', 'School Year', 'Group', 'Date'];

    // draw outer text
    for (var m = 0; m < 6; m++) {
      var textArc = d3.svg.arc()
        .innerRadius(200 * ratio)
        .outerRadius(200 * ratio)
        .startAngle(((m * 5) + 1) * oneSliceWidth) // radians
        .endAngle(((m * 5) + 6) * oneSliceWidth); // radians

      vis.attr("width", width).attr("height", height)
        .append("path")
        .attr("id", outerTextArray[m] + unique_string)
        .attr("d", textArc)
        .attr("fill", "none")
        .style("stroke", "none")
        .attr("transform", "translate(" + centre + "," + centre + ")");

      vis.append("text")
        .append("textPath") //append a textPath to the text element
        .style("font-size", (8 * ratio) + "px")
        .style("text-anchor", "middle") //place the text halfway on the arc
        .style("font-family", "Varela Round")
        .attr("fill", "#6D6D6B")
        .attr("startOffset", "25%")
        .attr("xlink:href", "#" + outerTextArray[m] + unique_string) //place the ID of the path here
        .text(outerTextArray[m]);
    }

    // generate chart outline
    for (var j = 0; j < 5; j++) {
      for (var i = 0; i < 31; i++) {

        if (i === 0) {
          segmentClass = "face";

          arc = d3.svg.arc()
            .innerRadius(ratio * (40 + j * 30))
            .outerRadius(ratio * (70 + j * 30))
            .startAngle(0 - oneSliceWidth) // radians
            .endAngle(oneSliceWidth); // radians

        } else {
          segmentClass = "segment" + unique_string;
          textPathID = "textpath" + unique_string + "-" + i + "-" + j;
          segmentID = "segment" + unique_string + "-" + i + "-" + j;

          arc = d3.svg.arc()
            .innerRadius(ratio * (40 + j * 30))
            .outerRadius(ratio * (70 + j * 30))
            .startAngle(i * oneSliceWidth) // radians
            .endAngle((i + 1) * oneSliceWidth); // radians

          if (j === 3) {
            var numArc = d3.svg.arc()
              .innerRadius(ratio * (41 + j * 32))
              .outerRadius(ratio * (71 + j * 32))
              .startAngle(i * oneSliceWidth) // radians
              .endAngle((i + 1) * oneSliceWidth); // radians

            vis.attr("width", width).attr("height", height)
              .append("path")
              .attr("d", numArc)
              .attr("id", textPathID)
              .attr("fill", "none")
              .style("stroke", "none")
              .attr("transform", "translate(" + centre + "," + centre + ")");

            vis.append("text")
              .append("textPath") //append a textPath to the text element to follow
              .style("font-size", (18 * ratio) + "px")
              .style("font-family", "Varela Round")
              .attr("fill", "#EA5C37")
              .attr("startOffset", "8%")
              .attr("xlink:href", "#textpath" + unique_string + "-" + i + "-" + j) //place the ID of the path here
              .text(((i - 1) % 5) + 1 + ".");
          }
        }

        vis.attr("width", width).attr("height", height)
          .append("path")
          .attr("d", arc)
          .classed(segmentClass, true)
          .attr("id", segmentID)
          .attr("fill", "transparent")
          .style("stroke", "#6D6D6B")
          .attr("transform", "translate(" + centre + "," + centre + ")");

        if (i === 0 && j < 4) {
          vis.append("svg:image")
            .attr("xlink:href", assets_path + faceImages[j])
            .attr("width", 40 * ratio)
            .attr("height", 40 * ratio)
            .attr("x", centre - 20 * ratio)
            .attr("y", (centre - ratio * 75 - (ratio * j * 30)));
        }
      }
    }

    // Draw the orange line seperators on the chart
    for (var k = -7; k < 24; k += 5) {
      vis.append("line")
        .attr("x2", centre + ratio * (190 * Math.cos(k * oneSliceWidth)))
        .attr("y2", centre + ratio * (190 * Math.sin(k * oneSliceWidth)))
        .attr("x1", centre + ratio * (40 * Math.cos(k * oneSliceWidth)))
        .attr("y1", centre + ratio * (40 * Math.sin(k * oneSliceWidth)))
        .attr("stroke", "#EA5C37");
    }
    fillWheel(formAnswers, unique_string);
  }
}
