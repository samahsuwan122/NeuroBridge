"""appointments: appointments

Revision ID: 0007_appointments
Revises: 0006_family_encouragements
Create Date: 2026-07-12

Creates appointments for family/caregiver appointment *requests* for a linked
patient. References the existing patient_profiles/users tables one-directionally
(no circular FK). Portable types keep it SQLite-friendly and PostgreSQL-ready.

MEDICAL SAFETY: coordination content only — not emergency care, and never a
diagnosis, assessment, or treatment. Status is backend-controlled.
"""

from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op

# revision identifiers, used by Alembic.
revision: str = "0007_appointments"
down_revision: Union[str, None] = "0006_family_encouragements"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "appointments",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("patient_profile_id", sa.Uuid(), nullable=False),
        sa.Column("requester_user_id", sa.Uuid(), nullable=False),
        sa.Column("preferred_date", sa.Date(), nullable=False),
        sa.Column("preferred_time", sa.String(length=32), nullable=True),
        sa.Column("reason", sa.String(length=500), nullable=False),
        sa.Column("status", sa.String(length=32), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("deleted_at", sa.DateTime(timezone=True), nullable=True),
        sa.PrimaryKeyConstraint("id", name="pk_appointments"),
        sa.ForeignKeyConstraint(
            ["patient_profile_id"],
            ["patient_profiles.id"],
            name="fk_appointments_patient_profile_id_patient_profiles",
        ),
        sa.ForeignKeyConstraint(
            ["requester_user_id"],
            ["users.id"],
            name="fk_appointments_requester_user_id_users",
        ),
    )


def downgrade() -> None:
    op.drop_table("appointments")
