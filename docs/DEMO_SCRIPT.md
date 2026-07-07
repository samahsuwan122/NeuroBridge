# Demo Script

> **Status: placeholder.** The full demo walkthrough is written near the integration/demo phases
> (Phases 24–25). It is outlined here so the target flow is clear from the start.

## Target end-to-end demo flow (planned)

1. Admin creates users (patient, family, doctor, manager).
2. Doctor sees their assigned patient.
3. Patient logs in on the **Flutter mobile app**.
4. Patient plays a cognitive game.
5. The game result is saved.
6. Doctor views the patient's progress on the **web dashboard**.
7. Doctor generates an AI **support recommendation** (non-diagnostic, pending review).
8. Doctor approves / edits / rejects the recommendation.
9. A therapy plan appears for the patient.
10. A reminder appears.
11. A PDF report is generated.
12. Audit logs show the sensitive actions.

## Demo accounts

Demo credentials and seed data are added in **Phase 24 (Testing and Demo Data)** and kept in local
docs only — never committed as real secrets, and never using real patient data.

> Reminder: everything shown in the demo is **non-diagnostic**. AI output is a support recommendation
> that requires review by a qualified doctor or therapist.
