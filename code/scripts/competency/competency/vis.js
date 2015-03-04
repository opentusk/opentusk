/*
Uses D3.js data visualization library (http://d3js.org/) for Javascript.
Based on Collapsible Tree example by Mike Bostock (http://mbostock.github.io/d3/talk/20111018/tree.html)
and pan and zoom extension by Rob Schmuecker (http://bl.ocks.org/robschmuecker/7880033)
*/

var m = [20, 120, 20, 120],
    w = 1500 - m[1] - m[3],
    h = 1200 - m[0] - m[2];

$(function() {
	detectIE("The Competency Visualization tool does not support the Internet Explorer web browser below version 11. Please either upgrade to IE11 or use Google Chrome or Mozilla Firefox (recommended).", 
		"The Competency Visualization tool is not fully supported in Internet Explorer 11. Although you will be able to use the tool we recommend switching to Google Chrome or Mozilla Firefox for a better experience.");
	
	$("#current_domain").val(0);
	document.getElementById("current_domain").options[0].disabled = true;
	
	var i = 0;
	var root;

	var currentURL = window.location.pathname;
	var split_currentURL = currentURL.split('/');		
	var school = split_currentURL[split_currentURL.length - 1];

	var tree = d3.layout.tree()
		    .separation(function(a, b) {
		    	return ((a.parent == root) && (b.parent == root)) ? 1 :1;
		    })
		    .size([h + 500, w]);

	var diagonal = d3.svg.diagonal()
			    .projection(function(d) { return [d.y, d.x]; });

	var vis = d3.select("#visualization").append("svg:svg")
		    .attr("width", w + m[1] + m[3])
		    .attr("height", h + m[0] + m[2])
		    .append("svg:g")
		    .attr("transform", "translate(" + m[3] + "," + m[0] + ")")
		    .append("svg:g")
		    .attr("class","drawarea")
		    .append("svg:g")
		    .attr("transform", "translate(" + m[3] + "," + m[0] + ")");

	
	d3.json("/scripts/competency/competency/competency_none.json", function(json) {
		root = json;
	        root.x0 = h / 2;
		root.y0 = 0;
		function toggleAll(d) {
		    if (d.children) {
			      d.children.forEach(toggleAll);
		   	      toggle(d);
		    }
		}

	$("#current_domain").change(function() {		
		var domain_json = new Object();
		domain_json.title = $(this).children("option").filter(":selected").text();
		domain_json.level = "category";
		domain_json.competency_id = this.value;
		
		$.ajax({				
				type: "POST",
				url: "/tusk/competency/visualization/ajaxFirstLoad/school/" + school,
				data: {competency_id: this.value},
				dataType: "json",
				statusCode: {
					500: function() {
						console.log("Error 500: Failed to obtain tree for current competency.")
					}
				}
			}).success(function(data) {
				domain_json.children = data;
				root = domain_json;				
				root.x0 = h/2;
				root.y0 = 0;
				update(root);
			});

		
	});

  	//Initialize the display to show a few nodes.
		toggle(root);
		update(root);
});


function update(source) {
	var duration = d3.event && d3.event.altKey ? 5000 : 500;

	// Compute the new tree layout.
	var nodes = tree.nodes(root).reverse();

	// Normalize for fixed-depth.
	nodes.forEach(function(d) { 
		d.y = d.depth * 400; 
	});

	// Update the nodes…
	var node = vis.selectAll("g.node")
		.data(nodes, function(d) { return d.id || (d.id = ++i); });

	// Enter any new nodes at the parent's previous position.
	var nodeEnter = node.enter().append("svg:g")
		.attr("class", "node")
      		.attr("transform", function(d) { return "translate(" + source.y0 + "," + source.x0 + ")"; })
  		.on("click", function(d) { toggle(d); update(d); });
/*
	nodeEnter.append("svg:rect")
		.attr("x", function(d) { return d.children || d._children ? -160 : -162; })
		.attr("y", -10)
		.attr("width", 200)
		.attr("height", 30)
		.attr("stroke", function(d) {
			if (d.level == "national" || d.level == "category") {
				return "black";
			} else if (d.level == "school") {
				return "green";
			} else if (d.level == "course") {
				return "#D57025";
			} else {
				return "#4D92CD";
			}
		})
*/
	nodeEnter.append("svg:foreignObject")
		 .attr("x", function(d) { return d.children || d._children ? -200 : -200; })
	         .attr("y", -20)
		 .attr('width', 300)
		 .attr('height', 100)
		 .append('xhtml:p')
		 .attr('class', 'node_text')
		 .attr('style', function(d) {
			if (d.level == "national" || d.level == "category") {
				return "border-color : black; color : black;";
			} else if (d.level == "school") {
				return "border-color : green; color : green;";
			} else if (d.level == "course") {
				return "border-color : #D57025; color : saddlebrown";
			} else {
				return "border-color : #4D92CD; color : darkslateblue";
			}
		 })
		 .html(function(d) {
			var competency_info;
			if (d.title) {
				competency_info = d.title;
			} else {
				competency_info =  d.description;
			}
			if (d.info) {
				competency_info = "<span class='node_text_info'>[" + d.info + "]</span> " + competency_info; 
			} 
			if (d.date) {
				competency_info = competency_info + " <span class='node_text_info'>(" + d.date + ")</span>";
			}
			return competency_info;
		 });
	
	
/*
	nodeEnter.append("svg:text")
	        .attr("x", function(d) { return d.children || d._children ? -10 : -157; })
	        .attr("dy", ".35em")
		.attr("stroke", function(d) {
			if (d.level == "national" || d.level == "category") {
				return "black";
			} else if (d.level == "school") {
				return "green";
			} else if (d.level == "course") {
				return "#D57025";
			} else {
				return "#4D92CD";
			}
		})
	        .attr("text-anchor", function(d) { return d.children || d._children ? "end" : "start"; })
	        .text(function(d) { 
			var competency_info;
			if (d.title) {
				competency_info = d.title;
			} else {
				competency_info =  d.description;
			}
	
			if (competency_info.length >= 30){
				if (competency_info === competency_info.toUpperCase() ){
					competency_info = competency_info.substring(0,20) + "\u2026";
				} else {
					competency_info = competency_info.substring(0,28) + "\u2026";		
				} 
			} 
	
			return competency_info;
		})
*/
	nodeEnter.append("svg:title")
		.text(function (d) {
			var this_text;
			if (d.title) {
				if (d.title.length >= 30) {this_text = d.title};
			} else {
				if (d.description.length >=30) {this_text = d.description};
			}
			if (d.info) {
				if (this_text) {
					this_text = this_text + " (" + d.info + ")";
				} else {
					this_text = " (" + d.info + ")";
				}
			} 
			return this_text;
		});


	// Transition nodes to their new position.
	var nodeUpdate = node.transition()
	        .duration(duration)
	        .attr("transform", function(d) { return "translate(" + d.y + "," + d.x + ")"; });

	nodeUpdate.select("circle")
	        .attr("r", 4.5)
	        .style("fill", function(d) { return d._children ? "lightsteelblue" : "#fff"; });

	nodeUpdate.select("text")
	        .style("fill-opacity", 1);

	// Transition exiting nodes to the parent's new position.
	var nodeExit = node.exit()
	        .attr("transform", function(d) { return "translate(" + source.y + "," + source.x + ")"; })
	        .remove();

	nodeExit.select("circle")
	        .attr("r", 1e-6);

        nodeExit.select("text")
	        .style("fill-opacity", 1e-6);

        // Update the links…
	var link = vis.selectAll("path.link")
	        .data(tree.links(nodes), function(d) { return d.target.id; });

	// Enter any new links at the parent's previous position.
	link.enter().insert("svg:path", "g")
	        .attr("class", "link")
	        .attr("d", function(d) {
		        var o = {x: source.x0, y: source.y0};
		        return diagonal({source: o, target: o});
	        })
	        .transition()
	        .duration(duration)
	        .attr("d", diagonal);

  	// Transition links to their new position.
	link.transition()
	        .duration(duration)
	        .attr("d", diagonal);

	// Transition exiting nodes to the parent's new position.
	link.exit().transition()
	        .duration(duration)
	        .attr("d", function(d) {
		        var o = {x: source.x, y: source.y};
		        return diagonal({source: o, target: o});
	        })
	        .remove();

	// Stash the old positions for transition.
	nodes.forEach(function(d) {
	        d.x0 = d.x;
	        d.y0 = d.y;
	});

	d3.select("svg")
	    	.call(d3.behavior.zoom()
	        .scaleExtent([0.5, 5])
	        .on("zoom", zoom));
}


// Toggle children nodes (expand/collapse)
function toggle(d) {
	if (d.children) {
		d.children.forEach(function(this_child) {
			if (this_child.children) {
				toggle(this_child);
			}
		});
		d._children = d.children;
		d.children = null;
		if (d.level !== "category") {
			d._children = null;
		}
	} else {
		if (d._children == null){ //if no children exists in our tree data structure yet then make ajax call to look into the database
			$.ajax({
				type: "POST",
				url: "/tusk/competency/visualization/ajaxCompetencyBranch/school/" + school,
				data: {competency_id: d.competency_id},
				dataType: "json",
				statusCode: {
					500: function() {
						console.log("Error 500: Failed to obtain tree for current competency.")
					}
				}
			}).success(function(data) {				
				var newnodes = tree.nodes(data.children).reverse();
				d.children = newnodes[0];
				update(d);
				$.ajax({
				type: "POST",
				url: "/tusk/competency/visualization/ajaxCompetencyChildren/school/" + school,
				data: {competency_id: d.competency_id},
				dataType: "json",
				statusCode: {
					500: function() {
						console.log("Error 500: Failed to obtain tree for current competency.")
					}
				}
				}).success(function(data2) {
					if (!d.children) {
						if (data2.length === 0) {
							alert("No links or children found!");
						}
						d.children = data2;
						update(d);
					} else {
						$.each( data2, function (key, child) {
							d.children.push(child);
						});
						update(d);
					}
				});
			});			
		}		
	        d.children = d._children;		
	        d._children = null;
        }
}

});


