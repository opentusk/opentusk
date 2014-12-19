var json =[];

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
				$.each(object_2, function(index_3, object_3) {
					grades = object_3;
				});
			});
		});

		$.each(grades, function (uid, grade) {
			var temp_hash = {};
			temp_hash.uid = uid;
			temp_hash.grade = grade;
			temp_hash.name = students_processed[uid]; 
			json.push(temp_hash);			
		});

		$.post( "/tusk/admin/grade/export", function(data){
		});
	});

});

function generate() {
	var form=document.createElement('form');
	form.setAttribute('method', 'post');
	form.setAttribute('action', '/tusk/admin/grade/export');
	form.style.display = 'hidden';
	var data = document.createElement("input");
	var json_text = JSON.stringify(json);
	data.setAttribute("name", json_text);
	form.appendChild(data);
	document.body.appendChild(form);
	form.submit();
}