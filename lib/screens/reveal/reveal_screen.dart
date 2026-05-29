import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../state/game_controller.dart';
import '../../ui/stitch_scaffold.dart';
import '../../ui/stitch_theme.dart';
import '../../utils/app_constants.dart';

class RevealScreen extends ConsumerStatefulWidget {
  const RevealScreen({super.key});

  @override
  ConsumerState<RevealScreen> createState() => _RevealScreenState();
}

class _RevealScreenState extends ConsumerState<RevealScreen> {
  int _secondsRemaining = AppConstants.revealPhaseDuration;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _timer?.cancel();
        _navigateToClues();
      }
    });
  }

  void _navigateToClues() {
    if (mounted) {
      ref.read(gameControllerProvider.notifier).beginCluePhase();
      context.go('/clues');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameControllerProvider);

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
                const SizedBox(height: 32),
                Text(
                  'Moving to Clues in $_secondsRemaining...',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: StitchColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 24),
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
