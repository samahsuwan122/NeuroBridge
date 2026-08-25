"""add AI conversation metadata

Revision ID: 0020_ai_conversation_metadata
Revises: 0019_encouragement_media
"""

from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op

revision: str = "0020_ai_conversation_metadata"
down_revision: Union[str, None] = "0019_encouragement_media"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    with op.batch_alter_table("ai_chat_sessions") as batch_op:
        batch_op.add_column(sa.Column("title", sa.String(length=255), nullable=True))
        batch_op.add_column(sa.Column("patient_profile_id", sa.Uuid(), nullable=True))
        batch_op.add_column(
            sa.Column("archived_at", sa.DateTime(timezone=True), nullable=True)
        )
        batch_op.add_column(
            sa.Column("deleted_at", sa.DateTime(timezone=True), nullable=True)
        )
        batch_op.create_foreign_key(
            "fk_ai_chat_sessions_patient_profile_id_patient_profiles",
            "patient_profiles",
            ["patient_profile_id"],
            ["id"],
        )
        batch_op.create_index(
            "ix_ai_chat_sessions_patient_profile_id", ["patient_profile_id"]
        )


def downgrade() -> None:
    with op.batch_alter_table("ai_chat_sessions") as batch_op:
        batch_op.drop_index("ix_ai_chat_sessions_patient_profile_id")
        batch_op.drop_constraint(
            "fk_ai_chat_sessions_patient_profile_id_patient_profiles",
            type_="foreignkey",
        )
        batch_op.drop_column("deleted_at")
        batch_op.drop_column("archived_at")
        batch_op.drop_column("patient_profile_id")
        batch_op.drop_column("title")
