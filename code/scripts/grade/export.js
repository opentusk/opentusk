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

		var trial;

		$.each(grades, function (uid, grade) {
			var temp_hash = {};
			temp_hash.uid = uid;
			temp_hash.grade = grade;
			temp_hash.name = students_processed[uid]; 
			json.push(temp_hash);			
			trial = JSON.stringify(temp_hash);
		});

		console.log(trial);

		console.log(json);

		/*
		$.post( "/tusk/admin/grade/export", function(data){
		});
		*/
	});

});

var input;
var url;
var lastSaved;
 
function doJSON(validJSONInput) {
  // get input JSON, try to parse it
  var newInput = validJSONInput;
  if (newInput == input) return;
 
  input = newInput;
  if (!input) {
    return;
  }
  var json = jsonFrom(input);
  doCSV(json);
  return true;
}
 
function doCSV(json) {
  var inArray = arrayFrom(json);
  var outArray = [];
  for (var row in inArray)
      outArray[outArray.length] = parse_object(inArray[row]);
 
  var csv = $.csv.fromObjects(outArray);
  var uri = "data:text/csv;charset=utf-8," + encodeURIComponent(csv);
  window.location.href = uri;
}


function generate() {
	var form=document.createElement('form');
	form.setAttribute('method', 'post');
	form.setAttribute('action', '/tusk/admin/grade/export');
	form.style.display = 'hidden';
	var data = document.createElement("input");
	var json_text = JSON.stringify(json);
	console.log(json_text);
	data.setAttribute("name", "json");
	data.setAttribute("value", json_text);
	form.appendChild(data);
	console.log(data);
	document.body.appendChild(form);
	form.submit();
}