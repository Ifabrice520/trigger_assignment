# AUCA Database Security Implementation  
**Combined Assignment Submission**


**Institution:** African University of Central Africa (AUCA)  
**Date:** 11 2025  


---

## I. Scenario 1:(Q1) AUCA System Access Control Policy  
### Business Rules Enforced
1. **No access allowed on Sabbath** → Saturday and Sunday completely blocked  
2. **Working hours only** → Monday to Friday, 08:00 AM – 05:00 PM (17:00)  
3. Any DML attempt (INSERT, UPDATE, DELETE) outside allowed time/day → **automatically blocked**  
4. Every violation attempt → **logged instantly** for audit and investigation  

### Solution Delivered
- **Trigger 1 (Enforcement):** BEFORE STATEMENT trigger that checks current day and time. Raises custom error (ORA-20001) to **prevent** the operation if outside policy.  
- **Trigger 2 (Auditing):** Logs every blocked attempt into `access_violations_log` table with:  
  → Username, Timestamp, Attempted action, Client IP/Host, Reason (e.g., “Access denied – Sabbath”, “Outside working hours”)  

**Result:** Zero unauthorized data changes + full audit trail.

---

## II. Scenario 2:(Q3) Suspicious Login Behavior Monitoring  
### Security Policy
> “If any user attempts to log in **more than twice** with incorrect credentials **on the same day**, the system must **immediately trigger a security alert**.”

### Solution Delivered
1. **`login_audit` table**  
   Records every login attempt (success or failed) with:  
   → Username, Attempt time, Status (SUCCESS/FAILED), IP address  

2. **`security_alerts` table**  
   Stores critical alerts with:  
   → Username, Number of failed attempts, Alert time, Alert message, Notification email  

3. **Smart Trigger (trg_failed_login_alert)**  
   - Fires only on FAILED logins  
   - Counts failed attempts for that user **today**  
   - When count > 2 → inserts **one alert per user per day**  
   - Uses **autonomous transaction** → cleanly avoids ORA-04091 mutating table error  
    

**Result:** Immediate detection of potential brute-force attacks with clean, actionable alerts.

---

## Final Status
| Requirement                            | Status    | Notes                              |
|----------------------------------------|-----------|------------------------------------|
| Sabbath & working hours enforcement   | Completed | Fully blocked + logged             |
| Unauthorized access prevention         | Completed | Real-time rejection                |
| Login failure monitoring               | Completed | >2 fails → alert generated         |
| Audit trail for violations             | Completed | Full logging in both cases         |
| No trigger errors (mutating, etc.)     | Completed | Solved using best practices        |
| One alert per user per day             | Completed | No duplicates                      |

**All requirements from both scenarios successfully implemented and tested.**

# Images
## 02 desc system access attempts
![image description](screenshots/02_desc_system_access_attempts.PNG)

## 03 desc access violation log
![image description]( screenshots/03_desc_access_violation_log.PNG)
## 04 test inserts result
![image description]( screenshots/04_test_inserts_result.PNG)

## 06 package body compiled
![image description]( screenshots/06_package_body_compiled.PNG)

## 06 package spec compiled
![image description]( screenshots/06_package_spec_compiled.PNG)

## 07 is access allowed check
![image description]( screenshots/07_is_access_allowed_check.PNG)

## 09 blocked insert error
![image description]( screenshots/09_blocked_insert_error.PNG)
## 12 auca data rows
![image description]( screenshots/12_auca_data_rows.PNG)

## 14 system access attempts_after fix 1
![image description]( screenshots/14_system_access_attempts_after_fix_1.PNG)

## 14 system access attempts_after fix 2
![image description]( screenshots/14_system_access_attempts_after_fix_2.PNG)

## Q3 trigger implementation
![image description]( screenshots/Q3_trigger_implementation.png)

## Q3 trigger screation
![image description]( screenshots/Q3_trigger_screation.png)

## create access violation log table
![image description]( screenshots/create_access_violation_log_table.PNG)

## create system access attempts table
![image description]( screenshots/create_system_access_attempts_table.PNG)

## output for creating tables
![image description]( screenshots/output_for_creating_tables.PNG)

---
