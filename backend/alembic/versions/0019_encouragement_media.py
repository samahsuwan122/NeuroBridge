"""add persistent multimedia encouragement fields

Revision ID: 0019_encouragement_media
Revises: 0018_appointment_foreign_keys
"""

from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op

revision: str = "0019_encouragement_media"
down_revision: Union[str, None] = "0018_appointment_foreign_keys"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    with op.batch_alter_table("family_encouragements") as batch_op:
        batch_op.alter_column(
            "message",
            existing_type=sa.String(length=300),
            existing_nullable=False,
            nullable=True,
        )
        batch_op.add_column(sa.Column("caption", sa.String(length=180), nullable=True))
        batch_op.add_column(sa.Column("media_type", sa.String(length=16), nullable=True))
        batch_op.add_column(sa.Column("media_url", sa.String(length=1024), nullable=True))
        batch_op.add_column(
            sa.Column("media_mime_type", sa.String(length=128), nullable=True)
        )
        batch_op.add_column(sa.Column("media_size_bytes", sa.Integer(), nullable=True))
        batch_op.add_column(
            sa.Column("media_duration_seconds", sa.Integer(), nullable=True)
        )


def downgrade() -> None:
    # The legacy schema requires text. Preserve multimedia rows rather than
    # dropping them by converting their absent message to an empty value.
    op.execute(
        sa.text("UPDATE family_encouragements SET message = '' WHERE message IS NULL")
    )
    with op.batch_alter_table("family_encouragements") as batch_op:
        batch_op.drop_column("media_duration_seconds")
        batch_op.drop_column("media_size_bytes")
        batch_op.drop_column("media_mime_type")
        batch_op.drop_column("media_url")
        batch_op.drop_column("media_type")
        batch_op.drop_column("caption")
        batch_op.alter_column(
            "message",
            existing_type=sa.String(length=300),
            existing_nullable=True,
            nullable=False,
        )
