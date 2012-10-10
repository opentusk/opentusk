$(function() {
	$('#emailsubmit').click(function() {
		if (!$('input[name="to"]:checked').length) {
			alert('Please select at least one email recipient.');
			return false;
		}

		if (confirm("Are you sure you want to send this email?") == false) {
			return false;
		}
	});

	$("input[name='checkall']").click(function() {
		var newval = $(this).attr('checked');
		$("input[name='to']").each(function() {
			$(this).attr('checked', newval);
		});
	});

	$("input[name='to']").click(function() {
		var checkall_flag = true;
		$("input[name='to']").each(function() {
			if ($(this).attr('checked') == false) {
				checkall_flag = false;
				return;
			}
		});
		$("input[name='checkall']").attr('checked', checkall_flag);
	});

});

