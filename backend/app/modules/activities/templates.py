"""Predefined, safe activity templates and content generation.

Care-team members never write raw activity code. They pick a `template_type`
and a difficulty; the server fills in fixed, safe exercise parameters here.

MEDICAL SAFETY: everything in this module is generic cognitive-exercise content
(word lists, sequence lengths, round counts, neutral orientation prompts). There
is deliberately NO medical vocabulary, diagnosis, treatment, prediction, or any
scoring of a condition. The generated content is plain gameplay parameters.
"""

from typing import Dict, List

# Canonical template types (kept stable — the mobile app maps these to screens).
TEMPLATE_MEMORY_RECALL = "memory_recall"
TEMPLATE_ATTENTION_FOCUS = "attention_focus"
TEMPLATE_REACTION_TIME = "reaction_time"
TEMPLATE_SEQUENCE_RECALL = "sequence_recall"
TEMPLATE_MATCHING_GAME = "matching_game"
TEMPLATE_DAILY_ORIENTATION = "daily_orientation"

TEMPLATE_TYPES: List[str] = [
    TEMPLATE_MEMORY_RECALL,
    TEMPLATE_ATTENTION_FOCUS,
    TEMPLATE_REACTION_TIME,
    TEMPLATE_SEQUENCE_RECALL,
    TEMPLATE_MATCHING_GAME,
    TEMPLATE_DAILY_ORIENTATION,
]

DIFFICULTIES: List[str] = ["easy", "medium", "hard"]

# Difficulty → level index (0 easy, 1 medium, 2 hard).
_LEVEL = {"easy": 0, "medium": 1, "hard": 2}

# A small, neutral pool of everyday words (no medical terms).
_WORD_POOL = [
    "apple", "river", "chair", "garden", "candle", "orange", "window",
    "pillow", "basket", "guitar", "yellow", "mountain", "cookie", "flower",
    "bicycle", "morning",
]

# Per-template defaults: friendly title + supportive, non-diagnostic instructions
# and an optional playable game slug the mobile app may open directly.
TEMPLATE_DEFAULTS: Dict[str, Dict[str, str]] = {
    TEMPLATE_MEMORY_RECALL: {
        "label": "Memory Recall",
        "title": "Memory Recall",
        "instructions": (
            "Look at the words, then try to remember as many as you can. "
            "Take your time — there is no rush."
        ),
        "game_slug": "memory-match",
    },
    TEMPLATE_ATTENTION_FOCUS: {
        "label": "Attention Focus",
        "title": "Attention Focus",
        "instructions": (
            "Find and tap the target shape each time it appears. "
            "Stay relaxed and go at your own pace."
        ),
        "game_slug": "attention-focus",
    },
    TEMPLATE_REACTION_TIME: {
        "label": "Reaction Time",
        "title": "Reaction Time",
        "instructions": (
            "Tap the button as soon as it lights up. "
            "It is just for practice — enjoy it."
        ),
        "game_slug": "reaction-time",
    },
    TEMPLATE_SEQUENCE_RECALL: {
        "label": "Sequence Recall",
        "title": "Sequence Recall",
        "instructions": (
            "Watch the sequence, then repeat it in the same order. "
            "Take a breath and try your best."
        ),
        "game_slug": "sequence-recall",
    },
    TEMPLATE_MATCHING_GAME: {
        "label": "Matching Game",
        "title": "Matching Game",
        "instructions": (
            "Turn over the cards and find the matching pairs. "
            "There is no time pressure — have fun."
        ),
        "game_slug": "matching-pairs",
    },
    TEMPLATE_DAILY_ORIENTATION: {
        "label": "Daily Orientation",
        "title": "Daily Orientation",
        "instructions": (
            "Answer a few gentle everyday questions about today. "
            "This is a simple, friendly warm-up."
        ),
        "game_slug": "",
    },
}

# Neutral, everyday orientation prompts (no medical or clinical content).
_ORIENTATION_PROMPTS = [
    "What day of the week is it today?",
    "What month are we in?",
    "What season is it right now?",
    "What is a meal you enjoyed recently?",
    "Name something you can see near you right now.",
]


def is_valid_template(template_type: str) -> bool:
    return template_type in TEMPLATE_TYPES


def is_valid_difficulty(difficulty: str) -> bool:
    return difficulty in DIFFICULTIES


def default_title(template_type: str) -> str:
    return TEMPLATE_DEFAULTS.get(template_type, {}).get("title", "Activity")


def default_instructions(template_type: str) -> str:
    return TEMPLATE_DEFAULTS.get(template_type, {}).get("instructions", "")


def game_slug(template_type: str) -> str:
    """The playable game slug for this template, or '' if it is preview-only."""
    return TEMPLATE_DEFAULTS.get(template_type, {}).get("game_slug", "")


def build_activity_content(template_type: str, difficulty: str) -> Dict:
    """Return safe, fixed exercise parameters for a template + difficulty.

    Pure function (no I/O). The output is plain gameplay parameters only.
    """
    level = _LEVEL.get(difficulty, 0)
    content: Dict = {
        "kind": template_type,
        "difficulty": difficulty,
        "game_slug": game_slug(template_type),
    }

    if template_type == TEMPLATE_MEMORY_RECALL:
        count = (4, 6, 8)[level]
        content.update(
            {"items": _WORD_POOL[:count], "rounds": (1, 2, 3)[level],
             "display_seconds": (8, 6, 5)[level]}
        )
    elif template_type == TEMPLATE_ATTENTION_FOCUS:
        content.update(
            {"target": "★", "grid_size": (3, 4, 5)[level],
             "rounds": (6, 9, 12)[level]}
        )
    elif template_type == TEMPLATE_REACTION_TIME:
        content.update(
            {"rounds": (5, 8, 12)[level], "min_delay_ms": 800, "max_delay_ms": 2500}
        )
    elif template_type == TEMPLATE_SEQUENCE_RECALL:
        content.update(
            {"sequence_length": (3, 4, 5)[level], "rounds": (2, 3, 4)[level]}
        )
    elif template_type == TEMPLATE_MATCHING_GAME:
        content.update({"pairs": (4, 6, 8)[level]})
    elif template_type == TEMPLATE_DAILY_ORIENTATION:
        count = (3, 4, 5)[level]
        content.update({"prompts": _ORIENTATION_PROMPTS[:count]})

    return content
