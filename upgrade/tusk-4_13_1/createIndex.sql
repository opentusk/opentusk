ALTER TABLE tusk.form_builder_entry ADD INDEX perf_index (user_id, form_id, time_period_id);
ALTER TABLE tusk.form_builder_entry_association ADD INDEX entry_id (entry_id);
