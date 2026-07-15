# Control Mapping Matrix

Each control implemented in the Northwind Botanicals IAM Governance Lab, mapped to **NIST CSF 2.0**, **NIST SP 800-53 Rev. 5**, and **ISO/IEC 27001:2022**, with the supporting evidence.

This matrix is the bridge between the technical work and the frameworks — it demonstrates that each configuration was made in service of a named control objective, not in isolation.

---

## Account & Identity Management

| Implementation | NIST 800-53 | NIST CSF 2.0 | ISO 27001:2022 | Evidence |
|----------------|-------------|--------------|----------------|----------|
| 25 users provisioned with department/title; account inventory maintained | AC-2 | ID.AM-03, PR.AA-01 | A.5.16 | `scripts/Get-NorthwindUserInventory.ps1`; user-inventory CSV |
| Department and function-based security groups | AC-2, AC-3 | PR.AA-05 | A.5.15 | Groups list; membership screenshots |
| Break-glass emergency-access account (documented, monitored, CA-excluded) | AC-2(7) | PR.AA-05 | A.5.16 | RBAC design; privileged-access register |

## Least Privilege & Access Control

| Implementation | NIST 800-53 | NIST CSF 2.0 | ISO 27001:2022 | Evidence |
|----------------|-------------|--------------|----------------|----------|
| Tiered RBAC model; no admin rights beyond role need | AC-6 | PR.AA-05 | A.5.15 | `access-control-design.md`; RBAC matrix |
| Help-desk scoped to Helpdesk Administrator (password resets only), not broader admin | AC-6 | PR.AA-05 | A.8.2 | Role assignment screenshot |
| Scoped premium (P2) licensing to in-scope accounts only | AC-6 | — | — | License assignment |

## Separation of Duties

| Implementation | NIST 800-53 | NIST CSF 2.0 | ISO 27001:2022 | Evidence |
|----------------|-------------|--------------|----------------|----------|
| Vendor/invoice entry segregated from payment approval (mutually exclusive groups) | AC-5 | GV.RR | A.5.3 | RBAC matrix — SoD sheet |
| PIM activation approved by a party other than the requester | AC-5, AC-6(5) | PR.AA-05 | A.8.2 | PIM approval evidence |

## Authentication (Finding F-01)

| Implementation | NIST 800-53 | NIST CSF 2.0 | ISO 27001:2022 | Evidence |
|----------------|-------------|--------------|----------------|----------|
| Conditional Access CA01 — require MFA for all users | IA-2, IA-2(1) | PR.AA-03 | A.8.5 | CA01 policy; report-only + enforced sign-in evidence |
| Conditional Access CA02 — block legacy authentication | IA-2, AC-17 | PR.AA-03 | A.8.5 | CA02 policy screenshot |
| MFA registration state audited | IA-2 | PR.AA-03 | A.8.5 | `scripts/Get-NorthwindMfaRegistration.ps1`; MFA CSV |

## Privileged Access (Finding F-02)

| Implementation | NIST 800-53 | NIST CSF 2.0 | ISO 27001:2022 | Evidence |
|----------------|-------------|--------------|----------------|----------|
| Global Administrator made eligible (JIT) via PIM, not standing | AC-2(7), AC-6(5) | PR.AA-05 | A.8.2 | PIM eligible assignment; activation chain |
| Activation requires MFA + justification + approval + 4-hr limit | IA-2, AC-5, AU-2 | PR.AA-05 | A.8.2 | PIM role settings; activation evidence |
| External guest's standing Global Admin removed | AC-2(7), AC-6 | PR.AA-05 | A.8.2 | Privileged-roles before/after CSVs |
| Standing/privileged assignments audited | AC-2, AU-6 | DE.CM | A.8.15 | `scripts/Get-NorthwindPrivilegedRoles.ps1` |

## Access Recertification (Finding F-03)

| Implementation | NIST 800-53 | NIST CSF 2.0 | ISO 27001:2022 | Evidence |
|----------------|-------------|--------------|----------------|----------|
| Access review of privileged group; over-privileged member denied with justification | AC-2 | PR.AA-05 | A.5.18 | Access review decision screenshot |
| Denied access auto-removed (review → remediation loop) | AC-2, AC-6 | PR.AA-05 | A.5.18 | Group membership before/after |

## Logging & Monitoring

| Implementation | NIST 800-53 | NIST CSF 2.0 | ISO 27001:2022 | Evidence |
|----------------|-------------|--------------|----------------|----------|
| PIM activation events logged with justification | AU-2, AU-12 | DE.CM | A.8.15 | PIM audit history |
| Read-only audit toolkit generates timestamped CSV evidence | AU-6 | DE.CM | A.8.15 | `scripts/` + `evidence/` CSVs |

---

*Control identifiers are drawn from NIST SP 800-53 Rev. 5, NIST CSF 2.0, and ISO/IEC 27001:2022. Mappings reflect the primary control objective each implementation supports; some implementations reasonably map to additional controls.*
