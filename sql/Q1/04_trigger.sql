CREATE OR REPLACE TRIGGER trg_auca_data_access_control
  BEFORE INSERT OR UPDATE OR DELETE ON auca_data
  FOR EACH ROW
DECLARE
  v_username    VARCHAR2(128) := NVL(USER, 'UNKNOWN');
  v_action      VARCHAR2(20);
  v_clientinfo  VARCHAR2(4000);
  v_allowed     BOOLEAN;
BEGIN
  IF INSERTING THEN v_action := 'INSERT';
  ELSIF UPDATING THEN v_action := 'UPDATE';
  ELSIF DELETING THEN v_action := 'DELETE';
  END IF;
  v_clientinfo := NVL(SYS_CONTEXT('USERENV','IP_ADDRESS'), 'unknown_ip')
                  || ' / ' || NVL(SYS_CONTEXT('USERENV','OS_USER'), 'unknown_os_user')
                  || ' / ' || NVL(SYS_CONTEXT('USERENV','MODULE'), 'unknown_module');

  v_allowed := access_control_pkg.is_access_allowed;

  IF NOT v_allowed THEN
    access_control_pkg.log_violation(
      p_username     => v_username,
      p_violation    => 'OUTSIDE_ALLOWED_HOURS_OR_SABBATH',
      p_target_table => 'AUCA_DATA',
      p_action       => v_action,
      p_client_info  => v_clientinfo,
      p_reason       => 'Attempt blocked by AUCA policy (Mon–Fri 08:00–17:00)'
    );
    access_control_pkg.log_access_attempt(
      p_username     => v_username,
      p_action       => v_action,
      p_target_table => 'AUCA_DATA',
      p_client_info  => v_clientinfo,
      p_success      => 'N',
      p_details      => 'Blocked by policy'
    );
    RAISE_APPLICATION_ERROR(-20001, 'Access denied: outside allowed days/hours per AUCA system access policy');
  END IF;
  access_control_pkg.log_access_attempt(
    p_username     => v_username,
    p_action       => v_action,
    p_target_table => 'AUCA_DATA',
    p_client_info  => v_clientinfo,
    p_success      => 'Y',
    p_details      => 'Allowed by policy'
  );

EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE = -20001 THEN
      RAISE;
    END IF;
    BEGIN
      access_control_pkg.log_violation(
        p_username     => v_username,
        p_violation    => 'TRIGGER_ERROR',
        p_target_table => 'AUCA_DATA',
        p_action       => v_action,
        p_client_info  => v_clientinfo,
        p_reason       => 'Trigger runtime error: ' || SUBSTR(SQLERRM,1,500)
      );
    EXCEPTION WHEN OTHERS THEN NULL;
    END;

    RAISE_APPLICATION_ERROR(-20002, 'Access control error: contact DBA. ' || SUBSTR(SQLERRM,1,200));
END trg_auca_data_access_control;
/