//Zoom function
function zoom() {
    var scale = d3.event.scale,
        translation = d3.event.translate,
        tbound = -h * scale,
        bbound = h * scale,
        lbound = (-w + m[1]) * scale,
        rbound = (w - m[3]) * scale;

    // limit translation to thresholds
    translation = [
        Math.max(Math.min(translation[0], rbound), lbound),
        Math.max(Math.min(translation[1], bbound), tbound)
    ];

    d3.select(".drawarea")
        .attr("transform", "translate(" + translation + ")" +" scale(" + scale + ")");
}

function wrap(text, width) {
    text.each(function () {
        var text = d3.select(this);
        var words = text.text().split(/\s+/).reverse(),
            word,
            line = [],
            lineNumber = 0,
            lineHeight = 1.1, // ems
            x = text.attr("x"),
            y = text.attr("y"),
            dy = 0, //parseFloat(text.attr("dy")),
            tspan = text.text(null)
                        .append("tspan")
                        .attr("x", x)
                        .attr("y", y)
                        .attr("dy", dy + "em");
        while (word = words.pop()) {
            line.push(word);
            tspan.text(line.join(" "));
            if (tspan.node().getComputedTextLength() > width) {
                line.pop();
                tspan.text(line.join(" "));
                line = [word];
                tspan = text.append("tspan")
                            .attr("x", x)
                            .attr("y", y)
                            .attr("dy", lineHeight + dy + "em")
                            .text(word);
            }
        }
    });
	d3plus.textwrap()
		.container(d3.select(".node rect"))
		.draw();
}