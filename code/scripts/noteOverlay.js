function cancelNoteTrigger(button) {
	$(button).closest('#noteHistoryColumnContent').remove();
}

$(document).ready(function() {
	$("a#placeholder").click(function() {
		var noteHistory = document.createElement('textarea');
		var noteHistoryColumnContent = document.createElement('div');
		var buttons = document.createElement('span');
		var cancelNoteButton = document.createElement('a');

		noteHistory.setAttribute("disabled", true);
		noteHistory.setAttribute("id", "noteHistory");
		noteHistory.setAttribute("rows", 10);
		noteHistory.setAttribute("cols", 30);
		noteHistoryColumnContent.setAttribute("id", "noteHistoryColumnContent");
		buttons.setAttribute("id", "noteActions");
		cancelNoteButton.setAttribute("id", "cancelNoteTrigger");
		cancelNoteButton.setAttribute("onclick", "cancelNoteTrigger(this)");
		cancelNoteButton.setAttribute("style", "cursor: pointer");
		cancelNoteButton.setAttribute("class", "navsm");
		cancelNoteButton.innerHTML = "Cancel";
		console.log("Closest sid is : " + $(this).closest('td').find('span#student').html());
		$.ajax({
			url: "/tusk/schedule/clinical/admin/ajax/note/content",
			cache: false,
			data: {
				user_id: $(this).closest('td').find('span#student').html(),
				school_id: note_school_id,
				course_id: note_course_id,
				serial_user_id_used: 1
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
				var noteContent = data['content'];
				for (var noteElement in noteContent) {
					for (var noteEntry in noteContent[noteElement]) {
						noteHistory.innerHTML += noteContent[noteElement][noteEntry]['noteAuthor'] + 
						" on " + noteContent[noteElement][noteEntry]['noteCreated'] + ": \n\n" + 
							noteContent[noteElement][noteEntry]['note'] + "\n\n\n";
					}
				}
			}
		});

		noteHistoryColumnContent.appendChild(noteHistory);
		buttons.appendChild(cancelNoteButton);
		noteHistoryColumnContent.appendChild(buttons);
		$(this).after(noteHistoryColumnContent);
	});
});