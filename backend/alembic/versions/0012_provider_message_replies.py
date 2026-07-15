"""provider message replies: provider_message_replies

Revision ID: 0012_provider_message_replies
Revises: 0011_provider_messages
Create Date: 2026-07-15

Creates provider_message_replies for two-way chat inside a provider inquiry
thread. Each reply belongs to a provider_messages row (the thread root) and a
sender user; read_at/read_by_user_id drive the in-app unread badge. References
existing tables one-directionally (no circular FK). Portable/SQLite-friendly.

MEDICAL SAFETY: non-urgent care-coordination content only — never emergency
care, medical advice, diagnosis, assessment, or any scored/interpreted value.
"""

from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op

# revision identifiers, used by Alembic.
revision: str = "0012_provider_message_replies"
down_revision: Union[str, None] = "0011_provider_messages"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "provider_message_replies",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("provider_message_id", sa.Uuid(), nullable=False),
        sa.Column("sender_user_id", sa.Uuid(), nullable=False),
        sa.Column("body", sa.String(length=500), nullable=False),
        sa.Column("read_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("read_by_user_id", sa.Uuid(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("deleted_at", sa.DateTime(timezone=True), nullable=True),
        sa.PrimaryKeyConstraint("id", name="pk_provider_message_replies"),
        sa.ForeignKeyConstraint(
            ["provider_message_id"],
            ["provider_messages.id"],
            name="fk_provider_message_replies_provider_message_id",
        ),
        sa.ForeignKeyConstraint(
            ["sender_user_id"],
            ["users.id"],
            name="fk_provider_message_replies_sender_user_id_users",
        ),
        sa.ForeignKeyConstraint(
            ["read_by_user_id"],
            ["users.id"],
            name="fk_provider_message_replies_read_by_user_id_users",
        ),
    )


def downgrade() -> None:
    op.drop_table("provider_message_replies")
