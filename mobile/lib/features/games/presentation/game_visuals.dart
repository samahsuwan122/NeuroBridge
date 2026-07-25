import 'package:flutter/material.dart';

import '../data/game_definition.dart';

/// A premium icon for a game, chosen by slug then game type (display only).
IconData gameIcon(GameDefinition game) {
  switch (game.slug) {
    case 'memory_match':
      return Icons.grid_view_rounded;
    case 'memory_recall':
      return Icons.photo_library_rounded;
  }
  switch (game.gameType) {
    case 'attention':
      return Icons.center_focus_strong_rounded;
    case 'reaction':
      return Icons.bolt_rounded;
    case 'sequence':
      return Icons.reorder_rounded;
    case 'recall':
      return Icons.photo_library_rounded;
    case 'memory':
      return Icons.style_rounded;
  }
  return Icons.videogame_asset_rounded;
}
