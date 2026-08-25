"""provider profile semantic languages

Revision ID: 0017_provider_profile_languages
Revises: 0016_ai_chat
"""
from alembic import op
import sqlalchemy as sa

revision = "0017_provider_profile_languages"
down_revision = "0016_ai_chat"
branch_labels = None
depends_on = None

def upgrade() -> None:
    op.add_column("provider_profiles", sa.Column("languages", sa.String(length=64), nullable=True))

def downgrade() -> None:
    op.drop_column("provider_profiles", "languages")
