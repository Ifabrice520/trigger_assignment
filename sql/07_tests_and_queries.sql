INSERT INTO system_access_attempts(username, action, client_host, user_agent, success_flag, details)
VALUES ('TEST_USER', 'LOGON', '127.0.0.1', 'SQL Developer', 'Y', 'Manual test insert to validate schema');

INSERT INTO access_violation_log(username, violation_type, target_table, action_attempt, client_info, reason)
VALUES ('TEST_USER', 'TEST_VIOLATION', 'AUCA_DATA', 'INSERT', '127.0.0.1 / SQL Developer', 'Manual test row to validate schema');

COMMIT;
