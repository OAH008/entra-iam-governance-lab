# Identity & Access Management Governance Review — Findings Report

**Engagement:** Identity Governance Assessment & Remediation
**Environment:** Northwind Botanicals (simulated 25-user organization, Microsoft Entra ID)
**Reviewer:** Omar Humran
**Date:** July 2026
**Frameworks referenced:** NIST CSF 2.0 · NIST SP 800-53 Rev. 5 · ISO/IEC 27001:2022

---

## 1. Executive Summary

This engagement assessed and remediated identity and access management (IAM) controls for Northwind Botanicals, a simulated organization built in Microsoft Entra ID. The review covered account management, privileged access, authentication controls, and access recertification.

Three findings were identified through a baseline audit of the tenant. Each was remediated during the engagement and verified. In summary:

- **Multi-factor authentication was not enforced** across the user population. Remediated by implementing Conditional Access policies requiring MFA and blocking legacy authentication.
- **Privileged access was excessive and standing**, including an external guest identity holding a permanent Global Administrator role. Remediated by removing the external guest's privileged access and converting administrative roles to just-in-time (JIT) access using Privileged Identity Management (PIM).
- **Access creep was present in a privileged group**, where a non-IT user held membership in an IT administrators group. Remediated through a formal access recertification that identified and removed the inappropriate access.

All three findings were closed by the end of the engagement.

---

## 2. Scope & Methodology

**In scope:** all user and administrative accounts, security groups, directory role assignments, Conditional Access configuration, and privileged access configuration within the Northwind Botanicals Entra ID tenant.

**Methodology:**
1. **Baseline audit** — a read-only PowerShell (Microsoft Graph) toolkit was used to inventory accounts, enumerate privileged role assignments, and report MFA registration state, producing timestamped CSV evidence.
2. **Analysis** — baseline output was evaluated against least-privilege, strong-authentication, and separation-of-duties principles to identify control gaps.
3. **Remediation** — each gap was remediated using native Entra ID controls (Conditional Access, PIM, Access Reviews).
4. **Verification** — controls were re-tested and the audit scripts re-run to confirm the remediated state.

**Environment note:** This is a lab environment built to demonstrate the IAM governance lifecycle. To validate the access recertification control (Finding 3), a controlled access-creep scenario was deliberately introduced (a non-IT user added to a privileged group) so that the review process could be shown to detect and remediate it.

---

## 3. Findings

### F-01 — Multi-Factor Authentication Not Enforced
**Risk rating:** High

**Observation:** The baseline audit found that the provisioned user population (25 accounts) had no multi-factor authentication methods registered, and no policy existed to require MFA at sign-in. Authentication relied on passwords alone.

**Risk:** Password-only authentication leaves accounts vulnerable to credential theft, phishing, and password-spray attacks. Without MFA, a single compromised password grants full account access.

**Control mapping:**
- NIST 800-53: IA-2, IA-2(1) (Identification and Authentication — MFA), AC-17 (Remote Access)
- NIST CSF 2.0: PR.AA-03 (Authentication)
- ISO 27001:2022: A.8.5 (Secure Authentication)

**Remediation:** Implemented Conditional Access policy **CA01 – Require MFA for All Users** (all users, all cloud apps, break-glass account excluded by design) and **CA02 – Block Legacy Authentication** (blocks legacy protocols that cannot enforce MFA and would otherwise bypass CA01). Both policies were validated in report-only mode before enforcement, then enabled.

**Status:** ✅ Remediated and verified (live MFA challenge confirmed on enforced sign-in).

---

### F-02 — Excessive Standing Privileged Access
**Risk rating:** High

**Observation:** The baseline privileged-role report showed that all administrative access was standing (permanently active). Critically, an **external guest identity held a standing Global Administrator role** — the highest privilege in the tenant, assigned permanently to an account originating from another organization.

**Risk:** Standing administrative privilege maximizes the attack surface — any compromise of an admin account grants immediate, always-available tenant-wide control. An external guest holding Global Administrator is a particularly serious exposure, as the identity is managed outside the organization's directory.

