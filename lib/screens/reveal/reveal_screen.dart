import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../state/game_controller.dart';
import '../../ui/stitch_scaffold.dart';
import '../../ui/stitch_theme.dart';

class RevealScreen extends ConsumerWidget {
  const RevealScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameControllerProvider);
    final controller = ref.read(gameControllerProvider.notifier);

    final imposterId = game.imposterPlayerId;
    final myId = game.myPlayerId;
    final isImposter = myId != null && imposterId != null && myId == imposterId;

    final topic = game.topic;

    return StitchScaffold(
      title: 'WhoLied?',
      bottomItem: StitchNavItem.reveal,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Your Role',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: StitchColors.primary),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Icon(
                          isImposter ? Icons.lock : Icons.key,
                          size: 44,
                          color: isImposter
                              ? StitchColors.secondary
                              : StitchColors.tertiary,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          isImposter ? 'CONFIDENTIAL' : 'THE TOPIC IS...',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            letterSpacing: 2,
                            color: StitchColors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          topic == null
                              ? 'TOPIC NOT SET'
                              : (isImposter ? '???' : topic.toUpperCase()),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                color: isImposter
                                    ? StitchColors.secondary
                                    : StitchColors.tertiary,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isImposter
                      ? 'Your job: bluff with a clue that sounds connected, but not too directly.'
                      : 'Your job: submit a real clue connected to the topic.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ChunkyButton(
                  onPressed: topic == null
                      ? null
                      : () {
                          controller.beginCluePhase();
                          context.go('/clues');
                        },
                  label: 'CONTINUE TO CLUES',
                  background: StitchColors.primary,
                  foreground: StitchColors.onPrimary,
                  shadow: const Color(0xFF66002C),
                ),
                const SizedBox(height: 8),
                if (game.hostId != myId)
                  const Text(
                    'Tip: Everyone follows the same phase timers (local scaffold).',
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
