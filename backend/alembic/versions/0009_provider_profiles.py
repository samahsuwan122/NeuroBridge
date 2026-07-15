"""provider profiles: provider_profiles

Revision ID: 0009_provider_profiles
Revises: 0008_appointment_booking
Create Date: 2026-07-14

Creates provider_profiles with extra display/booking details for care providers
(focus/specialty, short blurb, clinic, location, experience label, and seeded
demo rating values). References users one-directionally. Portable/SQLite-friendly.

DEMO USE: ratings/text are seeded demo values only. MEDICAL SAFETY: scheduling/
coordination content only — never diagnosis, assessment, or treatment.
"""

from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op

# revision identifiers, used by Alembic.
revision: str = "0009_provider_profiles"
down_revision: Union[str, None] = "0008_appointment_booking"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "provider_profiles",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("provider_user_id", sa.Uuid(), nullable=False),
        sa.Column("specialty", sa.String(length=255), nullable=True),
        sa.Column("bio_short", sa.String(length=500), nullable=True),
        sa.Column("clinic_name", sa.String(length=255), nullable=True),
        sa.Column("location", sa.String(length=255), nullable=True),
        sa.Column("experience_label", sa.String(length=64), nullable=True),
        sa.Column("rating_average", sa.Float(), nullable=True),
        sa.Column("rating_count", sa.Integer(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("deleted_at", sa.DateTime(timezone=True), nullable=True),
        sa.PrimaryKeyConstraint("id", name="pk_provider_profiles"),
        sa.UniqueConstraint(
            "provider_user_id", name="uq_provider_profiles_provider_user_id"
        ),
        sa.ForeignKeyConstraint(
            ["provider_user_id"],
            ["users.id"],
            name="fk_provider_profiles_provider_user_id_users",
        ),
    )


def downgrade() -> None:
    op.drop_table("provider_profiles")
