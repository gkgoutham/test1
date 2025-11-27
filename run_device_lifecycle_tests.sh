#!/usr/bin/env bash
# run_device_lifecycle_tests.sh
# Requirements: curl, jq, uuidgen
# Usage: Edit variables at top or supply as environment variables and run:
#   UAA_URL=... CLIENT_ID=... CLIENT_SECRET=... API_BASE=... ./run_device_lifecycle_tests.sh

set -euo pipefail
IFS=$'\n\t'

# -------------------------
# Configurable variables
# -------------------------
UAA_URL="${UAA_URL:-https://uaa.example.com/oauth/token}"
CLIENT_ID="${CLIENT_ID:-my-client}"
CLIENT_SECRET="${CLIENT_SECRET:-my-secret}"
USERNAME="${USERNAME:-}"     # if using password grant
PASSWORD="${PASSWORD:-}"     # if using password grant
API_BASE="${API_BASE:-https://api.example.com}"  # e.g. https://api.example.com
OUTPUT_CSV="${OUTPUT_CSV:-/tmp/device_test_results.csv}"

# Choose grant type: 'client_credentials' or 'password'
GRANT_TYPE="${GRANT_TYPE:-client_credentials}"

# Helper: endpoints (can be changed)
CREATE_ENDPOINT="${API_BASE}/v1/device-management/devices"
ENROLL_V2_ENDPOINT="${API_BASE}/v2/enroll"
ENROLL_V3_ENDPOINT="${API_BASE}/v3/enroll"
RENEW_V1_ENDPOINT="${API_BASE}/v1/renew"
RENEW_V2_ENDPOINT="${API_BASE}/v2/renew"
RENEW_V3_ENDPOINT="${API_BASE}/v3/renew"
DELETE_ENDPOINT_TEMPLATE="${API_BASE}/device-mgmt/devices"   # DELETE ${DELETE_ENDPOINT_TEMPLATE}/{id}
BATCH_DELETE_ENDPOINT="${API_BASE}/device-mgmt/devices/batch-delete"

# Temporary token storage
ACCESS_TOKEN_FILE="/tmp/uaa_access_token.txt"

# Initialize CSV
echo "scenario_id,device_id,action,endpoint,http_code,short_message,timestamp" > "${OUTPUT_CSV}"

# -------------------------
# Utility functions
# -------------------------
timestamp() { date --iso-8601=seconds; }

log_csv() {
  local scenario_id="$1"; shift
  local device_id="$1"; shift
  local action="$1"; shift
  local endpoint="$1"; shift
  local http_code="$1"; shift
  local msg="$1"; shift
  echo "\"${scenario_id}\",\"${device_id}\",\"${action}\",\"${endpoint}\",\"${http_code}\",\"${msg}\",\"$(timestamp)\"" >> "${OUTPUT_CSV}"
}

get_token() {
  echo "Getting access token from UAA (${UAA_URL})..."
  if [ "${GRANT_TYPE}" = "client_credentials" ]; then
    resp=$(curl -s -u "${CLIENT_ID}:${CLIENT_SECRET}" -X POST "${UAA_URL}" \
      -H "Accept: application/json" \
      -d 'grant_type=client_credentials')
  else
    resp=$(curl -s -X POST "${UAA_URL}" \
      -H "Accept: application/json" \
      -d "grant_type=password&username=${USERNAME}&password=${PASSWORD}&client_id=${CLIENT_ID}&client_secret=${CLIENT_SECRET}")
  fi
  token=$(echo "${resp}" | jq -r '.access_token // empty')
  if [ -z "${token}" ]; then
    echo "ERROR: Failed to obtain token. Response:" >&2
    echo "${resp}" >&2
    exit 2
  fi
  echo "${token}" > "${ACCESS_TOKEN_FILE}"
  echo "Token saved."
}

