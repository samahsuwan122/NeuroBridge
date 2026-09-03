"""provider messages: provider_messages

Revision ID: 0011_provider_messages
Revises: 0010_provider_profile_extra
Create Date: 2026-07-14

Creates provider_messages for non-urgent care-coordination inquiries a family
member sends to a care provider about their linked patient. References the
existing users/patient_profiles tables one-directionally (no circular FK).
Portable types keep it SQLite-friendly and PostgreSQL-ready.

MEDICAL SAFETY: non-urgent care-coordination content only — never emergency
care, medical advice, diagnosis, assessment, or any scored/interpreted value.
"""

from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op

# revision identifiers, used by Alembic.
revision: str = "0011_provider_messages"
down_revision: Union[str, None] = "0010_provider_profile_extra"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "provider_messages",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("provider_user_id", sa.Uuid(), nullable=False),
        sa.Column("sender_user_id", sa.Uuid(), nullable=False),
        sa.Column("patient_profile_id", sa.Uuid(), nullable=False),
        sa.Column("message", sa.String(length=500), nullable=False),
        sa.Column(
            "status", sa.String(length=32), nullable=False, server_default="sent"
        ),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("deleted_at", sa.DateTime(timezone=True), nullable=True),
        sa.PrimaryKeyConstraint("id", name="pk_provider_messages"),
        sa.ForeignKeyConstraint(
            ["provider_user_id"],
            ["users.id"],
            name="fk_provider_messages_provider_user_id_users",
        ),
        sa.ForeignKeyConstraint(
            ["sender_user_id"],
            ["users.id"],
            name="fk_provider_messages_sender_user_id_users",
        ),
        sa.ForeignKeyConstraint(
            ["patient_profile_id"],
            ["patient_profiles.id"],
            name="fk_provider_messages_patient_profile_id_patient_profiles",
        ),
    )


def downgrade() -> None:
    op.drop_table("provider_messages")
