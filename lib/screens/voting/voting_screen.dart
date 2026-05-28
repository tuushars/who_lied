import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../state/game_controller.dart';
import '../../state/game_state.dart';
import '../../ui/stitch_scaffold.dart';
import '../../ui/stitch_theme.dart';

class VotingScreen extends ConsumerWidget {
  const VotingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameControllerProvider);
    final controller = ref.read(gameControllerProvider.notifier);

    final myId = game.myPlayerId;
    final myVote = (myId == null) ? null : game.votesByVoterId[myId];

    final players = game.players;

    final votesSummary = <String, int>{};
    for (final votedId in game.votesByVoterId.values) {
      votesSummary[votedId] = (votesSummary[votedId] ?? 0) + 1;
    }

    return StitchScaffold(
      title: 'Phase 3: Vote',
      bottomItem: StitchNavItem.vote,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Cast your vote for the Imposter',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: StitchColors.secondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              myVote == null
                  ? 'You have not voted yet.'
                  : 'You voted: ${_nameForId(game.players, myVote)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: players.length,
                separatorBuilder: (_, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final p = players[index];
                  final count = votesSummary[p.id] ?? 0;
                  final isMineVote = myVote == p.id;

                  return ListTile(
                    title: Text(p.name),
                    subtitle: Text('$count vote${count == 1 ? '' : 's'}'),
                    trailing: myVote != null
                        ? (isMineVote
                              ? const Chip(label: Text('Your vote'))
                              : null)
                        : FilledButton(
                            onPressed: () {
                              controller.submitMyVote(p.id);
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: StitchColors.primaryContainer,
                            ),
                            child: const Text('Vote'),
                          ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            if (game.players.any((p) => p.isBot))
              OutlinedButton.icon(
                onPressed: controller.botCastOneVote,
                icon: const Icon(Icons.auto_awesome_outlined),
                label: const Text('Simulate Bot Vote'),
              ),
            const SizedBox(height: 12),
            ChunkyButton(
              onPressed: game.votesByVoterId.isEmpty
                  ? null
                  : () {
                      controller.revealAndScore();
                      context.go('/scoreboard');
                    },
              label: 'REVEAL & SCORE',
              background: StitchColors.tertiary,
              foreground: StitchColors.onTertiary,
              shadow: const Color(0xFF095300),
            ),
          ],
        ),
      ),
    );
  }

  static String _nameForId(List<WhoLiedPlayer> players, String? id) {
    if (id == null) return '';
    final p = players.where((e) => e.id == id).toList();
    if (p.isEmpty) return '';
    return p.first.name;
  }
}
