"""Audit logging module.

Provides a small, reusable helper to record sensitive actions in the
`audit_logs` table. Used by auth (login/logout) now and by later phases
(profile updates, notes, report generation, AI review, etc.).
"""
