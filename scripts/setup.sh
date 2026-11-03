#!/usr/bin/env bash
# setup.sh - build the segmented network lab with Linux network namespaces.
# Usage: sudo ./scripts/setup.sh
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
    echo "Run as root: sudo $0" >&2
    exit 1
fi

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RULES="$DIR/../configs/fw.nft"

# Start from a clean slate
"$DIR/teardown.sh"

# zone name and subnet prefix (see docs/ip-plan.md)
ZONES=(
    "staff       10.10.10"
    "servers     10.10.20"
    "dmz         10.10.30"
    "guests      10.10.40"
    "management  10.10.99"
    "internet    203.0.113"
)

# 1. The firewall namespace sits in the middle and routes between all zones.
#    Forwarding stays off until the rules are loaded (step 3).
ip netns add fw
ip netns exec fw ip link set lo up
ip netns exec fw sysctl -qw net.ipv4.ip_forward=0

# 2. One namespace per zone, each connected to the firewall by its own
#    virtual cable (a veth pair): one end in fw, the other end in the zone.
for z in "${ZONES[@]}"; do
    read -r zone prefix <<< "$z"

    ip netns add "$zone"
    ip link add "fw-$zone" netns fw type veth peer name eth0 netns "$zone"

    # The firewall end gets .1, the zone host gets .10
    ip netns exec fw ip addr add "$prefix.1/24" dev "fw-$zone"
    ip netns exec fw ip link set "fw-$zone" up
    ip netns exec "$zone" ip addr add "$prefix.10/24" dev eth0
    ip netns exec "$zone" ip link set eth0 up
    ip netns exec "$zone" ip link set lo up

    # Everything outside the zone's own subnet goes through the firewall
    ip netns exec "$zone" ip route add default via "$prefix.1"
done

# 3. Load the rules BEFORE enabling forwarding, so traffic is never unfiltered
ip netns exec fw nft -f "$RULES"
ip netns exec fw sysctl -qw net.ipv4.ip_forward=1

echo "Lab is up: firewall + ${#ZONES[@]} zones, rules loaded."
