"""patient care & safety information columns

Revision ID: 0004_patient_care_info
Revises: 0003_cognitive_games
Create Date: 2026-07-09

Adds nullable care/safety columns to patient_profiles. These are practical
care/safety details only (non-diagnostic) — never analyzed or scored. Uses
plain ADD COLUMN (safe on SQLite and PostgreSQL for nullable columns) and a
batch drop for the downgrade so it works on SQLite too.
"""

from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op

# revision identifiers, used by Alembic.
revision: str = "0004_patient_care_info"
down_revision: Union[str, None] = "0003_cognitive_games"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None

_TABLE = "patient_profiles"


def upgrade() -> None:
    op.add_column(_TABLE, sa.Column("allergies", sa.Text(), nullable=True))
    op.add_column(_TABLE, sa.Column("current_medications", sa.Text(), nullable=True))
    op.add_column(_TABLE, sa.Column("blood_type", sa.String(length=8), nullable=True))
    op.add_column(_TABLE, sa.Column("mobility_needs", sa.String(length=255), nullable=True))
    op.add_column(
        _TABLE, sa.Column("vision_hearing_needs", sa.String(length=255), nullable=True)
    )
    op.add_column(
        _TABLE, sa.Column("preferred_communication", sa.String(length=255), nullable=True)
    )
    op.add_column(_TABLE, sa.Column("caregiver_notes", sa.Text(), nullable=True))


def downgrade() -> None:
    with op.batch_alter_table(_TABLE, schema=None) as batch_op:
        batch_op.drop_column("caregiver_notes")
        batch_op.drop_column("preferred_communication")
        batch_op.drop_column("vision_hearing_needs")
        batch_op.drop_column("mobility_needs")
        batch_op.drop_column("blood_type")
        batch_op.drop_column("current_medications")
        batch_op.drop_column("allergies")
