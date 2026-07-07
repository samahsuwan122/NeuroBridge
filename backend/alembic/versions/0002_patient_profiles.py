"""patient profiles, assignments, and family links

Revision ID: 0002_patient_profiles
Revises: 0001_initial
Create Date: 2026-07-07

Creates patient_profiles, patient_assignments, and patient_family_links. These
reference the existing users/medical_centers tables one-directionally (no
circular FK), so no batch ALTER is required. Portable types (sa.Uuid, sa.Date,
sa.Boolean) keep it SQLite-friendly and PostgreSQL-ready.
"""

from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op

# revision identifiers, used by Alembic.
revision: str = "0002_patient_profiles"
down_revision: Union[str, None] = "0001_initial"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "patient_profiles",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("user_id", sa.Uuid(), nullable=False),
        sa.Column("medical_center_id", sa.Uuid(), nullable=True),
        sa.Column("date_of_birth", sa.Date(), nullable=True),
        sa.Column("gender", sa.String(length=32), nullable=True),
        sa.Column("emergency_contact_name", sa.String(length=255), nullable=True),
        sa.Column("emergency_contact_phone", sa.String(length=50), nullable=True),
        sa.Column("notes", sa.Text(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("deleted_at", sa.DateTime(timezone=True), nullable=True),
        sa.PrimaryKeyConstraint("id", name="pk_patient_profiles"),
        sa.UniqueConstraint("user_id", name="uq_patient_profiles_user_id"),
        sa.ForeignKeyConstraint(
            ["user_id"], ["users.id"], name="fk_patient_profiles_user_id_users"
        ),
        sa.ForeignKeyConstraint(
            ["medical_center_id"],
            ["medical_centers.id"],
            name="fk_patient_profiles_medical_center_id_medical_centers",
        ),
    )

    op.create_table(
        "patient_assignments",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("patient_profile_id", sa.Uuid(), nullable=False),
        sa.Column("clinician_user_id", sa.Uuid(), nullable=False),
        sa.Column("assignment_type", sa.String(length=32), nullable=False),
        sa.Column("active", sa.Boolean(), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False),
        sa.PrimaryKeyConstraint("id", name="pk_patient_assignments"),
        sa.ForeignKeyConstraint(
            ["patient_profile_id"],
            ["patient_profiles.id"],
            name="fk_patient_assignments_patient_profile_id_patient_profiles",
        ),
        sa.ForeignKeyConstraint(
            ["clinician_user_id"],
            ["users.id"],
            name="fk_patient_assignments_clinician_user_id_users",
        ),
        sa.UniqueConstraint(
            "patient_profile_id",
            "clinician_user_id",
            "assignment_type",
            name="uq_patient_assignments_profile_clinician_type",
        ),
    )

    op.create_table(
        "patient_family_links",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("patient_profile_id", sa.Uuid(), nullable=False),
        sa.Column("family_user_id", sa.Uuid(), nullable=False),
        sa.Column("relationship", sa.String(length=64), nullable=True),
        sa.Column("active", sa.Boolean(), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False),
        sa.PrimaryKeyConstraint("id", name="pk_patient_family_links"),
        sa.ForeignKeyConstraint(
            ["patient_profile_id"],
            ["patient_profiles.id"],
            name="fk_patient_family_links_patient_profile_id_patient_profiles",
        ),
        sa.ForeignKeyConstraint(
            ["family_user_id"],
            ["users.id"],
            name="fk_patient_family_links_family_user_id_users",
        ),
        sa.UniqueConstraint(
            "patient_profile_id",
            "family_user_id",
            name="uq_patient_family_links_profile_family",
        ),
    )


def downgrade() -> None:
    op.drop_table("patient_family_links")
    op.drop_table("patient_assignments")
    op.drop_table("patient_profiles")
