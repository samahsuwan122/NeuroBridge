# Database Schema

> **Status: placeholder.** This document is populated starting in **Phase 3 (Database Foundation)**.
> No models or migrations exist in Phase 1.

## Strategy

- **Local development:** SQLite (`sqlite:///./neurobridge_dev.db`) — no server required.
- **Official / production database:** PostgreSQL.
- The active database is chosen at runtime via the `DATABASE_URL` environment variable, so the same
  code runs on both. Schema and migrations are written to remain PostgreSQL-compatible.

## Base model fields (planned, Phase 3)

Common fields intended for most tables:

- `id` — UUID primary key
- `created_at` — timestamp
- `updated_at` — timestamp
- `deleted_at` — nullable timestamp (soft delete, where useful)

## Initial tables (planned, Phase 3)

- `Users`
- `Roles`
- `UserRoles`
- `MedicalCenters`
- `AuditLogs`

Full column definitions, types, constraints, and relationships will be documented here as they are
implemented.
