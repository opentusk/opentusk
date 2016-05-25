function closeNoteTrigger(button) {
	$(button).closest("div#note").find("a#noteHistoryPlaceholder").show();
	$(button).closest('#noteHistoryColumnContent').remove();
}

$(document).ready(function() {
	$("a#noteHistoryPlaceholder").off();
	$("a#noteHistoryPlaceholder").click(function() {
		if ($(this).closest("div#note").find("#noteHistoryHover").length) {
			$(this).closest("div#note").find("#noteHistoryHover").remove();
		}
		if ($(this).closest("div#note").find("#noteHistory").length) {
			return;
		}
		var noteHistory = document.createElement('div');
		var lineBreak = document.createElement('br');
		var noteHistoryColumnContent = document.createElement('div');
		var buttons = document.createElement('span');
		var cancelNoteButton = document.createElement('a');

		noteHistory.setAttribute("id", "noteHistory");	
		noteHistoryColumnContent.setAttribute("id", "noteHistoryColumnContent");
		buttons.setAttribute("id", "noteActions");
		cancelNoteButton.setAttribute("id", "closeNoteTrigger");
		cancelNoteButton.setAttribute("onclick", "closeNoteTrigger(this)");
		cancelNoteButton.setAttribute("style", "cursor: pointer");
		cancelNoteButton.setAttribute("class", "navsm");
		cancelNoteButton.innerHTML = "Close";
                                              
		var dataProcessor = function (data, noteHistory) {
			var noteContent = data['content'];
			for (var noteElement in noteContent) {
				for (var noteEntry in noteContent[noteElement]) {
					noteHistory.innerHTML += 
						"<p class = 'noteAuthor'>" + 
						noteContent[noteElement][noteEntry]['noteAuthor'] + "</p>" +
						"<p class = 'noteCreated'>" + noteContent[noteElement][noteEntry]['noteCreated'] 
						+ "</p>" + noteContent[noteElement][noteEntry]['note'] + "<br>";
				}
			}
		};
		applyNoteContent(
			((typeof note_user_id !== 'undefined' && typeof note_user_id == 'function') ? 
				note_user_id() : 
				$(this).closest('td').find('span#student').html()),
			note_school_id, 
			(typeof note_course_id == 'function' ? note_course_id(this) : note_course_id), 
			(typeof serial_user_id_used == 'function' ? serial_user_id_used() : 1),
			noteHistory, dataProcessor);


		buttons.appendChild(lineBreak);
		buttons.appendChild(cancelNoteButton);
		// noteHistory.appendChild(buttons);
		noteHistoryColumnContent.appendChild(noteHistory);
		noteHistoryColumnContent.appendChild(buttons);
		$(this).closest("div#note").append(noteHistoryColumnContent);
		$(this).closest("div#note").find("a#noteHistoryPlaceholder").hide();
	});

	$("a#noteHistoryPlaceholder").hover(
		function() {
			if (!$(this).closest("div#note").find("#noteHistory").length) {
				console.log('Note history lengt is ' + $(this).closest("div#note").find("#noteHistory").length);
				var position = $(this).position();
				var noteHistoryHover = document.createElement('div');
				noteHistoryHover.setAttribute("id", "noteHistoryHover");
				var dataProcessor = function (data, noteHistoryHover) {
					var noteContent = data['content'];
						for (var noteElement in noteContent) {
							for (var noteEntry in noteContent[noteElement]) {
								noteHistoryHover.innerHTML += 
									"<p class = 'noteAuthor'>" + 
									noteContent[noteElement][noteEntry]['noteAuthor'] + "</p>" +
									"<p class = 'noteCreated'>" + noteContent[noteElement][noteEntry]['noteCreated'] 
									+ "</p>" + noteContent[noteElement][noteEntry]['note'] + "<br>";
							}
						}
						noteHistoryHover.innerHTML += "</p>";
					};
				applyNoteContent(
					((typeof note_user_id !== 'undefined' && typeof note_user_id == 'function') ? 
						note_user_id() : 
						$(this).closest('td').find('span#student').html()),
					note_school_id, 
					(typeof note_course_id == 'function' ? note_course_id(this) : note_course_id), 
					(typeof serial_user_id_used == 'function' ? serial_user_id_used() : 1),
					noteHistoryHover, dataProcessor);
				$(this).closest("div#note").append($(noteHistoryHover));
			}
		},
		function() {
			if ($(this).closest("div#note").find("#noteHistoryHover").length) {
				$(this).closest("div#note").find( "div:last" ).remove();
			}
		}
	);

	function applyNoteContent(user_id, school_id, course_id, serial_user_id_used, noteBox, dataProcessor) {
		$.ajax({
			url: "/tusk/schedule/clinical/admin/ajax/note/content",
			cache: false,
			data: {
				user_id: user_id,
				school_id: note_school_id,
				course_id: course_id,
				serial_user_id_used: serial_user_id_used
			}, dataType: "json",
			statusCode: {
				404: function () {
				},
				500: function () {
				},
			}
		}).done(function() {
		}).error(function() {
			alert("An error occured during the note retrieval process.");
		}).success(function(data, status) {
			if (data.status == 'ok') {
				dataProcessor(data, noteBox);
			}
		});
	}
});