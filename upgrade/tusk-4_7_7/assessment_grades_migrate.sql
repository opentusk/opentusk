/*
INSERT INTO form_builder_entry_grade
SELECT 0,  e.entry_id, grade, uge.comments, uge.created_by, uge.created_on, uge.modified_by, uge.modified_on
FROM form_builder_entry_association ea, form_builder_entry e, form_builder_assessment a, form_builder_form_grade_event ge, link_user_grade_event uge
WHERE e.entry_id = ea.entry_id 
and a.form_id = e.form_id and ge.form_id = e.form_id
and child_grade_event_id = grade_event_id and parent_user_id = ea.user_id
and complete_date is null and is_final = 1;
*/

DELETE FROM link_user_grade_event
WHERE link_user_grade_event_id IN (
SELECT * FROM (
    SELECT link_user_grade_event_id
    FROM form_builder_entry_association ea, form_builder_entry e, form_builder_assessment a, form_builder_form_grade_event ge, link_user_grade_event uge
    WHERE e.entry_id = ea.entry_id 
    and a.form_id = e.form_id and ge.form_id = e.form_id
    and child_grade_event_id = grade_event_id and parent_user_id = ea.user_id
    and complete_date is null and is_final = 1
) as t);