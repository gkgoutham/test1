
# Device Management & Certificate Lifecycle — Full Test Plan (Automatable)
**Generated:** Comprehensive list of 70+ scenarios and combinations for Create → Enroll → Renew → Delete flows.
Use this file as the definitive test plan and the companion bash script to run the scenarios and export CSV results.

---

## API Endpoints
```
POST /v1/device-management/devices                 → Create Device
POST /v2/enroll                                     → Enroll Certificate (v2)
POST /v3/enroll                                     → Enroll Certificate (v3)
POST /v1/renew                                      → Renew Certificate (v1)
POST /v2/renew                                      → Renew Certificate (v2)
POST /v3/renew                                      → Renew Certificate (v3)
DELETE /device-mgmt/devices/{deviceId}              → Single Delete
POST /device-mgmt/devices/batch-delete              → Batch Delete
POST /uaa/oauth/token                                → UAA token endpoint (OAuth2 password/client_credentials)
```

---

## 1. Scope
- Functional tests for device & certificate lifecycle.
- Version compatibility, order-of-operations, negative and edge cases.
- Concurrency & basic performance scenarios.
- Test runner script will perform the flows and log results to CSV.

Not included: UI E2E, full auth-server testing beyond token retrieval, PKI internals.

---

## 2. Master Scenario List (1..70)
Each scenario is written as: **ID. Short title — Expected result summary**

### Device Creation (1–8)
1. Create device with valid payload — 201 Created, device stored.  
2. Create multiple devices sequentially — All succeed.  
3. Create device & immediately enroll (v2) — Enroll success after create.  
4. Create device with missing required fields — 4xx error.  
5. Create device with invalid data types — 4xx error.  
6. Create device with duplicate deviceId — 409 or defined duplicate behavior.  
7. Create device when DB is unavailable — 5xx / error (transient).  
8. Recreate a previously deleted device (same id) — Accept/reject based on design (test both if allowed).

### Enrollment (9–21)
9. Enroll existing device using v2 — 200 success, certificate returned.  
10. Enroll existing device using v3 — 200 success.  
11. Re-enroll after renewal (valid) — 200 success.  
12. Enroll v2 then re-enroll using v3 — Verify compatibility or failure.  
13. Enroll v3 then re-enroll using v2 — Verify compatibility or failure.  
14. Enroll with payload format mismatch (v2 JSON to v3 endpoint) — 4xx.  
15. Enroll a non-existent deviceId — 404 / error.  
16. Enroll a deleted device — 4xx/404.  
17. Enroll with expired CSR — 4xx/invalid CSR.  
18. Enroll with malformed CSR — 4xx.  
19. Enrollment service down — 5xx / timeout.  
20. Duplicate enrollment (enroll twice without renewal) — idempotency or error.  
21. Enroll with invalid JSON body — 400 Bad Request.

### Renewal (22–35)
22. Enroll v2 → Renew using v1 — new certificate issued (if compatible).  
23. Enroll v2 → Renew using v2 — success.  
24. Enroll v3 → Renew using v3 — success.  
25. Renew just before expiry — success.  
26. Renew after expiry (past expiry) — behavior depends on policy (test both expected).  
27. Enroll v2 → Renew v3 — compatibility check.  
28. Enroll v3 → Renew v1 — compatibility check.  
29. Enroll v3 → Renew v2 — compatibility check.  
30. Renew without enrollment — 4xx / error.  
31. Renew with invalid certificate ID — 404 / error.  
32. Renew non-existing device — 404 / error.  
33. Renew deleted device — 4xx / error.  
34. Renew with corrupted certificate data — 4xx/5xx.  
35. Renewal service down — 5xx / timeout.

### Delete (36–42)
36. Delete device after successful renew — 200 or 204; certificate revoked.  
37. Delete a newly created device — 200/204.  
38. Delete device with active certificate — certificate revoked (verify).  
39. Delete non-existing device — 404.  
40. Delete device twice — second call returns 404 or idempotent success.  
41. DB down during delete — 5xx.  
42. Delete while enrollment/renewal in progress — race condition handling.

### Batch Delete (43–50)
43. Batch delete 5 devices — all deleted, success details.  
44. Batch delete 1 device — success.  
45. Batch delete large set (100+) — performance check.  
46. Batch delete with mixed valid & invalid ids — partial success with errors for invalid.  
47. Batch delete all invalid ids — errors for all.  
48. Batch delete with empty list — 400 or no-op.  
49. Batch delete with duplicate ids in input — ensure idempotency or defined behavior.  
50. Batch delete while cert service down — partial failure / rollback or partial success.

