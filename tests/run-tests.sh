#!/usr/bin/env bash
# run-tests.sh - check every rule in the matrix (docs/ip-plan.md).
# From each zone we try to connect and compare the result with what we expect.
# Usage: sudo ./tests/run-tests.sh | tee docs/test-results.md
set -uo pipefail

if [[ $EUID -ne 0 ]]; then
    echo "Run as root: sudo $0" >&2
    exit 1
fi

declare -A IP=(
    [staff]=10.10.10.10   [servers]=10.10.20.10  [dmz]=10.10.30.10
    [guests]=10.10.40.10  [management]=10.10.99.10 [internet]=203.0.113.10
)

# Every zone (and the firewall) listens on every test port. A blocked
# connection is then always the firewall's doing, never "nobody listening".
PIDS=()
cleanup() { for p in "${PIDS[@]}"; do kill "$p" 2>/dev/null; done; }
trap cleanup EXIT
for z in staff servers dmz guests management internet fw; do
    for port in 22 80 443 445; do
        ip netns exec "$z" nc -lk "$port" >/dev/null 2>&1 &
        PIDS+=($!)
    done
done
sleep 1

PASS=0
FAIL=0

report() {   # report <from> <to> <expected> <actual>
    local result=PASS
    if [[ $3 != "$4" ]]; then result=FAIL; FAIL=$((FAIL + 1)); else PASS=$((PASS + 1)); fi
    printf "| %-10s | %-22s | %-8s | %-8s | %s |\n" "$1" "$2" "$3" "$4" "$result"
}

check() {    # check <from-zone> <to-zone-or-ip> <port> <ALLOW|BLOCK>
    local dst=${IP[$2]:-$2}
    local actual=BLOCK
    ip netns exec "$1" nc -z -w 1 "$dst" "$3" >/dev/null 2>&1 && actual=ALLOW
    report "$1" "$2:$3" "$4" "$actual"
}

checkping() {   # checkping <from-zone> <to-zone-or-ip> <ALLOW|BLOCK>
    local dst=${IP[$2]:-$2}
    local actual=BLOCK
    ip netns exec "$1" ping -c 1 -W 1 "$dst" >/dev/null 2>&1 && actual=ALLOW
    report "$1" "$2 (ping)" "$3" "$actual"
}

echo "| From | To | Expected | Actual | Result |"
echo "|---|---|---|---|---|"

# --- Should be allowed ---
check staff servers 445 ALLOW
check staff dmz 80 ALLOW
check staff dmz 443 ALLOW
check staff internet 80 ALLOW
check staff internet 443 ALLOW
check management staff 22 ALLOW
check management servers 22 ALLOW
check management dmz 22 ALLOW
check management internet 80 ALLOW
check guests internet 80 ALLOW
check internet 203.0.113.1 80 ALLOW
check internet 203.0.113.1 443 ALLOW
checkping management staff ALLOW
checkping management servers ALLOW
checkping management dmz ALLOW

# --- Should be blocked ---
check staff servers 22 BLOCK
check staff dmz 22 BLOCK
check staff guests 80 BLOCK
check staff management 22 BLOCK
check staff internet 22 BLOCK
check servers staff 445 BLOCK
check servers dmz 80 BLOCK
check servers internet 80 BLOCK
check dmz staff 80 BLOCK
check dmz servers 445 BLOCK
check dmz management 22 BLOCK
check dmz internet 80 BLOCK
check guests staff 80 BLOCK
check guests servers 445 BLOCK
check guests dmz 80 BLOCK
check guests management 22 BLOCK
check guests internet 22 BLOCK
check management guests 22 BLOCK
check internet staff 80 BLOCK
check internet servers 445 BLOCK
check internet dmz 80 BLOCK
check internet management 22 BLOCK
check internet 203.0.113.1 22 BLOCK
checkping staff 10.10.10.1 BLOCK
checkping guests management BLOCK
checkping dmz management BLOCK

echo
echo "Passed: $PASS, failed: $FAIL"
[[ $FAIL -eq 0 ]]
