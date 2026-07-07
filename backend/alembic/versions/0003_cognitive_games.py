"""cognitive games: game_definitions and game_results

Revision ID: 0003_cognitive_games
Revises: 0002_patient_profiles
Create Date: 2026-07-07

Creates game_definitions and game_results. game_results references the existing
game_definitions/patient_profiles/users tables one-directionally (no circular
FK). Portable types keep it SQLite-friendly and PostgreSQL-ready.
"""

from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op

# revision identifiers, used by Alembic.
revision: str = "0003_cognitive_games"
down_revision: Union[str, None] = "0002_patient_profiles"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "game_definitions",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("name", sa.String(length=255), nullable=False),
        sa.Column("slug", sa.String(length=64), nullable=False),
        sa.Column("description", sa.Text(), nullable=True),
        sa.Column("game_type", sa.String(length=64), nullable=False),
        sa.Column("difficulty", sa.String(length=32), nullable=False),
        sa.Column("estimated_duration_minutes", sa.Integer(), nullable=True),
        sa.Column("active", sa.Boolean(), nullable=False),
        sa.Column("instructions", sa.Text(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("deleted_at", sa.DateTime(timezone=True), nullable=True),
        sa.PrimaryKeyConstraint("id", name="pk_game_definitions"),
        sa.UniqueConstraint("slug", name="uq_game_definitions_slug"),
    )

    op.create_table(
        "game_results",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("game_definition_id", sa.Uuid(), nullable=False),
        sa.Column("patient_profile_id", sa.Uuid(), nullable=False),
        sa.Column("user_id", sa.Uuid(), nullable=False),
        sa.Column("score", sa.Integer(), nullable=True),
        sa.Column("max_score", sa.Integer(), nullable=True),
        sa.Column("accuracy_percent", sa.Float(), nullable=True),
        sa.Column("duration_seconds", sa.Integer(), nullable=True),
        sa.Column("completed", sa.Boolean(), nullable=False),
        sa.Column("metrics", sa.JSON(), nullable=True),
        sa.Column("started_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("completed_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.PrimaryKeyConstraint("id", name="pk_game_results"),
        sa.ForeignKeyConstraint(
            ["game_definition_id"],
            ["game_definitions.id"],
            name="fk_game_results_game_definition_id_game_definitions",
        ),
        sa.ForeignKeyConstraint(
            ["patient_profile_id"],
            ["patient_profiles.id"],
            name="fk_game_results_patient_profile_id_patient_profiles",
        ),
        sa.ForeignKeyConstraint(
            ["user_id"], ["users.id"], name="fk_game_results_user_id_users"
        ),
    )


def downgrade() -> None:
    op.drop_table("game_results")
    op.drop_table("game_definitions")