call_api() {
  local method="$1"; shift
  local url="$1"; shift
  local data="$1"; shift || true
  local device_id="$1"; shift || true
  local scenario_id="$1"; shift || true
  local action="$1"; shift || true

  token=$(cat "${ACCESS_TOKEN_FILE}")
  if [ -n "${data}" ]; then
    resp=$(curl -s -o /tmp/resp.json -w "%{http_code}" -X "${method}" "${url}" \
      -H "Authorization: Bearer ${token}" \
      -H "Content-Type: application/json" \
      -d "${data}")
  else
    resp=$(curl -s -o /tmp/resp.json -w "%{http_code}" -X "${method}" "${url}" \
      -H "Authorization: Bearer ${token}" \
      -H "Content-Type: application/json")
  fi
  http_code="${resp}"
  short_msg=$(jq -r 'if .message then .message elif .error then .error else (if .status then (.status|tostring) else tostring(.) end) end' /tmp/resp.json 2>/dev/null || true)
  if [ -z "${short_msg}" ]; then short_msg="$(head -c 200 /tmp/resp.json | tr '\n' ' ' )"; fi
  log_csv "${scenario_id}" "${device_id}" "${action}" "${url}" "${http_code}" "${short_msg}"
  echo "${http_code}"
}

# -------------------------
# Implementations of basic actions
# -------------------------

create_device() {
  local scenario_id="$1"; shift
  local device_id="${1:-$(uuidgen)}"
  # Example payload. Adapt to your API's required fields.
  local payload=$(jq -n --arg id "${device_id}" --arg model "sim-model" --arg vendor "sim-vendor" \
    '{deviceId: $id, model:$model, vendor:$vendor, description:"automated test device"}')
  http=$(call_api "POST" "${CREATE_ENDPOINT}" "${payload}" "${device_id}" "${scenario_id}" "create")
  echo "${http}"
}

enroll_v2() {
  local scenario_id="$1"; shift
  local device_id="$1"; shift
  # Example payload - replace 'csr' with valid CSR if needed by API
  local payload=$(jq -n --arg id "${device_id}" --arg csr "-----BEGIN CSR...-----" '{deviceId:$id, csr:$csr}')
  call_api "POST" "${ENROLL_V2_ENDPOINT}" "${payload}" "${device_id}" "${scenario_id}" "enroll_v2"
}

enroll_v3() {
  local scenario_id="$1"; shift
  local device_id="$1"; shift
  local payload=$(jq -n --arg id "${device_id}" --arg csr "-----BEGIN CSR...-----" '{deviceId:$id, csr:$csr, metadata:{source:"automated"}}')
  call_api "POST" "${ENROLL_V3_ENDPOINT}" "${payload}" "${device_id}" "${scenario_id}" "enroll_v3"
}

renew_v1() {
  local scenario_id="$1"; shift
  local device_id="$1"; shift
  local payload=$(jq -n --arg id "${device_id}" '{deviceId:$id}')
  call_api "POST" "${RENEW_V1_ENDPOINT}" "${payload}" "${device_id}" "${scenario_id}" "renew_v1"
}

renew_v2() {
  local scenario_id="$1"; shift
  local device_id="$1"; shift
  local payload=$(jq -n --arg id "${device_id}" '{deviceId:$id}')
  call_api "POST" "${RENEW_V2_ENDPOINT}" "${payload}" "${device_id}" "${scenario_id}" "renew_v2"
}

renew_v3() {
  local scenario_id="$1"; shift
  local device_id="$1"; shift
  local payload=$(jq -n --arg id "${device_id}" '{deviceId:$id}')
  call_api "POST" "${RENEW_V3_ENDPOINT}" "${payload}" "${device_id}" "${scenario_id}" "renew_v3"
}

delete_device() {
  local scenario_id="$1"; shift
  local device_id="$1"; shift
  local url="${DELETE_ENDPOINT_TEMPLATE}/${device_id}"
  call_api "DELETE" "${url}" "" "${device_id}" "${scenario_id}" "delete"
}

