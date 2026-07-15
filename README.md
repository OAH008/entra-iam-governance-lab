Entra ID — Identity & Access Management Governance Lab

A self-directed lab that implements and audits an identity governance program for a simulated organization in Microsoft Entra ID, mapping every control to NIST CSF 2.0, NIST SP 800-53 Rev. 5, and ISO/IEC 27001:2022.

The project walks the full GRC lifecycle — assess → remediate → verify — on a real Entra ID tenant: baseline the environment with read-only audit scripts, identify control gaps, remediate them with native Entra controls (Conditional Access, Privileged Identity Management, Access Reviews), and produce audit-ready evidence.


Environment

Northwind Botanicals — a simulated 25-user wholesale distributor built in Microsoft Entra ID, with seven departments, department and function-based security groups, and a tiered privileged-access model.

What was done

AreaImplementationDirectory build25 users across 7 departments provisioned via Microsoft Graph PowerShell; department and function security groupsAccess model (RBAC)Tiered role design with documented least-privilege and separation-of-duties rationaleAuthenticationConditional Access enforcing MFA for all users; legacy authentication blockedPrivileged accessGlobal Administrator converted to just-in-time via PIM (MFA + approval + justification + time-bound); external guest's standing admin removedRecertificationFormal access review of a privileged group, identifying and removing over-privileged accessAutomationRead-only Microsoft Graph PowerShell audit toolkit generating CSV evidence

Key results


MFA enforced tenant-wide via Conditional Access, closing a gap where the provisioned user population had no MFA registered.
Standing Global Administrators reduced from 2 to 1, with administrative roles moved to just-in-time access via PIM — eliminating always-on top-tier privilege.
Over-privileged access identified and remediated through a formal access recertification, with the removal auto-applied.



Findings summary

IDFindingRatingStatusF-01MFA not enforcedHigh✅ RemediatedF-02Excessive standing privileged access (incl. external guest as Global Admin)High✅ RemediatedF-03Access creep in a privileged groupMedium✅ Remediated

Full detail: Findings Report


Repository contents


findings-report.md — the engagement findings report: each gap, its risk, control mapping, and remediation
control-mapping.md — every implemented control mapped to NIST CSF 2.0, NIST 800-53, and ISO 27001, with supporting evidence
access-control-design.md — the RBAC role design, least-privilege model, and separation-of-duties rules
scripts/ — read-only Microsoft Graph PowerShell audit toolkit
evidence/ — screenshots and CSV exports captured during the engagement



Skills & technologies

Microsoft Entra ID · Conditional Access · Privileged Identity Management (PIM) · Access Reviews · RBAC · Least Privilege · Separation of Duties · Microsoft Graph PowerShell · NIST CSF 2.0 · NIST SP 800-53 · ISO/IEC 27001:2022 · Audit evidence collection


Built as a self-directed portfolio project to demonstrate the identity governance lifecycle end to end. All findings, remediations, and evidence reflect actions genuinely performed in a live Entra ID tenant.
