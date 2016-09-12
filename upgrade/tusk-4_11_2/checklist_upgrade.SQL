USE tusk;

ALTER TABLE competency_checklist_entry ADD COLUMN excellence tinyint(1) unsigned NOT NULL AFTER complete_date;

ALTER TABLE competency_checklist_entry_history ADD COLUMN excellence tinyint(1) unsigned NOT NULL AFTER complete_date;