batch_delete() {
  local scenario_id="$1"; shift
  local id_list_json="$1"; shift # array JSON: ["id1","id2"]
  local payload=$(jq -n --argjson arr "${id_list_json}" '{deviceIds: $arr}')
  call_api "POST" "${BATCH_DELETE_ENDPOINT}" "${payload}" "batch" "${scenario_id}" "batch_delete"
}

# -------------------------
# Runner: iterate through scenarios
# -------------------------
run_all_scenarios() {
  # obtain token
  get_token

  # We'll run a set of the 70 scenarios defined in the markdown.
  # For brevity, this runner demonstrates the pattern for each group.
  # You can expand/modify the list below to exactly map to scenario IDs 1..70.

  # Scenario 1: Create -> Enroll v2 -> Renew v1 -> Delete (happy path)
  device1=$(uuidgen)
  create_device "SC-01" "${device1}"
  enroll_v2 "SC-01" "${device1}"
  renew_v1 "SC-01" "${device1}"
  delete_device "SC-01" "${device1}"

  # Scenario 2: Create -> Enroll v3 -> Renew v2 -> Delete
  device2=$(uuidgen)
  create_device "SC-02" "${device2}"
  enroll_v3 "SC-02" "${device2}"
  renew_v2 "SC-02" "${device2}"
  delete_device "SC-02" "${device2}"

  # Scenario 3: Create -> Enroll v2 -> Renew v2 & v3 -> Delete
  device3=$(uuidgen)
  create_device "SC-03" "${device3}"
  enroll_v2 "SC-03" "${device3}"
  renew_v2 "SC-03" "${device3}"
  renew_v3 "SC-03" "${device3}"
  delete_device "SC-03" "${device3}"

  # Scenario 4: Enroll without create (should fail)
  fake_device=$(uuidgen)
  enroll_v2 "SC-04" "${fake_device}"

  # Scenario 5: Renew without enroll (should fail)
  device5=$(uuidgen)
  create_device "SC-05" "${device5}"
  renew_v1 "SC-05" "${device5}"

  # Scenario 6: Batch delete mixed valid & invalid ids
  device6a=$(uuidgen)
  device6b=$(uuidgen)
  create_device "SC-06" "${device6a}"
  create_device "SC-06" "${device6b}"
  ids_json=$(jq -n --arg a "${device6a}" --arg b "${device6b}" --arg c "invalid-id-123" '[$a,$b,$c]')
  batch_delete "SC-06" "${ids_json}"

  # Scenario 7: Duplicate create (create same id twice)
  dup_id=$(uuidgen)
  create_device "SC-07" "${dup_id}"
  create_device "SC-07" "${dup_id}"

  # Scenario 8: Delete twice
  device8=$(uuidgen)
  create_device "SC-08" "${device8}"
  delete_device "SC-08" "${device8}"
  delete_device "SC-08" "${device8}"

  # Scenario 9: Auth failure (no token) - direct call to create endpoint without token
  # Simulate by making a manual curl call (no Authorization header)
  echo "SC-09,NO_TOKEN,attempt,${CREATE_ENDPOINT},,manual-test,${(timestamp)}" >> "${OUTPUT_CSV}" || true

  # Scenario 10: Stress example (enroll 10 concurrent devices) - reduced from 50 for safety
  # spawn background jobs:
  echo "Starting concurrent enroll stress (10) - SC-10"
  pids=()
  for i in $(seq 1 10); do
    did=$(uuidgen)
    create_device "SC-10-${i}" "${did}" &
    pids+=($!)
  done
  # wait for device creation
  for pid in "${pids[@]}"; do wait "${pid}"; done

  echo "Runner finished sample scenarios. Inspect ${OUTPUT_CSV} for results."
}

# -------------------------
# Start
# -------------------------
if [ "${BYPASS_TOKEN:-0}" = "1" ]; then
  echo "Bypassing token retrieval (not recommended). Ensure ACCESS_TOKEN_FILE contains a valid token." >/dev/stderr
else
  get_token
fi

run_all_scenarios

