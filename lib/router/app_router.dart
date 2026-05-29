import 'package:context_holder/context_holder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../screens/clues/clues_screen.dart';
import '../screens/discussion/discussion_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/lobby/lobby_screen.dart';
import '../screens/reveal/reveal_screen.dart';
import '../screens/scoreboard/scoreboard_screen.dart';
import '../screens/voting/voting_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  // NOTE: Screens read/write state via Riverpod; the router itself is static.
  return GoRouter(
    navigatorKey: ContextHolder.key,
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/lobby',
        builder: (context, state) => const LobbyScreen(),
      ),
      GoRoute(
        path: '/reveal',
        builder: (context, state) => const RevealScreen(),
      ),
      GoRoute(
        path: '/clues',
        builder: (context, state) => const CluesScreen(),
      ),
      GoRoute(
        path: '/discussion',
        builder: (context, state) => const DiscussionScreen(),
      ),
      GoRoute(
        path: '/voting',
        builder: (context, state) => const VotingScreen(),
      ),
      GoRoute(
        path: '/scoreboard',
        builder: (context, state) => const ScoreboardScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('WhoLied')),
      body: const Center(child: Text('Route not found')),
    ),
  );
});