**Control mapping:**
- NIST 800-53: AC-2(7) (Privileged User Accounts), AC-6, AC-6(5) (Least Privilege — Privileged Accounts)
- NIST CSF 2.0: PR.AA-05 (Access permissions managed, incorporating least privilege)
- ISO 27001:2022: A.8.2 (Privileged Access Rights)

**Remediation:**
1. Removed the external guest identity's standing Global Administrator assignment.
2. Converted administrative access to just-in-time using **Privileged Identity Management (PIM)** — the IT Manager was made *eligible* for Global Administrator rather than holding it as standing. Activation requires MFA, business justification, and approval by a separate approver, and is time-bound (4-hour maximum).
3. Retained one break-glass Global Administrator account (excluded from Conditional Access) as an intentional, documented emergency-access measure.

**Result:** Standing Global Administrator assignments reduced to the single break-glass account. Privileged access is now granted on-demand, approved by a different party than the requester (separation of duties), MFA-gated, justified, logged, and self-expiring.

**Control mapping (remediated state adds):** AC-5 (Separation of Duties — approval by a separate party), AU-2 (Auditable Events — activation logged with justification).

**Status:** ✅ Remediated and verified (JIT activation workflow executed end-to-end; audit trail captured).

---

### F-03 — Access Creep in Privileged Group
**Risk rating:** Medium

**Observation:** A formal access review of the **SG-IT-Admins** privileged group identified a member (an Inside Sales representative) with no IT administrative job function — an instance of access creep, where access is granted or retained beyond what a role requires.

**Risk:** Users accumulating access beyond their role violates least privilege and expands the pool of accounts that, if compromised, could reach sensitive administrative functions. Unreviewed group membership is a common audit finding.

**Control mapping:**
- NIST 800-53: AC-2 (Account Management — review of accounts), AC-6 (Least Privilege)
- NIST CSF 2.0: PR.AA-05 (Access permissions managed)
- ISO 27001:2022: A.5.18 (Review of Access Rights)

**Remediation:** Conducted a formal access recertification campaign using Entra Access Reviews. The reviewer (IT Manager) attested to each member's access; the inappropriate membership was **denied with documented justification** ("Inside Sales role; no IT administrative function; access not required"). With auto-apply enabled, the denied user was automatically removed from the privileged group, closing the loop from review decision to remediation.

**Status:** ✅ Remediated and verified (user removed from group; membership confirmed post-review).

---

## 4. Findings Summary

| ID | Finding | Rating | Primary Control | Status |
|----|---------|--------|-----------------|--------|
| F-01 | MFA not enforced | High | IA-2, PR.AA-03, A.8.5 | ✅ Remediated |
| F-02 | Excessive standing privileged access | High | AC-6(5), PR.AA-05, A.8.2 | ✅ Remediated |
| F-03 | Access creep in privileged group | Medium | AC-2, PR.AA-05, A.5.18 | ✅ Remediated |

---

## 5. Recommendations (Ongoing)

The remediations above address the identified gaps. To sustain the improved posture, the following operational practices are recommended:

1. **Recurring access reviews.** Convert the one-time recertification (F-03) into a recurring quarterly review of all privileged groups and directory roles, so access creep is caught continuously rather than once.
2. **Periodic privileged-access audit.** Run the privileged-role audit script on a schedule to detect any new standing administrative assignments.
3. **Separation-of-duties enforcement.** Formalize the documented SoD rule (vendor/invoice entry vs. payment approval) with entitlement-management separation checks as the environment matures.
4. **Break-glass account monitoring.** Alert on any sign-in by the excluded break-glass account, since its use should be rare and exceptional.
5. **MFA registration campaign.** Ensure all users complete MFA registration so enforcement never blocks legitimate access.

---

*This report documents work performed in a self-directed lab environment built to demonstrate the identity governance lifecycle: assess, remediate, and verify. All findings, remediations, and evidence reflect actions genuinely performed in the tenant.*
