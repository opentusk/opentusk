/*
Uses D3.js data visualization library (http://d3js.org/) for Javascript.
Based on Collapsible Tree example by Mike Bostock (http://mbostock.github.io/d3/talk/20111018/tree.html)
and pan and zoom extension by Rob Schmuecker (http://bl.ocks.org/robschmuecker/7880033)
*/

var m = [20, 120, 20, 120],
    w = 1280 - m[1] - m[3],
    h = 600 - m[0] - m[2];

$(function() {
	var i = 0;
	var root;

	var currentURL = window.location.pathname;
	var split_currentURL = currentURL.split('/');		
	var school = split_currentURL[split_currentURL.length - 1];

	var tree = d3.layout.tree()
		    .size([h, w]);

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

	
	d3.json("/scripts/competency/competency/competency_test.json", function(json) {
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
		domain_json.level = "national";
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
	nodes.forEach(function(d) { d.y = d.depth * 180; });

	// Update the nodes…
	var node = vis.selectAll("g.node")
		.data(nodes, function(d) { return d.id || (d.id = ++i); });

	// Enter any new nodes at the parent's previous position.
	var nodeEnter = node.enter().append("svg:g")
		.attr("class", "node")
      		.attr("transform", function(d) { return "translate(" + source.y0 + "," + source.x0 + ")"; })
  		.on("click", function(d) { toggle(d); update(d); });

	nodeEnter.append("svg:rect")
		.attr("x", function(d) { return d.children || d._children ? -160 : 0; })
		.attr("y", -10)
		.attr("width", 160)
		.attr("height", 20)
		.attr("stroke", function(d) {
			if (d.level == "national") {
				return "black";
			} else if (d.level == "school") {
				return "green";
			} else if (d.level == "course") {
				return "#D57025";
			} else {
				return "#4D92CD";
			}
		})

	nodeEnter.append("svg:text")
	        .attr("x", function(d) { return d.children || d._children ? -10 : 10; })
	        .attr("dy", ".35em")
		.attr("stroke", function(d) {
			if (d.level == "national") {
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
			if (competency_info.length >= 20){
				competency_info = competency_info.substring(0,20) + "\u2026";		
			} 
			return competency_info;
		})

	nodeEnter.append("svg:title")
		.text(function (d) {
			var this_text;
			if (d.title) {
				if (d.title.length >= 20) {this_text = d.title};
			} else {
				if (d.description.length >=20) {this_text = d.description};
			}
			if (d.course) {
				this_text = this_text + " (" + d.course + ")";
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
	} else {
		if (d._children == null){ //if no children exists in our tree data structure yet then make ajax call to look into the database
			$.ajax({
				type: "POST",
				url: "/tusk/competency/visualization/ajaxCompetencyBranch",
				data: {competency_id: d.competency_id},
				dataType: "json",
				statusCode: {
					500: function() {
						console.log("Error 500: Failed to obtain tree for current competency.")
					}
				}
			}).success(function(data) {
				if (data.children.length == 0) {
					alert("No children or links found!");
				}
				var newnodes = tree.nodes(data.children).reverse();
				d.children = newnodes[0];
				update(d);
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
