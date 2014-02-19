alter table tusk.grade_event_type add `grade_event_type_token` varchar(50) CHARACTER SET utf8 DEFAULT NULL after grade_event_type_id;

update tusk.grade_event_type set grade_event_type_token = 'quiz' where grade_event_type_name = 'Quiz';
update tusk.grade_event_type set grade_event_type_token = 'exam' where grade_event_type_name = 'Exam';
update tusk.grade_event_type set grade_event_type_token = 'assignment' where grade_event_type_name = 'Assignment';
update tusk.grade_event_type set grade_event_type_token = 'paper' where grade_event_type_name = 'Paper';
update tusk.grade_event_type set grade_event_type_token = 'project' where grade_event_type_name = 'Project';
update tusk.grade_event_type set grade_event_type_token = 'finalgrade' where grade_event_type_name = 'Final Grade';
update tusk.grade_event_type set grade_event_type_token = 'case' where grade_event_type_name = 'Case';

