"""provider profile extra: governorate/city/phone/photo

Revision ID: 0010_provider_profile_extra
Revises: 0009_provider_profiles
Create Date: 2026-07-14

Adds governorate, city, phone_number_demo (demo contact only), and photo_url to
provider_profiles for the doctor-directory booking page. Portable/SQLite-friendly
plain columns.

DEMO USE: all values are seeded demo values only — no real clinicians, phone
numbers, or photos. MEDICAL SAFETY: scheduling/coordination content only.
"""

from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op

# revision identifiers, used by Alembic.
revision: str = "0010_provider_profile_extra"
down_revision: Union[str, None] = "0009_provider_profiles"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column(
        "provider_profiles",
        sa.Column("governorate", sa.String(length=64), nullable=True),
    )
    op.add_column(
        "provider_profiles",
        sa.Column("city", sa.String(length=64), nullable=True),
    )
    op.add_column(
        "provider_profiles",
        sa.Column("phone_number_demo", sa.String(length=32), nullable=True),
    )
    op.add_column(
        "provider_profiles",
        sa.Column("photo_url", sa.String(length=1024), nullable=True),
    )


def downgrade() -> None:
    op.drop_column("provider_profiles", "photo_url")
    op.drop_column("provider_profiles", "phone_number_demo")
    op.drop_column("provider_profiles", "city")
    op.drop_column("provider_profiles", "governorate")
