# IP plan and rule matrix

## Zones

| Zone | Subnet | Firewall address | Example host |
|---|---|---|---|
| staff | 10.10.10.0/24 | 10.10.10.1 | 10.10.10.10 |
| servers | 10.10.20.0/24 | 10.10.20.1 | 10.10.20.10 |
| dmz | 10.10.30.0/24 | 10.10.30.1 | 10.10.30.10 (web server) |
| guests | 10.10.40.0/24 | 10.10.40.1 | 10.10.40.10 |
| management | 10.10.99.0/24 | 10.10.99.1 | 10.10.99.10 |
| internet (simulated) | 203.0.113.0/24 | 203.0.113.1 | 203.0.113.10 |

203.0.113.0/24 is reserved for documentation (RFC 5737), so it can never
collide with real addresses.

## Rule matrix

Row = who starts the connection. Column = who they connect to.
Numbers are the allowed TCP ports. Everything else is blocked.
Replies to allowed connections pass automatically (stateful firewall).

| From / To | staff | servers | dmz | guests | management | internet | firewall itself |
|---|---|---|---|---|---|---|---|
| staff | - | 445 | 80, 443 | blocked | blocked | 80, 443 | blocked |
| servers | blocked | - | blocked | blocked | blocked | blocked | blocked |
| dmz | blocked | blocked | - | blocked | blocked | blocked | blocked |
| guests | blocked | blocked | blocked | - | blocked | 80, 443 | blocked |
| management | 22, ping | 22, ping | 22, ping | blocked | - | 80, 443 | 22, ping |
| internet | blocked | blocked | 80, 443 (*) | blocked | blocked | - | blocked |

(*) Only via port forwarding: traffic to 203.0.113.1 on 80/443 is redirected to
the web server 10.10.30.10. Internal addresses cannot be reached directly.

## Principles

1. Default deny: traffic between zones is dropped unless a rule allows it.
2. Stateful: only the side that starts a connection needs a rule.
3. Least privilege: only the ports that are actually needed.
4. The DMZ never starts connections inward. If the web server is compromised,
   the attacker cannot move on from there.
5. Management is its own zone, and nothing can start a connection into it.
6. Outbound traffic is filtered too. Servers and the DMZ have no internet access.
7. The firewall protects itself (input chain): only management can reach it.
8. Rules match on the interface a packet arrived on, not only on its IP address.
