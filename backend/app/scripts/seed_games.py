"""Seed the default cognitive-exercise game definitions.

Idempotent: existing games (matched by slug) are skipped. Names/slugs are
neutral exercise labels — not medical tests.

Run from the backend/ folder:

    python -m app.scripts.seed_games
"""

from typing import Any, Dict, List

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models import GameDefinition

DEFAULT_GAMES: List[Dict[str, Any]] = [
    {
        "slug": "memory_match",
        "name": "Memory Match",
        "game_type": "memory",
        "difficulty": "easy",
        "estimated_duration_minutes": 5,
        "description": "Match pairs of cards to exercise short-term memory.",
        "instructions": "Flip two cards at a time and find matching pairs.",
    },
    {
        "slug": "attention_focus",
        "name": "Attention Focus",
        "game_type": "attention",
        "difficulty": "easy",
        "estimated_duration_minutes": 4,
        "description": "Select the target items to exercise focused attention.",
        "instructions": "Tap only the highlighted targets as they appear.",
    },
    {
        "slug": "reaction_time",
        "name": "Reaction Time",
        "game_type": "reaction",
        "difficulty": "easy",
        "estimated_duration_minutes": 3,
        "description": "Respond quickly to prompts to exercise reaction speed.",
        "instructions": "Tap the button as soon as the signal appears.",
    },
    {
        "slug": "sequence_order",
        "name": "Sequence Order",
        "game_type": "sequence",
        "difficulty": "medium",
        "estimated_duration_minutes": 5,
        "description": "Recall and repeat sequences to exercise working memory.",
        "instructions": "Watch the sequence, then repeat it in the same order.",
    },
]

DEFAULT_GAME_SLUGS: List[str] = [g["slug"] for g in DEFAULT_GAMES]


def seed_games(session: Session) -> Dict[str, List[str]]:
    """Create any missing default games. Returns created/skipped slugs."""
    created: List[str] = []
    skipped: List[str] = []

    for game in DEFAULT_GAMES:
        existing = session.execute(
            select(GameDefinition).where(GameDefinition.slug == game["slug"])
        ).scalar_one_or_none()
        if existing is not None:
            skipped.append(game["slug"])
            continue
        session.add(GameDefinition(active=True, **game))
        created.append(game["slug"])

    session.commit()
    return {"created": created, "skipped": skipped}


def main() -> None:
    from app.db.session import SessionLocal

    session = SessionLocal()
    try:
        result = seed_games(session)
    finally:
        session.close()

    print(
        "Created games: "
        + (", ".join(result["created"]) if result["created"] else "(none)")
    )
    print(
        "Skipped (already present): "
        + (", ".join(result["skipped"]) if result["skipped"] else "(none)")
    )


if __name__ == "__main__":
    main()
