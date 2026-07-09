"""memory album: memory_entries

Revision ID: 0005_memory_album
Revises: 0004_patient_care_info
Create Date: 2026-07-10

Creates memory_entries for the Memory Album. Each row references the existing
patient_profiles/users tables one-directionally (no circular FK). Portable
types keep it SQLite-friendly and PostgreSQL-ready.

MEDICAL SAFETY: supportive/family-engagement content only — no diagnostic
columns, never analyzed or scored. media_type/media_url are placeholders (no
real file upload yet).
"""

from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op

# revision identifiers, used by Alembic.
revision: str = "0005_memory_album"
down_revision: Union[str, None] = "0004_patient_care_info"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "memory_entries",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("patient_profile_id", sa.Uuid(), nullable=False),
        sa.Column("uploaded_by_user_id", sa.Uuid(), nullable=False),
        sa.Column("title", sa.String(length=255), nullable=False),
        sa.Column("description", sa.Text(), nullable=True),
        sa.Column("person_name", sa.String(length=255), nullable=True),
        sa.Column("relationship", sa.String(length=64), nullable=True),
        sa.Column("place_name", sa.String(length=255), nullable=True),
        sa.Column("memory_date", sa.Date(), nullable=True),
        sa.Column("category", sa.String(length=64), nullable=True),
        sa.Column("media_type", sa.String(length=32), nullable=True),
        sa.Column("media_url", sa.String(length=1024), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("deleted_at", sa.DateTime(timezone=True), nullable=True),
        sa.PrimaryKeyConstraint("id", name="pk_memory_entries"),
        sa.ForeignKeyConstraint(
            ["patient_profile_id"],
            ["patient_profiles.id"],
            name="fk_memory_entries_patient_profile_id_patient_profiles",
        ),
        sa.ForeignKeyConstraint(
            ["uploaded_by_user_id"],
            ["users.id"],
            name="fk_memory_entries_uploaded_by_user_id_users",
        ),
    )


def downgrade() -> None:
    op.drop_table("memory_entries")
