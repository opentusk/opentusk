
alter table tusk.link_phase_quiz add column allow_resubmit tinyint(1) NOT NULL default '0' after child_quiz_id;
alter table tusk.link_phase_quiz_history add column allow_resubmit tinyint(1) NOT NULL default '0' after child_quiz_id;


alter table tusk.link_case_report_quiz_result add column phase_visit_id int(10) unsigned default NULL after child_quiz_result_id, add index (phase_visit_id);
alter table tusk.link_case_report_quiz_result_history add column phase_visit_id int(10) unsigned default NULL after child_quiz_result_id;


update tusk.phase_type set default_sort_order=default_sort_order+1 order by default_sort_order desc limit 1;

# need at least mysql 4.0.14 to have below insert work. if mysql version is earlier 
# than this, you will need to comment the following insert and manually give the new 
# 'Quiz' phase type the second highest value for 'default_sort_order' (the "Summary" 
# type should have the highest).
insert into tusk.phase_type (title, phase_type_object_name, default_sort_order, created_by, created_on, modified_by, modified_on) select 'Quiz', 'Quiz', max(default_sort_order)-1, 'dwalke01', now(), 'dwalke01', now() from tusk.phase_type;
