#!/usr/bin/env bash
# teardown.sh – river ned hele labben
set -uo pipefail

if [[ $EUID -ne 0 ]]; then
    echo "Kjør med sudo: sudo $0" >&2
    exit 1
fi

for ns in fw ansatte servere dmz gjester management internett; do
    ip netns delete "$ns" 2>/dev/null || true
done
echo "Ryddet bort gamle namespaces."
