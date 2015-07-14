var currentURL = window.location.pathname;
var split_currentURL = currentURL.split('/');		
var school = split_currentURL[split_currentURL.length - 1];

var competency_types = null;
var competency_levels = null;
var content_competencies = "";
var content_info = null;


$(function() {
	$("#domain_dropdown").val(0);
	$("#competency_dropdown").val(0);

	$("#tabs").tabs();

	$.ajax({				
			async: false,
			global: false,
			type: "POST",
			url: "/tusk/competency/search/ajaxCompetencyTypes/school/" + school,
			dataType: "json"
	}).success(function(data) {
			competency_types = data;
	});

	$.ajax({				
			async: false,
			global: false,
			type: "POST",
			url: "/tusk/competency/search/ajaxCompetencyLevels/school/" + school,
			dataType: "json"
	}).success(function(data) {
			competency_levels = data;
	});

});


function loadTopLevelCompetencies(domain) {
	$.ajax({				
			type: "POST",
			url: "/tusk/competency/search/ajaxTopLevelCompetencies",
			data: {competency_id: domain.value},
						
		}).success(function(data) {
			$("#competency_dropdown").empty();
			var blankCompetency = $('<option value="">' + "-- Select a Competency --" + '</option>');
			$("#competency_dropdown").append(blankCompetency);
			data = $.parseJSON(data);
			$.each(data, function(index, competency_object) {
				var newCompetency = $('<option value="' + competency_object.competency_id + '">' + competency_object.title + '</option>');
				$("#competency_dropdown").append(newCompetency);
			});
			if ($("#competency_dropdown option").length  <= 1) {
				var newCompetency = $('<option value="" disabled>' + "(None Available for current Selection)" + '</option>');
				$("#competency_dropdown").append(newCompetency);
			}
		});
}

function loadCompetencyChildren(competency_id) {
	$.ajax({				
			type: "POST",
			url: "/tusk/competency/search/ajaxCompetencyChildren",
			data: {competency_id: competency_id},						
		}).success(function(data) {
			console.log(data);
	});
}

function loadLinkedCompetencies(competency_id) {
	$.ajax({				
			type: "POST",
			url: "/tusk/competency/search/ajaxLinkedCompetencies",
			data: {competency_id: competency_id},						
		}).success(function(data) {
			console.log(data);
	});
}

function loadLinkedAndChildren(competency_id) {
	$.ajax({				
			type: "POST",
			url: "/tusk/competency/search/ajaxLinkedAndChildren",
			data: {competency_id: competency_id},						
		}).success(function(data) {
			console.log(data);
	});
}

