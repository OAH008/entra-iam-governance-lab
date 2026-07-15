# Access Control Design

The role-based access control (RBAC) model, least-privilege reasoning, and separation-of-duties rules for Northwind Botanicals. This document is the design rationale that the technical configuration implements.

---

## 1. Organization

Northwind Botanicals is a simulated 25-user wholesale distributor, organized into seven departments:

| Department | Users | Example roles |
|------------|-------|---------------|
| Executive | 3 | CEO, COO, CFO |
| Finance | 4 | Finance Manager, AP Clerk, Controller, Payroll |
| Human Resources | 1 | HR Generalist |
| Information Technology | 3 | IT Manager, Systems Administrator, Help Desk |
| Sales | 5 | Sales Director, Account Executives, Sales Ops |
| Operations | 4 | Ops Manager, Logistics, Procurement, QA |
| Warehouse | 5 | Warehouse Manager, Inventory, Shipping/Receiving |

Each user is a member of a department security group (e.g., `SG-Finance`). Function-based groups layer on top for privileged and duty-segregated access.

---

## 2. Privilege model

Access is tiered by how much privilege a role genuinely requires, applying **least privilege (AC-6)** deliberately rather than granting broad admin rights by default.

| Tier | Definition | Accounts |
|------|-----------|----------|
| Break-glass | Standing Global Admin, emergency use only, excluded from Conditional Access | `labadmin` |
| Tier 0 (JIT) | Eligible for Global Administrator via PIM — no standing privilege | IT Manager |
| Tier 1 (JIT) | Eligible for scoped admin roles via PIM | Systems Administrator |
| Tier 2 (standing, scoped) | Minimal standing role matching daily function | Help Desk (Helpdesk Administrator) |
| Standard | No administrative rights; department resource access only | All other users |

**Design decisions worth noting:**

- **The help-desk technician holds only the Helpdesk Administrator role** — scoped to password resets for non-admin users. Deliberately *not* User Administrator or Global Administrator. This is least privilege applied precisely to job function.
- **The IT Manager does not hold standing Global Administrator.** Full GA is granted just-in-time through PIM, activated only when needed with approval and MFA, and expires automatically. This eliminates always-on top-tier privilege while preserving the ability to do the job.
- **One break-glass account is retained as a standing Global Admin by design.** It is excluded from Conditional Access so a misconfigured policy or MFA outage can never lock the organization out of its own tenant. Its use is exceptional and should be monitored. (Note the distinction: excluded from *enforcement*, but still protected with strong authentication — the exclusion is about lockout recovery, not weaker security.)

---

## 3. Separation of duties

Certain function combinations are "toxic" — no single identity should hold both, because together they enable fraud or error with no second check.

| Function A | Function B | Rule | Control |
|------------|-----------|------|---------|
| Vendor / invoice entry (`SG-Finance-VendorEntry`) | Payment approval (`SG-Finance-PaymentApproval`) | No single identity may hold both | AC-5 |
| Privileged role activation (requester) | Privileged role approval (approver) | The requester of an elevation cannot approve their own | AC-5, AC-6(5) |

The finance segregation is enforced through mutually-exclusive security groups and verified during access reviews. The privileged-access segregation is enforced by the PIM approval workflow, which routes each activation request to a separate approver.

---

## 4. How the design maps to enforcement

| Design element | Entra ID control | Framework |
|----------------|------------------|-----------|
| Least-privilege tiers | Directory role assignment + PIM | AC-6, PR.AA-05, A.5.15 |
| Just-in-time admin | Privileged Identity Management | AC-6(5), A.8.2 |
| Separation of duties | Mutually-exclusive groups + PIM approval | AC-5, A.5.3 |
| Strong authentication | Conditional Access (MFA, block legacy) | IA-2, PR.AA-03, A.8.5 |
| Periodic recertification | Access Reviews | AC-2, A.5.18 |

---

*This design was implemented and verified in the Northwind Botanicals Entra ID tenant. See the findings report and control-mapping matrix for evidence of each control operating.*
