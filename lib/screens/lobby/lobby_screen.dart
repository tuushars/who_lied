import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../state/game_controller.dart';
import '../../ui/stitch_scaffold.dart';
import '../../ui/stitch_theme.dart';

class LobbyScreen extends ConsumerWidget {
  const LobbyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameControllerProvider);
    final controller = ref.read(gameControllerProvider.notifier);

    final roomCode = game.roomCode ?? '---';
    final myId = game.myPlayerId;

    return StitchScaffold(
      title: 'The Lobby',
      actions: [
        IconButton(
          tooltip: 'Back to Home',
          onPressed: () {
            controller.resetToHome();
            context.go('/');
          },
          icon: const Icon(Icons.home_outlined),
        ),
      ],
      bottomItem: StitchNavItem.clue,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'ROOM CODE',
                      style: TextStyle(
                        letterSpacing: 2,
                        color: StitchColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      roomCode,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: StitchColors.primary,
                            letterSpacing: 6,
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Players',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: StitchColors.secondary,
              ),
            ),
            Text(
              '${game.players.length}/8 JOINED',
              style: const TextStyle(
                color: StitchColors.tertiary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                itemCount: game.players.length,
                separatorBuilder: (_, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final p = game.players[index];
                  final isMe = p.id == myId;
                  return Container(
                    decoration: BoxDecoration(
                      color: StitchColors.surfaceContainerHigh,
                      border: Border.all(color: StitchColors.outline, width: 2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: StitchColors.surface,
                        child: Text(
                          p.name.isEmpty ? '?' : p.name[0].toUpperCase(),
                        ),
                      ),
                      title: Text(p.name),
                      subtitle: Text(
                        [if (p.isBot) 'Bot', if (isMe) 'You'].join(' · '),
                      ),
                      trailing: isMe && game.isHost
                          ? const Icon(
                              Icons.verified,
                              color: StitchColors.tertiary,
                            )
                          : null,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            if (!game.isHost)
              const Text(
                'Waiting for the host to start…',
                textAlign: TextAlign.center,
              ),
            Row(
              children: [
                Expanded(
                  child: ChunkyButton(
                    onPressed: game.players.length >= 8
                        ? null
                        : controller.addBotPlayer,
                    label: 'ADD BOT PLAYER',
                    icon: Icons.add,
                    background: StitchColors.surfaceContainer,
                    foreground: StitchColors.onSurface,
                    shadow: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ChunkyButton(
              onPressed: (!game.isHost || game.players.length < 2)
                  ? null
                  : () {
                      controller.startRound();
                      context.go('/reveal');
                    },
              label: 'START GAME',
              background: StitchColors.tertiary,
              foreground: StitchColors.onTertiary,
              shadow: const Color(0xFF095300),
            ),
          ],
        ),
      ),
    );
  }
}
