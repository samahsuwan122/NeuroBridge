"""appointment booking: providers availability + appointment provider/mode

Revision ID: 0008_appointment_booking
Revises: 0007_appointments
Create Date: 2026-07-13

Adds provider_availability_slots (bookable slots offered by doctors/therapists)
and extends appointments with provider_user_id, availability_slot_id,
appointment_mode, location, and meeting_url so a family can book a real slot.

Columns are added without inline FK constraints (portable/SQLite-friendly); the
ORM models declare the relationships. Portable types keep it PostgreSQL-ready.

MEDICAL SAFETY: scheduling/coordination content only — never emergency care,
diagnosis, assessment, or treatment.
"""

from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op

# revision identifiers, used by Alembic.
revision: str = "0008_appointment_booking"
down_revision: Union[str, None] = "0007_appointments"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "provider_availability_slots",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("provider_user_id", sa.Uuid(), nullable=False),
        sa.Column("slot_date", sa.Date(), nullable=False),
        sa.Column("start_time", sa.String(length=16), nullable=False),
        sa.Column("end_time", sa.String(length=16), nullable=False),
        sa.Column("appointment_mode", sa.String(length=32), nullable=False),
        sa.Column("location", sa.String(length=255), nullable=True),
        sa.Column("meeting_url", sa.String(length=1024), nullable=True),
        sa.Column("is_available", sa.Boolean(), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("deleted_at", sa.DateTime(timezone=True), nullable=True),
        sa.PrimaryKeyConstraint("id", name="pk_provider_availability_slots"),
        sa.ForeignKeyConstraint(
            ["provider_user_id"],
            ["users.id"],
            name="fk_provider_availability_slots_provider_user_id_users",
        ),
    )

    op.add_column(
        "appointments",
        sa.Column("provider_user_id", sa.Uuid(), nullable=True),
    )
    op.add_column(
        "appointments",
        sa.Column("availability_slot_id", sa.Uuid(), nullable=True),
    )
    op.add_column(
        "appointments",
        sa.Column(
            "appointment_mode",
            sa.String(length=32),
            nullable=False,
            server_default="in_person",
        ),
    )
    op.add_column(
        "appointments",
        sa.Column("location", sa.String(length=255), nullable=True),
    )
    op.add_column(
        "appointments",
        sa.Column("meeting_url", sa.String(length=1024), nullable=True),
    )


def downgrade() -> None:
    op.drop_column("appointments", "meeting_url")
    op.drop_column("appointments", "location")
    op.drop_column("appointments", "appointment_mode")
    op.drop_column("appointments", "availability_slot_id")
    op.drop_column("appointments", "provider_user_id")
    op.drop_table("provider_availability_slots")
