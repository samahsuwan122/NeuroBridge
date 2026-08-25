"""add missing appointment booking foreign keys

Revision ID: 0018_appointment_foreign_keys
Revises: 0017_provider_profile_languages

Migration 0008 added the nullable booking columns without their ORM-declared
foreign keys.  Batch alteration keeps this migration compatible with SQLite
while preserving all existing appointment rows.
"""

from typing import Sequence, Union

from alembic import op


revision: str = "0018_appointment_foreign_keys"
down_revision: Union[str, None] = "0017_provider_profile_languages"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    with op.batch_alter_table("appointments") as batch_op:
        batch_op.create_foreign_key(
            "fk_appointments_provider_user_id_users",
            "users",
            ["provider_user_id"],
            ["id"],
        )
        batch_op.create_foreign_key(
            "fk_appointments_availability_slot_id_provider_availability_slots",
            "provider_availability_slots",
            ["availability_slot_id"],
            ["id"],
        )


def downgrade() -> None:
    with op.batch_alter_table("appointments") as batch_op:
        batch_op.drop_constraint(
            "fk_appointments_availability_slot_id_provider_availability_slots",
            type_="foreignkey",
        )
        batch_op.drop_constraint(
            "fk_appointments_provider_user_id_users",
            type_="foreignkey",
        )
