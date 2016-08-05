ALTER TABLE competency_checklist_completion ADD COLUMN excellence tinyint(1) unsigned NOT NULL AFTER completed;

ALTER TABLE competency_checklist_completion_history ADD COLUMN excellence tinyint(1) unsigned NOT NULL AFTER completed;