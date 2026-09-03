"""family encouragements: family_encouragements

Revision ID: 0006_family_encouragements
Revises: 0005_memory_album
Create Date: 2026-07-12

Creates family_encouragements for supportive family messages sent to a linked
patient. References the existing patient_profiles/users tables one-directionally
(no circular FK). Portable types keep it SQLite-friendly and PostgreSQL-ready.

MEDICAL SAFETY: family support content only — never medical advice, diagnosis,
assessment, or any scored/interpreted value.
"""

from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op

# revision identifiers, used by Alembic.
revision: str = "0006_family_encouragements"
down_revision: Union[str, None] = "0005_memory_album"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "family_encouragements",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("patient_profile_id", sa.Uuid(), nullable=False),
        sa.Column("sender_user_id", sa.Uuid(), nullable=False),
        sa.Column("message", sa.String(length=300), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("deleted_at", sa.DateTime(timezone=True), nullable=True),
        sa.PrimaryKeyConstraint("id", name="pk_family_encouragements"),
        sa.ForeignKeyConstraint(
            ["patient_profile_id"],
            ["patient_profiles.id"],
            name="fk_family_encouragements_patient_profile_id_patient_profiles",
        ),
        sa.ForeignKeyConstraint(
            ["sender_user_id"],
            ["users.id"],
            name="fk_family_encouragements_sender_user_id_users",
        ),
    )


def downgrade() -> None:
    op.drop_table("family_encouragements")
