CREATE OR REPLACE PACKAGE access_control_pkg AS
  FUNCTION is_access_allowed RETURN BOOLEAN;
  PROCEDURE log_violation(
    p_username     IN VARCHAR2,
    p_violation    IN VARCHAR2,
    p_target_table IN VARCHAR2,
    p_action       IN VARCHAR2,
    p_client_info  IN VARCHAR2,
    p_reason       IN VARCHAR2
  );
  PROCEDURE log_access_attempt(
    p_username     IN VARCHAR2,
    p_action       IN VARCHAR2,
    p_target_table IN VARCHAR2,
    p_client_info  IN VARCHAR2,
    p_success      IN CHAR,       
    p_details      IN VARCHAR2
  );
END access_control_pkg;
/
