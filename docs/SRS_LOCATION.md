# SRS Location

The official **Software Requirements Specification (SRS)** for NeuroBridge should be placed at:

```text
docs/SRS.docx
```

At the time of writing, the SRS file is **not yet present** in the repository. Please add it at the
path above so the rest of the team (and future phases) can reference it directly.

## Traceability

Every future phase must **trace its implementation back to the SRS**:

- Before implementing a feature, confirm the requirement exists in the SRS.
- Do **not** invent medical features that are not in the SRS unless they are clearly marked as a
  *future enhancement*.
- When a feature is implemented, note the SRS requirement it satisfies (e.g. in the pull request,
  commit message, or the relevant doc such as `API_CONTRACT.md`).
- If an SRS requirement is intentionally deferred, record it as out-of-scope for the current MVP.

## Safety note

The SRS and all derived work must respect the project's documented guardrails:
NeuroBridge is **not a diagnostic system**, and no implementation may claim to diagnose any medical
condition.
