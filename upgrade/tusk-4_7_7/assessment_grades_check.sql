SELECT school_id, parent_course_id, e.form_id, e.entry_id, form_name, e.user_id as assessor_id, ea.user_id as student_id, grade, uge.modified_on as update_on
FROM form_builder_entry_association ea, form_builder_entry e, form_builder_form f, form_builder_assessment a, 
form_builder_form_grade_event ge, link_user_grade_event uge, link_course_form cf
WHERE e.entry_id = ea.entry_id 
and e.form_id = f.form_id and a.form_id = e.form_id and ge.form_id = e.form_id and e.form_id = cf.child_form_id
and child_grade_event_id = grade_event_id and parent_user_id = ea.user_id
and complete_date is null and is_final = 1 
order by school_id, parent_course_id, form_name;
