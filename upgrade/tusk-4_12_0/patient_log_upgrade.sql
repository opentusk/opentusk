use tusk;

INSERT INTO form_builder_field_type VALUES (0, "ConfidentialPatientIdentifier", "Confidential Patient Identifier", "script", now(), "script", now());

SELECT * FROM form_builder_field WHERE field_name = "Confidential Identifier";

UPDATE form_builder_field SET field_type_id = (SELECT field_type_id FROM form_builder_field_type where token = "ConfidentialPatientIdentifier") WHERE field_name = "Confidential Identifier";

