"""assigned activities: care-team activity builder

Revision ID: 0013_assigned_activities
Revises: 0012_provider_message_replies
Create Date: 2026-07-17

Creates assigned_activities. A doctor/therapist assigns a cognitive activity
(from a fixed safe template) to one of their patients. References the existing
patient_profiles/users tables one-directionally (no circular FK). Portable types
keep it SQLite-friendly and PostgreSQL-ready.

MEDICAL SAFETY: exercise content only — no diagnosis/treatment/prediction.
"""

from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op

# revision identifiers, used by Alembic.
revision: str = "0013_assigned_activities"
down_revision: Union[str, None] = "0012_provider_message_replies"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "assigned_activities",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("patient_profile_id", sa.Uuid(), nullable=False),
        sa.Column("assigned_by_user_id", sa.Uuid(), nullable=False),
        sa.Column("template_type", sa.String(length=64), nullable=False),
        sa.Column("title", sa.String(length=255), nullable=False),
        sa.Column("instructions", sa.Text(), nullable=True),
        sa.Column("difficulty", sa.String(length=32), nullable=False),
        sa.Column("duration_minutes", sa.Integer(), nullable=False),
        sa.Column("status", sa.String(length=16), nullable=False),
        sa.Column("generated_content", sa.JSON(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("completed_at", sa.DateTime(timezone=True), nullable=True),
        sa.PrimaryKeyConstraint("id", name="pk_assigned_activities"),
        sa.ForeignKeyConstraint(
            ["patient_profile_id"],
            ["patient_profiles.id"],
            name="fk_assigned_activities_patient_profile_id_patient_profiles",
        ),
        sa.ForeignKeyConstraint(
            ["assigned_by_user_id"],
            ["users.id"],
            name="fk_assigned_activities_assigned_by_user_id_users",
        ),
    )


def downgrade() -> None:
    op.drop_table("assigned_activities")
