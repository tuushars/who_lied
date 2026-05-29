import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../state/game_controller.dart';
import '../../ui/stitch_scaffold.dart';
import '../../ui/stitch_theme.dart';

class DiscussionScreen extends ConsumerWidget {
  const DiscussionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameControllerProvider);
    final controller = ref.read(gameControllerProvider.notifier);

    return StitchScaffold(
      title: 'Phase 2: Discuss',
      bottomItem: StitchNavItem.discuss,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'THE CLUE TRAIL · ${game.discussionSecondsRemaining}s',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: StitchColors.secondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (game.discussionPhaseLocked)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Discussion time is over.',
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(height: 16),
            Text('All clues', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                itemCount: game.players.length,
                separatorBuilder: (_, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final p = game.players[index];
                  final clue = game.cluesByPlayerId[p.id];
                  return ListTile(
                    title: Text(p.name),
                    subtitle: Text(clue ?? '— missing —'),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            if (game.hostId == game.myPlayerId) ChunkyButton(
              onPressed: game.discussionPhaseLocked
                  ? () {
                      controller.beginVotingPhase();
                      context.go('/voting');
                    }
                  : null,
              label: 'CONTINUE TO VOTING',
              background: StitchColors.secondary,
              foreground: StitchColors.onSecondary,
              shadow: const Color(0xFF4B007E),
            ),
          ],
        ),
      ),
    );
  }
}