### Mixed-Flow / Order-of-Operations (51–59)
51. Create → Enroll (v2) → Renew (v1) → Delete — happy path.  
52. Create → Enroll (v3) → Renew (v3) → Renew (v2) → Delete — multi-version happy path.  
53. Create → Enroll (v2) → Delete → Recreate same device → Enroll (v3) — recreate flow.  
54. Create → Renew without enroll — expected failure.  
55. Delete → Renew — failure.  
56. Delete → Enroll — depending on design, create or fail.  
57. Enroll → Delete → Re-enroll — ensure deletion cleared previous state.  
58. Renew → Delete → Renew — verify proper errors after delete.  
59. Enroll v3 → Enroll v2 (double-enroll different versions) — compatibility or reject.

### Security & Auth (60–63)
60. API calls with no token — 401 Unauthorized.  
61. API calls with expired token — 401 Unauthorized.  
62. API call with insufficient permissions — 403 Forbidden.  
63. Tampered certificate/CSR request — 4xx/403 depending on validation.

### Performance & Concurrency (64–70)
64. Concurrent enroll of 50 devices — check throughput and failures.  
65. Concurrent renew of 200 devices — load behavior.  
66. Batch delete occurring during active enrolls — race conditions.  
67. 1000 renew requests per minute (stress) — observe rate limiting.  
68. Repeated create/delete cycles for same device id — stability.  
69. Simultaneous requests for same device (create vs delete vs enroll) — concurrency correctness.  
70. Enroll many devices then batch delete in chunks — cleanup under load.

---

## 3. Combination Matrix (Table)
Below is an exhaustive table for many combination flavours. For readability this table lists the **main combination scenarios** and the expected result. Use this as the baseline matrix to compare against runtime CSV produced by the runner script.

| ID | Create | Enroll v2 | Enroll v3 | Renew v1 | Renew v2 | Renew v3 | Delete | Short description / expected |
|----|--------|-----------|-----------|----------|----------|----------|--------|------------------------------|
| 1  | ✔ | ✔ | ✖ | ✔ | ✖ | ✖ | ✔ | Create → Enroll v2 → Renew v1 → Delete |
| 2  | ✔ | ✖ | ✔ | ✖ | ✔ | ✖ | ✔ | Create → Enroll v3 → Renew v2 → Delete |
| 3  | ✔ | ✔ | ✖ | ✖ | ✔ | ✔ | ✔ | Create → Enroll v2 → Renew v2 & v3 → Delete |
| 4  | ✔ | ✔ | ✔ | ✔ | ✔ | ✔ | ✔ | All versions exercised in order |
| 5  | ✖ | ✔ | ✔ | ✔ | ✔ | ✔ | ✔ | Enroll without create — should fail |
| 6  | ✔ | ✖ | ✖ | ✔ | ✔ | ✔ | ✖ | Renew without enroll — should fail |
| 7  | ✔ | ✔ | ✖ | ✔ | ✔ | ✖ | ✖ | Partial cycle, no delete |
| 8  | ✔ | ✔ | ✖ | ✔ | ✖ | ✔ | ✔ | Mixed renew paths |
| 9  | ✔ | ✖ | ✔ | ✔ | ✖ | ✔ | ✔ | v3-first flow, then renew |
| 10 | ✔ | ✔ | ✔ | ✖ | ✖ | ✖ | ✔ | Multi-enroll attempts expected to be rejected |

> The runner script will output for each scenario a CSV row summarizing actions and their HTTP result codes and short messages.

---

## 4. Detailed Test Case Template (for reference)
Use this template to expand any scenario into step-by-step test cases:

```
### TC-XXX Title
**Description:** short description
**Preconditions:** device existence, tokens, etc.
**Steps:**
  1. Call endpoint X with payload Y
  2. Verify response Z
**Expected result:** HTTP status, response fields, DB changes
```

---

## 5. Companion Bash Script (overview)
A single executable bash script is included that accepts variables (UAA URL, credentials, API base URL, output CSV path). It will:

- Obtain OAuth token from UAA (client_credentials or password grant as configured)  
- Create devices with generated ids (or fixed seeds)  
- Call enroll endpoints (v2/v3) and renew endpoints (v1/v2/v3) according to scenario list  
- Call delete and batch-delete as required  
- Record each step result into a CSV: `scenario_id,device_id,action,endpoint,http_code,short_message`  
- Output final CSV for comparison with the Master Matrix

> The script assumes `curl`, `jq`, and `uuidgen` are available on the machine.

---

## 6. Files included with this plan
- `test_plan.md` (this file)  
- `run_device_lifecycle_tests.sh` (bash runner, executable)  
- `results.csv` (output when runner executed)

---

### End of plan
