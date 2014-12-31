var json =[];
var time_period;
var course_id;

$(document).ready(function() {
	$("#export").click(function() {
		var grades = $(this).data("grades");
		var students = $(this).data("students");
		var students_processed = {};
		$(students).each(function (index, object) {
			$.each(object, function(i,name) {
				students_processed[i] = name;			
			});
		});

		$(grades).each(function (index, object) {			
			$.each(object, function(index_2, object_2) {
				time_period = index_2;
				$.each(object_2, function(index_3, object_3) {
					course_id = index_3;
					grades = object_3;
				});
			});
		});

		var trial;

		$.each(grades, function (uid, grade) {
			var temp_hash = {};
			temp_hash.uid = uid;
			temp_hash.grade = grade;
			temp_hash.name = students_processed[uid]; 
			json.push(temp_hash);			
			trial = JSON.stringify(temp_hash);
		});
		
		generate();
		json = [];		
	});

});


function generate() {
	var form=document.createElement('form');
	form.setAttribute('method', 'post');
	form.setAttribute('action', '/tusk/admin/grade/export');
	form.style.display = 'hidden';

	var data = document.createElement("input");
	var data_2 = document.createElement("input");
	var data_3 = document.createElement("input");
	var data_4 = document.createElement("input");

	var json_text = JSON.stringify(json);

	data.setAttribute("name", "json");
	data.setAttribute("value", json_text);
	form.appendChild(data);
	
	data_2.setAttribute("name", "period");
	data_2.setAttribute("value", time_period);
	form.appendChild(data_2);
	
	data_3.setAttribute("name", "course");
	data_3.setAttribute("value", course_id);
	form.appendChild(data_3);

	var currentURL = window.location.pathname;

	data_4.setAttribute("name", "school");
	currentURL = currentURL.split('/');
	data_4.setAttribute("value", currentURL[currentURL.length - 1]);
	form.appendChild(data_4);

	document.body.appendChild(form);
	form.submit();
}