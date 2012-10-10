-- This  script adds the necessary permissions table entries to support isolated permissions for the quiz completion functionality (TUS-1353).
INSERT INTO tusk.permission_function VALUES (default, 'quiz_completion', 'View quiz completion lists, email noncompleters', 'scorbe01', now(), 'scorbe01', now());
INSERT INTO tusk.permission_role_function VALUES (default, 1, (SELECT function_id FROM tusk.permission_function WHERE function_token = 'quiz_completion'), 'scorbe01', now(), 'scorbe01', now());
