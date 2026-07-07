"""Cognitive games business logic and result visibility.

HTTP-free: routes translate the domain exceptions below into HTTP responses.
Result visibility reuses the patient-profile visibility rules so access control
lives in one place. Scores are exercise performance only — no diagnosis.
"""

import uuid
from datetime import datetime
from typing import Any, Dict, Iterable, List, Optional, Tuple

from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.models import GameDefinition, GameResult, PatientProfile, User
from app.modules.audit.service import record_audit
from app.modules.patients.service import visible_patient_profile_ids


# --- domain exceptions -------------------------------------------------------


class GameError(Exception):
    """Base class for games-service domain errors."""


class DuplicateSlugError(GameError):
    """A game with this slug already exists."""


class InactiveGameError(GameError):
    """Results cannot be submitted for an inactive game."""


class ProfileNotFoundError(GameError):
    """The referenced patient profile does not exist."""


class NotOwnProfileError(GameError):
    """A patient may only submit results for their own profile."""


# --- game definition queries -------------------------------------------------


def _slug_exists(
    session: Session, slug: str, exclude_game_id: Optional[uuid.UUID] = None
) -> bool:
    stmt = select(GameDefinition.id).where(
        GameDefinition.slug == slug, GameDefinition.deleted_at.is_(None)
    )
    if exclude_game_id is not None:
        stmt = stmt.where(GameDefinition.id != exclude_game_id)
    return session.execute(stmt).first() is not None


def get_game(session: Session, game_id: uuid.UUID) -> Optional[GameDefinition]:
    game = session.get(GameDefinition, game_id)
    if game is None or game.deleted_at is not None:
        return None
    return game


def list_games(
    session: Session, include_inactive: bool = False
) -> Tuple[List[GameDefinition], int]:
    stmt = select(GameDefinition).where(GameDefinition.deleted_at.is_(None))
    if not include_inactive:
        stmt = stmt.where(GameDefinition.active.is_(True))
    stmt = stmt.order_by(GameDefinition.name)
    rows = session.execute(stmt).scalars().all()
    return list(rows), len(rows)


# --- game definition mutations -----------------------------------------------


_GAME_FIELDS = (
    "name",
    "slug",
    "game_type",
    "description",
    "difficulty",
    "estimated_duration_minutes",
    "instructions",
    "active",
)


def create_game(
    session: Session,
    *,
    fields: dict,
    actor_user_id: Optional[uuid.UUID] = None,
    ip_address: Optional[str] = None,
    device_info: Optional[str] = None,
) -> GameDefinition:
    if _slug_exists(session, fields["slug"]):
        raise DuplicateSlugError()
    game = GameDefinition(
        name=fields["name"],
        slug=fields["slug"],
        game_type=fields["game_type"],
        description=fields.get("description"),
        difficulty=fields.get("difficulty", "easy"),
        estimated_duration_minutes=fields.get("estimated_duration_minutes"),
        instructions=fields.get("instructions"),
        active=fields.get("active", True),
    )
    session.add(game)
    session.flush()
    record_audit(
        session,
        action="create_game_definition",
        entity_type="GameDefinition",
        actor_user_id=actor_user_id,
        entity_id=game.id,
        ip_address=ip_address,
        device_info=device_info,
        commit=False,
    )
    session.commit()
    return game


def update_game(
    session: Session,
    *,
    game: GameDefinition,
    fields: dict,
    actor_user_id: Optional[uuid.UUID] = None,
    ip_address: Optional[str] = None,
    device_info: Optional[str] = None,
) -> GameDefinition:
    if "slug" in fields and fields["slug"] != game.slug:
        if _slug_exists(session, fields["slug"], exclude_game_id=game.id):
            raise DuplicateSlugError()
    for key in _GAME_FIELDS:
        if key in fields:
            setattr(game, key, fields[key])
    session.add(game)
    record_audit(
        session,
        action="update_game_definition",
        entity_type="GameDefinition",
        actor_user_id=actor_user_id,
        entity_id=game.id,
        ip_address=ip_address,
        device_info=device_info,
        commit=False,
    )
    session.commit()
    return game


# --- game results ------------------------------------------------------------


def submit_result(
    session: Session,
    *,
    game: GameDefinition,
    submitting_user: User,
    patient_profile_id: uuid.UUID,
    score: Optional[int] = None,
    max_score: Optional[int] = None,
    accuracy_percent: Optional[float] = None,
    duration_seconds: Optional[int] = None,
    completed: bool = True,
    metrics: Optional[Dict[str, Any]] = None,
    started_at: Optional[datetime] = None,
    completed_at: Optional[datetime] = None,
    ip_address: Optional[str] = None,
    device_info: Optional[str] = None,
) -> GameResult:
    if not game.active:
        raise InactiveGameError()

    profile = session.get(PatientProfile, patient_profile_id)
    if profile is None or profile.deleted_at is not None:
        raise ProfileNotFoundError()
    # A patient may only submit results for their own profile.
    if profile.user_id != submitting_user.id:
        raise NotOwnProfileError()

    result = GameResult(
        game_definition_id=game.id,
        patient_profile_id=patient_profile_id,
        user_id=submitting_user.id,
        score=score,
        max_score=max_score,
        accuracy_percent=accuracy_percent,
        duration_seconds=duration_seconds,
        completed=completed,
        metrics=metrics,
        started_at=started_at,
        completed_at=completed_at,
    )
    session.add(result)
    session.flush()
    record_audit(
        session,
        action="submit_game_result",
        entity_type="GameResult",
        actor_user_id=submitting_user.id,
        entity_id=result.id,
        ip_address=ip_address,
        device_info=device_info,
        metadata={
            "game_definition_id": str(game.id),
            "patient_profile_id": str(patient_profile_id),
        },
        commit=False,
    )
    session.commit()
    return result


def list_results(
    session: Session,
    viewer: User,
    roles: Iterable[str],
    *,
    patient_profile_id: Optional[uuid.UUID] = None,
    game_definition_id: Optional[uuid.UUID] = None,
    limit: int = 50,
    offset: int = 0,
) -> Tuple[List[GameResult], int]:
    # Determine which patient profiles the viewer may see (None == all/admin).
    visible = visible_patient_profile_ids(session, viewer, roles)

    conditions = []
    if visible is not None:
        if not visible:
            return [], 0
        # If a specific profile is requested, it must be within the visible set.
        if patient_profile_id is not None and patient_profile_id not in visible:
            return [], 0
        conditions.append(GameResult.patient_profile_id.in_(visible))

    if patient_profile_id is not None:
        conditions.append(GameResult.patient_profile_id == patient_profile_id)
    if game_definition_id is not None:
        conditions.append(GameResult.game_definition_id == game_definition_id)

    total = session.execute(
        select(func.count()).select_from(GameResult).where(*conditions)
    ).scalar_one()
    rows = (
        session.execute(
            select(GameResult)
            .where(*conditions)
            .order_by(GameResult.created_at.desc())
            .limit(limit)
            .offset(offset)
        )
        .scalars()
        .all()
    )
    return list(rows), int(total)
