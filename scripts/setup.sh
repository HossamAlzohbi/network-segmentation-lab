#!/usr/bin/env bash
# setup.sh – bygger det segmenterte nettverket med network namespaces
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
    echo "Kjør med sudo: sudo $0" >&2
    exit 1
fi

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
"$DIR/teardown.sh"

# Sone og subnett-prefiks (se docs/ip-plan.md)
ZONES=(
    "ansatte    10.10.10"
    "servere    10.10.20"
    "dmz        10.10.30"
    "gjester    10.10.40"
    "management 10.10.99"
    "internett  203.0.113"
)

# --- 1. Brannmuren i midten ---
ip netns add fw
ip netns exec fw ip link set lo up

# --- 2. En namespace per sone, koblet til brannmuren ---
for z in "${ZONES[@]}"; do
    read -r zone prefix <<< "$z"

    ip netns add "$zone"

    # Virtuell kabel: den ene enden i fw, den andre i sonen
    ip link add "fw-$zone" netns fw type veth peer name eth0 netns "$zone"

    # Brannmurens ende får .1, sonens ende får .10
    ip netns exec fw ip addr add "$prefix.1/24" dev "fw-$zone"
    ip netns exec fw ip link set "fw-$zone" up
    ip netns exec "$zone" ip addr add "$prefix.10/24" dev eth0
    ip netns exec "$zone" ip link set eth0 up
    ip netns exec "$zone" ip link set lo up

    # Alt utenfor eget subnett sendes til brannmuren
    ip netns exec "$zone" ip route add default via "$prefix.1"
done

# --- 3. Videresending i brannmuren (av inntil videre) ---
ip netns exec fw sysctl -qw net.ipv4.ip_forward=0

echo "Labben er bygget: 7 namespaces (fw + 6 soner)."
