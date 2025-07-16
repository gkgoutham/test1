import os
import json
import csv
from pathlib import Path

input_dir = Path("waf_json_logs")
output_dir = Path("waf_csv_output")
output_dir.mkdir(exist_ok=True)

# Common fields to extract
default_fields = [
    "timestamp", "action", "ruleGroupId", "matchedRuleId",
    "httpRequest.host", "httpRequest.uri", "httpRequest.httpMethod",
    "httpRequest.clientIp", "httpRequest.headers.user-agent"
]

def extract_field(log, field_path):
    keys = field_path.split(".")
    val = log
    for k in keys:
        if isinstance(val, dict) and k in val:
            val = val[k]
        else:
            return ""
    return val

def extract_all_matched_data(log):
    matched = []

    # 1. terminatingRuleMatchDetails
    for detail in log.get("terminatingRuleMatchDetails", []):
        matched += [m.get("data", "") for m in detail.get("matchedData", [])]

    # 2. nonTerminatingMatchingRules in ruleGroupList
    for group in log.get("ruleGroupList", []):
        rules = group.get("nonTerminatingMatchingRules", {}).get("items", [])
        for rule in rules:
            for detail in rule.get("ruleMatchDetails", []):
                matched += [m.get("data", "") for m in detail.get("matchedData", [])]

    return ";".join(filter(None, matched))

# Process each .json file
for file_path in input_dir.glob("*.json"):
    rule_name = file_path.stem
    output_csv = output_dir / f"{rule_name}.csv"
    rows = []

    with open(file_path, 'r') as f:
        for line in f:
            try:
                log = json.loads(line.strip())
                row = {field: extract_field(log, field) for field in default_fields}
                row['matchedData'] = extract_all_matched_data(log)
                rows.append(row)
            except json.JSONDecodeError:
                continue

    # Write CSV
    if rows:
        with open(output_csv, 'w', newline='') as f:
            writer = csv.DictWriter(f, fieldnames=rows[0].keys())
            writer.writeheader()
            writer.writerows(rows)
        print(f"✅ {output_csv.name} written with {len(rows)} rows")
    else:
        print(f"⚠️ No valid logs in {file_path.name}")