"""Cognitive games routes.

- Listing/getting games: any authenticated active user.
- Creating/updating game definitions: admin only.
- Submitting results: patient only, for their own profile.
- Listing results: scoped by role (admin=all, doctor/therapist=assigned,
  patient=own, family=linked, manager=same center).
"""

import uuid
from contextlib import contextmanager
from typing import Optional

from fastapi import APIRouter, Depends, HTTPException, Query, Request, status
from sqlalchemy.orm import Session

from app.core.permissions import ROLE_ADMIN, ROLE_PATIENT
from app.db.session import get_db
from app.models import GameDefinition, GameResult, User
from app.modules.auth.dependencies import get_current_active_user, require_roles
from app.modules.auth.service import get_role_names
from app.modules.games import service
from app.modules.games.schemas import (
    GameDefinitionCreate,
    GameDefinitionResponse,
    GameDefinitionUpdate,
    GameListResponse,
    GameResultCreate,
    GameResultListResponse,
    GameResultResponse,
)

router = APIRouter(prefix="/api/v1/games", tags=["games"])

admin_required = require_roles([ROLE_ADMIN])
patient_required = require_roles([ROLE_PATIENT])


@contextmanager
def _translate_game_errors():
    try:
        yield
    except service.DuplicateSlugError:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="A game with this slug already exists.",
        )
    except service.InactiveGameError:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="This game is not active.",
        )
    except service.ProfileNotFoundError:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Patient profile not found.",
        )
    except service.NotOwnProfileError:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You can only submit results for your own profile.",
        )


def _client_info(request: Request) -> tuple[str | None, str | None]:
    ip_address = request.client.host if request.client else None
    device_info = request.headers.get("user-agent")
    return ip_address, device_info


def _game_response(game: GameDefinition) -> GameDefinitionResponse:
    return GameDefinitionResponse.model_validate(game)


def _result_response(result: GameResult) -> GameResultResponse:
    return GameResultResponse.model_validate(result)


def _require_game(db: Session, game_id: uuid.UUID) -> GameDefinition:
    game = service.get_game(db, game_id)
    if game is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Game not found."
        )
    return game


# --- game definitions --------------------------------------------------------


@router.get("", response_model=GameListResponse)
def list_games(
    include_inactive: bool = Query(default=False),
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db),
) -> GameListResponse:
    # Only admins may include inactive games.
    allow_inactive = False
    if include_inactive:
        roles = get_role_names(db, current_user.id)
        allow_inactive = ROLE_ADMIN in set(roles)
    games, total = service.list_games(db, include_inactive=allow_inactive)
    return GameListResponse(total=total, games=[_game_response(g) for g in games])


@router.post(
    "", response_model=GameDefinitionResponse, status_code=status.HTTP_201_CREATED
)
def create_game(
    payload: GameDefinitionCreate,
    request: Request,
    admin: User = Depends(admin_required),
    db: Session = Depends(get_db),
) -> GameDefinitionResponse:
    ip_address, device_info = _client_info(request)
    with _translate_game_errors():
        game = service.create_game(
            db,
            fields=payload.model_dump(),
            actor_user_id=admin.id,
            ip_address=ip_address,
            device_info=device_info,
        )
    return _game_response(game)


# NOTE: /results is declared before /{game_id} so it is not captured as an id.
@router.get("/results", response_model=GameResultListResponse)
def list_results(
    patient_profile_id: Optional[uuid.UUID] = Query(default=None),
    game_definition_id: Optional[uuid.UUID] = Query(default=None),
    limit: int = Query(default=50, ge=1, le=200),
    offset: int = Query(default=0, ge=0),
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db),
) -> GameResultListResponse:
    roles = get_role_names(db, current_user.id)
    results, total = service.list_results(
        db,
        current_user,
        roles,
        patient_profile_id=patient_profile_id,
        game_definition_id=game_definition_id,
        limit=limit,
        offset=offset,
    )
    return GameResultListResponse(
        total=total,
        limit=limit,
        offset=offset,
        results=[_result_response(r) for r in results],
    )


@router.get("/{game_id}", response_model=GameDefinitionResponse)
def get_game(
    game_id: uuid.UUID,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db),
) -> GameDefinitionResponse:
    return _game_response(_require_game(db, game_id))


@router.put("/{game_id}", response_model=GameDefinitionResponse)
def update_game(
    game_id: uuid.UUID,
    payload: GameDefinitionUpdate,
    request: Request,
    admin: User = Depends(admin_required),
    db: Session = Depends(get_db),
) -> GameDefinitionResponse:
    game = _require_game(db, game_id)
    ip_address, device_info = _client_info(request)
    with _translate_game_errors():
        game = service.update_game(
            db,
            game=game,
            fields=payload.model_dump(exclude_unset=True),
            actor_user_id=admin.id,
            ip_address=ip_address,
            device_info=device_info,
        )
    return _game_response(game)


@router.post(
    "/{game_id}/results",
    response_model=GameResultResponse,
    status_code=status.HTTP_201_CREATED,
)
def submit_result(
    game_id: uuid.UUID,
    payload: GameResultCreate,
    request: Request,
    current_user: User = Depends(patient_required),
    db: Session = Depends(get_db),
) -> GameResultResponse:
    game = _require_game(db, game_id)
    ip_address, device_info = _client_info(request)
    with _translate_game_errors():
        result = service.submit_result(
            db,
            game=game,
            submitting_user=current_user,
            patient_profile_id=payload.patient_profile_id,
            score=payload.score,
            max_score=payload.max_score,
            accuracy_percent=payload.accuracy_percent,
            duration_seconds=payload.duration_seconds,
            completed=payload.completed,
            metrics=payload.metrics,
            started_at=payload.started_at,
            completed_at=payload.completed_at,
            ip_address=ip_address,
            device_info=device_info,
        )
    return _result_response(result)
