import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../state/game_controller.dart';
import '../../ui/stitch_scaffold.dart';
import '../../ui/stitch_theme.dart';

class CluesScreen extends ConsumerStatefulWidget {
  const CluesScreen({super.key});

  @override
  ConsumerState<CluesScreen> createState() => _CluesScreenState();
}

class _CluesScreenState extends ConsumerState<CluesScreen> {
  final _clueController = TextEditingController();

  @override
  void dispose() {
    _clueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameControllerProvider);
    final controller = ref.read(gameControllerProvider.notifier);

    final myId = game.myPlayerId;
    final myClueSubmitted =
        myId != null && game.cluesByPlayerId.containsKey(myId);

    return StitchScaffold(
      title: 'WhoLied?',
      bottomItem: StitchNavItem.clue,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'CLUE PHASE · ${game.clueSecondsRemaining}s',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: StitchColors.secondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (game.cluePhaseLocked)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text('Clue time is over.', textAlign: TextAlign.center),
              ),
            const SizedBox(height: 16),
            Text('Your clue', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            TextField(
              controller: _clueController,
              decoration: const InputDecoration(
                hintText: 'Type your one-word clue...',
              ),
              minLines: 2,
              maxLines: 4,
              enabled: !game.cluePhaseLocked,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ChunkyButton(
                    onPressed: (game.cluePhaseLocked || myClueSubmitted)
                        ? null
                        : () {
                            controller.submitMyClue(_clueController.text);
                            _clueController.clear();
                          },
                    label: 'SUBMIT CLUE',
                    background: StitchColors.primary,
                    foreground: StitchColors.onPrimary,
                    shadow: const Color(0xFF66002C),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Submitted clues',
              style: Theme.of(context).textTheme.titleSmall,
            ),
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
                    subtitle: Text(clue ?? '— waiting —'),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            if (game.hostId == game.myPlayerId) ChunkyButton(
              onPressed: game.cluePhaseLocked
                  ? () {
                      controller.beginDiscussionPhase();
                      context.go('/discussion');
                    }
                  : null,
              label: 'CONTINUE TO DISCUSSION',
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
