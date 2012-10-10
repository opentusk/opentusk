alter table form_builder_assessment add min_score float unsigned NULL after total_weight;
alter table form_builder_assessment_history add min_score float unsigned NULL after total_weight;
alter table form_builder_assessment add show_grade_to_assessor tinyint(1) unsigned NOT NULL default '0' after min_score;
alter table form_builder_assessment_history add show_grade_to_assessor tinyint(1) unsigned NOT NULL default '0' after min_score;
alter table form_builder_assessment add show_grade_to_subject tinyint(1) unsigned NOT NULL default '0' after show_grade_to_assessor;
alter table form_builder_assessment_history add show_grade_to_subject tinyint(1) unsigned NOT NULL default '0' after show_grade_to_assessor;
alter table form_builder_assessment add show_grade_to_registrar tinyint(1) unsigned NOT NULL default '0' after show_grade_to_subject;
alter table form_builder_assessment_history add show_grade_to_registrar tinyint(1) unsigned NOT NULL default '0' after show_grade_to_subject;
