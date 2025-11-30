CREATE OR REPLACE PACKAGE BODY access_control_pkg AS

  FUNCTION is_access_allowed RETURN BOOLEAN IS
    v_day   VARCHAR2(10);
    v_hour  NUMBER;
  BEGIN
    v_day := TO_CHAR(SYSDATE, 'DY', 'NLS_DATE_LANGUAGE=ENGLISH');
    v_hour := TO_NUMBER(TO_CHAR(SYSDATE, 'HH24'));
    IF v_day IN ('SAT', 'SUN') THEN
      RETURN FALSE;
    END IF;
    IF v_hour < 8 OR v_hour >= 17 THEN
      RETURN FALSE;
    END IF;

    RETURN TRUE;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN FALSE;
  END is_access_allowed;

  PROCEDURE log_violation(
    p_username     IN VARCHAR2,
    p_violation    IN VARCHAR2,
    p_target_table IN VARCHAR2,
    p_action       IN VARCHAR2,
    p_client_info  IN VARCHAR2,
    p_reason       IN VARCHAR2
  ) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    INSERT INTO access_violation_log(
      username, violation_time, violation_type, target_table, action_attempt, client_info, reason
    ) VALUES (
      p_username, SYSTIMESTAMP, p_violation, p_target_table, p_action, p_client_info, p_reason
    );

    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END log_violation;

  PROCEDURE log_access_attempt(
    p_username     IN VARCHAR2,
    p_action       IN VARCHAR2,
    p_target_table IN VARCHAR2,
    p_client_info  IN VARCHAR2,
    p_success      IN CHAR,
    p_details      IN VARCHAR2
  ) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    INSERT INTO system_access_attempts(
      username, attempt_time, action, client_host, user_agent, success_flag, details
    ) VALUES (
      p_username,
      SYSTIMESTAMP,
      p_action,
      SUBSTR(p_client_info,1,200),
      CASE WHEN LENGTH(p_client_info) > 200 THEN SUBSTR(p_client_info,201,4000) ELSE NULL END,
      p_success,
      p_details
    );

    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END log_access_attempt;

END access_control_pkg;
/



SET SERVEROUTPUT ON
DECLARE
  v_allowed BOOLEAN;
BEGIN
  v_allowed := access_control_pkg.is_access_allowed;
  DBMS_OUTPUT.PUT_LINE('is_access_allowed = ' || CASE WHEN v_allowed THEN 'TRUE' ELSE 'FALSE' END);
END;
/


