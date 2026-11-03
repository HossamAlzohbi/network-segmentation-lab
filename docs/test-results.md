| From | To | Expected | Actual | Result |
|---|---|---|---|---|
| staff      | servers:445            | ALLOW    | ALLOW    | PASS |
| staff      | dmz:80                 | ALLOW    | ALLOW    | PASS |
| staff      | dmz:443                | ALLOW    | ALLOW    | PASS |
| staff      | internet:80            | ALLOW    | ALLOW    | PASS |
| staff      | internet:443           | ALLOW    | ALLOW    | PASS |
| management | staff:22               | ALLOW    | ALLOW    | PASS |
| management | servers:22             | ALLOW    | ALLOW    | PASS |
| management | dmz:22                 | ALLOW    | ALLOW    | PASS |
| management | internet:80            | ALLOW    | ALLOW    | PASS |
| guests     | internet:80            | ALLOW    | ALLOW    | PASS |
| internet   | 203.0.113.1:80         | ALLOW    | ALLOW    | PASS |
| internet   | 203.0.113.1:443        | ALLOW    | ALLOW    | PASS |
| management | staff (ping)           | ALLOW    | ALLOW    | PASS |
| management | servers (ping)         | ALLOW    | ALLOW    | PASS |
| management | dmz (ping)             | ALLOW    | ALLOW    | PASS |
| staff      | servers:22             | BLOCK    | BLOCK    | PASS |
| staff      | dmz:22                 | BLOCK    | BLOCK    | PASS |
| staff      | guests:80              | BLOCK    | BLOCK    | PASS |
| staff      | management:22          | BLOCK    | BLOCK    | PASS |
| staff      | internet:22            | BLOCK    | BLOCK    | PASS |
| servers    | staff:445              | BLOCK    | BLOCK    | PASS |
| servers    | dmz:80                 | BLOCK    | BLOCK    | PASS |
| servers    | internet:80            | BLOCK    | BLOCK    | PASS |
| dmz        | staff:80               | BLOCK    | BLOCK    | PASS |
| dmz        | servers:445            | BLOCK    | BLOCK    | PASS |
| dmz        | management:22          | BLOCK    | BLOCK    | PASS |
| dmz        | internet:80            | BLOCK    | BLOCK    | PASS |
| guests     | staff:80               | BLOCK    | BLOCK    | PASS |
| guests     | servers:445            | BLOCK    | BLOCK    | PASS |
| guests     | dmz:80                 | BLOCK    | BLOCK    | PASS |
| guests     | management:22          | BLOCK    | BLOCK    | PASS |
| guests     | internet:22            | BLOCK    | BLOCK    | PASS |
| management | guests:22              | BLOCK    | BLOCK    | PASS |
| internet   | staff:80               | BLOCK    | BLOCK    | PASS |
| internet   | servers:445            | BLOCK    | BLOCK    | PASS |
| internet   | dmz:80                 | BLOCK    | BLOCK    | PASS |
| internet   | management:22          | BLOCK    | BLOCK    | PASS |
| internet   | 203.0.113.1:22         | BLOCK    | BLOCK    | PASS |
| staff      | 10.10.10.1 (ping)      | BLOCK    | BLOCK    | PASS |
| guests     | management (ping)      | BLOCK    | BLOCK    | PASS |
| dmz        | management (ping)      | BLOCK    | BLOCK    | PASS |

Passed: 41, failed: 0
