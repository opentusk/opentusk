-- This adds the columns needed for TUS-43. 
ALTER TABLE tusk.assignment ADD COLUMN sort_order smallint(6) unsigned NOT NULL default 0 AFTER resubmit_flag;
ALTER TABLE tusk.assignment_history ADD COLUMN sort_order smallint(6) unsigned NOT NULL default 0 AFTER resubmit_flag;
