import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../state/game_controller.dart';
import '../../state/game_state.dart';
import '../../ui/stitch_scaffold.dart';
import '../../ui/stitch_theme.dart';

class ScoreboardScreen extends ConsumerWidget {
  const ScoreboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameControllerProvider);
    final controller = ref.read(gameControllerProvider.notifier);

    final imposterId = game.imposterPlayerId;
    final majorityId = game.majorityVotedPlayerId;

    final scores = game.scoresByPlayerId;

    final imposterName = _nameForId(game.players, imposterId);
    final majorityName = _nameForId(game.players, majorityId);

    return StitchScaffold(
      title: 'Leaderboard',
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Majority voted for: ${majorityName ?? '—'}',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(color: StitchColors.secondary),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Imposter revealed: ${imposterName ?? '—'}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: StitchColors.primary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Scores', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.separated(
                  itemCount: game.players.length,
                  separatorBuilder: (_, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final p = game.players[index];
                    final points = scores[p.id] ?? 0;
                    return ListTile(
                      title: Text(p.name),
                      trailing: Text(
                        '$points pts',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: StitchColors.tertiary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        p.id == imposterId ? 'Imposter' : 'Player',
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ChunkyButton(
                      onPressed: () {
                        controller.playAgainToLobby();
                        context.go('/lobby');
                      },
                      label: 'PLAY AGAIN',
                      background: StitchColors.tertiary,
                      foreground: StitchColors.onTertiary,
                      shadow: const Color(0xFF095300),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ChunkyButton(
                onPressed: () {
                  controller.resetToHome();
                  context.go('/');
                },
                label: 'BACK TO HOME',
                background: StitchColors.secondary,
                foreground: StitchColors.onSecondary,
                shadow: const Color(0xFF4B007E),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String? _nameForId(List<WhoLiedPlayer> players, String? id) {
    if (id == null) return null;
    final p = players.where((e) => e.id == id).toList();
    if (p.isEmpty) return null;
    return p.first.name;
  }
}
