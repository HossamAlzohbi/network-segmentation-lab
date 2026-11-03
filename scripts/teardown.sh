#!/usr/bin/env bash
# teardown.sh - remove the whole lab. Deleting a namespace also removes
# the virtual cables and firewall rules inside it.
set -uo pipefail

if [[ $EUID -ne 0 ]]; then
    echo "Run as root: sudo $0" >&2
    exit 1
fi

for ns in fw staff servers dmz guests management internet; do
    ip netns delete "$ns" 2>/dev/null || true
done
echo "Lab removed."
