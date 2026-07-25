"""access requests: public request-access intake

Revision ID: 0014_access_requests
Revises: 0013_assigned_activities
Create Date: 2026-07-21

Creates access_requests. A member of the public submits a request from the
marketing website; it is stored as pending and reviewed by an admin before any
account is created. Portable types keep it SQLite-friendly and PostgreSQL-ready.

MEDICAL SAFETY: intake/contact record only — no account, password, or medical
data.
"""

from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op

# revision identifiers, used by Alembic.
revision: str = "0014_access_requests"
down_revision: Union[str, None] = "0013_assigned_activities"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "access_requests",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("full_name", sa.String(length=255), nullable=False),
        sa.Column("email", sa.String(length=255), nullable=False),
        sa.Column("phone", sa.String(length=50), nullable=True),
        sa.Column("requested_role", sa.String(length=32), nullable=False),
        sa.Column("organization", sa.String(length=255), nullable=True),
        sa.Column("message", sa.Text(), nullable=True),
        sa.Column("status", sa.String(length=16), nullable=False),
        sa.Column("admin_note", sa.Text(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False),
        sa.PrimaryKeyConstraint("id", name="pk_access_requests"),
    )


def downgrade() -> None:
    op.drop_table("access_requests")
