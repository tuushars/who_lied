import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../state/game_controller.dart';
import '../../ui/stitch_scaffold.dart';
import '../../ui/stitch_theme.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _nameController = TextEditingController(text: 'Player');
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameControllerProvider);
    final gameController = ref.read(gameControllerProvider.notifier);
    return StitchScaffold(
      title: 'WhoLied?',
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const SizedBox(height: 8),
              const Icon(
                Icons.visibility,
                color: StitchColors.primary,
                size: 72,
              ),
              const SizedBox(height: 12),
              Text(
                'Identity Check',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Who are you pretending to be tonight?',
                textAlign: TextAlign.center,
                style: TextStyle(color: StitchColors.onSurfaceVariant),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Enter your alias...',
                  prefixIcon: Icon(
                    Icons.fingerprint,
                    color: StitchColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _codeController,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'Room code',
                  prefixIcon: Icon(
                    Icons.meeting_room,
                    color: StitchColors.secondary,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ChunkyButton(
                label: 'CREATE ROOM',
                onPressed: () {
                  gameController.createRoom(myName: _nameController.text);
                  context.go('/lobby');
                },
                icon: Icons.add_circle,
              ),
              const SizedBox(height: 12),
              ChunkyButton(
                label: 'JOIN ROOM',
                background: StitchColors.secondary,
                foreground: StitchColors.onSecondary,
                shadow: const Color(0xFF4B007E),
                icon: Icons.group,
                onPressed: () {
                  final code = _codeController.text.trim();
                  if (code.isEmpty) return;
                  gameController.joinRoom(
                    roomCode: code,
                    myName: _nameController.text,
                  );
                  context.go('/lobby');
                },
              ),
              const SizedBox(height: 16),
              if (game.roomCode != null)
                Text(
                  'Current room: ${game.roomCode}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: StitchColors.tertiary),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