function loadSearchResults() {
	$("#competency_search_results").find("tr:gt(0)").remove();
	$("#course_competency_search_results").find("tr:gt(0)").remove();
	$("#content_competency_search_results").find("tr:gt(0)").remove();
	$("#session_competency_search_results").find("tr:gt(0)").remove();
	var search_text = ($("#search_box").val());
	
	$.ajax({				
			type: "POST",
			url: "/tusk/competency/search/ajaxSearchResults/school/" + school,
			data: {search_text: search_text},
			dataType: "json"
	}).success(function(data) {
			if (data.length == 0) {
				$("#competency_search_results tr:last").after("<tr><td><i>(No results found for the current query. Please try again after modifying your search.) </i></td><td>x</td><td>x</td></tr>");
			}
			$.each(data, function (index, value) {
				if (competency_levels[value[1]] == 'content') {					
					content_competencies += ", " + value[0];
				}
			});
			content_competencies = content_competencies.substr(2, content_competencies.length);
			$.ajax({				
					async: false,
					global: false,
					type: "POST",	
					data: {competency_ids: content_competencies},
					url: "/tusk/competency/search/getContent/school/" + school,
					dataType: "json"
				}).success(function(data) {
					content_info = data;
				});

			$.each(data, function (index, value) {
				var table_row = '<tr>';
				if (competency_types[value[2]] == 'category') {
					table_row += '<td><img src="/graphics/competency/folder_16x16.png" /></td>'
				} else if (competency_types[value[2]] == 'info') {
					table_row += '<td><img src="/graphics/competency/info_16x16.png" /></td>'
				} else {
					table_row += '<td><img src="/graphics/competency/checkmark_16x16.png" /></td>'
				}

				if (competency_levels[value[1]] == 'national' || competency_levels[value[1]] == 'school') {
					table_row += '<td>' + value[3] + '</td></tr>';
					$("#competency_search_results tr:last").after(table_row);
				} else if (competency_levels[value[1]] == 'course') {
					var course_link;
					$.ajax({				
						async: false,
						global: false,
						type: "POST",	
						data: {competency_id: value[0]},
						url: "/tusk/competency/search/getCourse/school/" + school,
						dataType: "json"
					}).success(function(data) {						
						course_link = "</tr><tr><td colspan='2'><a class='content-link' href='/view/course/" + school + "/" + data.id + "/obj' target='_blank'>" + data.title + "</a>";
					});
					table_row += '<td>' + value[3] + '</td>' +  course_link  + '</td></tr>';				
					$("#course_competency_search_results tr:last").after(table_row);
				} else if (competency_levels[value[1]] == 'content') {
					var content_link;
					content_link = "</tr><tr><td colspan='2'><a class='content-link' href='/view/content/" + value[0]  + "' target='_blank'>" + content_info[value[0]].title + "</a>";
					content_link += "<br> <b>ID:</b> " + content_info[value[0]].content_id;
					content_link += " &nbsp&nbsp<b>Created:</b> " + content_info[value[0]].created;
					content_link += " &nbsp&nbsp<b>Modified:</b> " + content_info[value[0]].modified;
					
					table_row += '<td>' + value[3] + '</td>' +  content_link + '</td></tr>';
					$("#content_competency_search_results tr:last").after(table_row);
				} else {
	$.ajax({				
						async: false,
						global: false,
						type: "POST",	
						data: {competency_id: value[0]},
						url: "/tusk/competency/search/getSession/school/" + school,
						dataType: "json"
					}).success(function(data) {
						var session_link;
						session_link = "</tr><tr><td colspan='2'><a class='session-link'>" + data[0][1] + " (" + data[0][2] + ") " + "</a>";
						session_link += "<br> <b>ID:</b> " + data[0][0];
						session_link += " &nbsp&nbsp<b>Meeting Date:</b> " + data[0][5];
						session_link += " &nbsp&nbsp<b>Time:</b> " + data[0][6] + " - " + data[0][7];
						session_link += " &nbsp&nbsp<b>Location:</b> " + data[0][8];
						table_row += '<td>' + value[3] + '</td>' +  session_link + '</td></tr>';
						$("#session_competency_search_results tr:last").after(table_row);
					});
				} 
			});
	});
}

function makeTabs(selector) {
    tab_lists_anchors = document.querySelectorAll(selector + " li a");
    divs = document.querySelector(selector).getElementsByTagName("div");
    for (var i = 0; i < tab_lists_anchors.length; i++) {
        if (tab_lists_anchors[i].classList.contains('active')) {
            divs[i].style.display = "block";
        }
    }
 
    for (i = 0; i < tab_lists_anchors.length; i++) {
 
        document.querySelectorAll(".tabs li a")[i].addEventListener('click', function(e) {
 
            for (i = 0; i < divs.length; i++) {
                divs[i].style.display = "none";
            }
 
            for (i = 0; i < tab_lists_anchors.length; i++) {
                tab_lists_anchors[i].classList.remove("active");
            }
 
            clicked_tab = e.target || e.srcElement;
 
            clicked_tab.classList.add('active');
            div_to_show = clicked_tab.getAttribute('href');
 
            document.querySelector(div_to_show).style.display = "block";
        });
    }
}