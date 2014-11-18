$(function() {
	var vis_container = d3.select("#visualization")
				.append("svg")
				.attr("width", 800)
				.attr("height", 500)
				.append("g")
				.attr("transform", "translate(50,50)");

	var competency_tree = d3.layout.tree()
				.size([400, 400]);

	var diagonal = d3.svg.diagonal()
			.projection(function (d) {
				return [d.y*1.2, d.x];
			});
	
	d3.json("/scripts/competency/competency/competency_test.json", function (competencies) {
		var nodes = competency_tree.nodes(competencies);
	
		var paths = competency_tree.links(nodes);

		vis_container.selectAll(".path")
			.data(paths)
			.enter()
			.append("path")
			.attr("class", "path")
			.attr("fill", "none")
			.attr("stroke", "black")
			.attr("d", diagonal);

		var node = vis_container.selectAll(".node")
	       		.data(nodes)
			.enter()
			.append("g")
			.attr("class", "node")
			.attr("transform", function (d) { 
						return "translate(" + d.y*1.2 + "," + d.x + ")";
					   });


		node.append("rect")
			.attr("width", 150)
			.attr("y", -15)
			.attr("height", 20)
			.attr("stroke", "black")
			.attr("fill", "lightblue");
		
		node.append("text")
			.text(function (d) { 
				return d.title;
			});

		node.on("click", function() {
			$.ajax({
				type: "POST",
				dataType: "json",
				url: "/tusk/competency/visualization/ajaxCompetencyBranch",
				data: {competency_id_1: 97575},
				success: function (response) {
					console.log(response);
				}
			});
		});

	});
});