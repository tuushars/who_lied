import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'game_state.dart';

class WhoLiedGameController extends StateNotifier<WhoLiedGameState> {
  WhoLiedGameController() : super(WhoLiedGameState.initial());

  Timer? _clueTimer;
  Timer? _discussionTimer;
  final _rand = Random();

  @override
  void dispose() {
    _clueTimer?.cancel();
    _discussionTimer?.cancel();
    super.dispose();
  }

  String _newId() => _rand.nextInt(1 << 32).toString();

  String createRandomRoomCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // avoid confusing chars
    return List.generate(6, (_) => chars[_rand.nextInt(chars.length)]).join();
  }

  static const _topics = <String>[
    'Cats',
    'Space',
    'Pizza toppings',
    'Movie genres',
    'Programming languages',
    'Famous landmarks',
    'Superpowers',
  ];

  void resetToHome() {
    _clueTimer?.cancel();
    _discussionTimer?.cancel();
    _clueTimer = null;
    _discussionTimer = null;
    state = WhoLiedGameState.initial();
  }

  void createRoom({required String myName}) {
    _clueTimer?.cancel();
    _discussionTimer?.cancel();
    _clueTimer = null;
    _discussionTimer = null;

    final meId = _newId();
    final code = createRandomRoomCode();
    state = state.copyWith(
      phase: GamePhase.lobby,
      roomCode: code,
      isHost: true,
      myPlayerId: meId,
      players: [
        WhoLiedPlayer(id: meId, name: myName.trim().isEmpty ? 'Host' : myName, isBot: false),
      ],
      topic: null,
      imposterPlayerId: null,
      cluesByPlayerId: const {},
      votesByVoterId: const {},
      clueSecondsRemaining: 0,
      cluePhaseLocked: false,
      discussionSecondsRemaining: 0,
      discussionPhaseLocked: false,
      majorityVotedPlayerId: null,
      scoresByPlayerId: const {},
    );
  }

  void joinRoom({
    required String roomCode,
    required String myName,
  }) {
    _clueTimer?.cancel();
    _discussionTimer?.cancel();
    _clueTimer = null;
    _discussionTimer = null;

    final meId = _newId();
    state = state.copyWith(
      phase: GamePhase.lobby,
      roomCode: roomCode.trim().toUpperCase(),
      isHost: false,
      myPlayerId: meId,
      players: [
        WhoLiedPlayer(
          id: meId,
          name: myName.trim().isEmpty ? 'Player' : myName,
          isBot: false,
        ),
      ],
      topic: null,
      imposterPlayerId: null,
      cluesByPlayerId: const {},
      votesByVoterId: const {},
      clueSecondsRemaining: 0,
      cluePhaseLocked: false,
      discussionSecondsRemaining: 0,
      discussionPhaseLocked: false,
      majorityVotedPlayerId: null,
      scoresByPlayerId: const {},
    );
  }

  void addBotPlayer() {
    if (state.players.length >= 8) return;
    final meId = state.myPlayerId;
    if (meId == null) return;

    final botNumber = state.players.where((p) => p.isBot).length + 1;
    final id = _newId();
    final name = 'Bot $botNumber';

    state = state.copyWith(
      players: [
        ...state.players,
        WhoLiedPlayer(id: id, name: name, isBot: true),
      ],
    );
  }

  void startRound() {
    if (!state.isHost) return;
    if (state.players.length < 2) return;

    _clueTimer?.cancel();
    _discussionTimer?.cancel();
    _clueTimer = null;
    _discussionTimer = null;

    final imposter = state.players[_rand.nextInt(state.players.length)];
    final topic = _topics[_rand.nextInt(_topics.length)];

    state = state.copyWith(
      phase: GamePhase.reveal,
      topic: topic,
      imposterPlayerId: imposter.id,
      cluesByPlayerId: const {},
      votesByVoterId: const {},
      clueSecondsRemaining: 0,
      cluePhaseLocked: false,
      discussionSecondsRemaining: 0,
      discussionPhaseLocked: false,
      majorityVotedPlayerId: null,
      scoresByPlayerId: const {},
    );
  }

  void beginCluePhase() {
    if (state.phase != GamePhase.reveal && state.phase != GamePhase.lobby) return;

    _clueTimer?.cancel();
    _discussionTimer?.cancel();
    _clueTimer = null;
    _discussionTimer = null;

    state = state.copyWith(
      phase: GamePhase.clues,
      cluesByPlayerId: const {},
      votesByVoterId: state.votesByVoterId, // keep empty until voting phase
      clueSecondsRemaining: 60,
      cluePhaseLocked: false,
    );

    _clueTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final remaining = state.clueSecondsRemaining;
      if (remaining <= 1) {
        _clueTimer?.cancel();
        _clueTimer = null;
        state = state.copyWith(clueSecondsRemaining: 0, cluePhaseLocked: true);
      } else {
        state = state.copyWith(clueSecondsRemaining: remaining - 1);
      }
    });
  }

  void submitMyClue(String clue) {
    if (state.phase != GamePhase.clues) return;
    if (state.cluePhaseLocked) return;
    final meId = state.myPlayerId;
    if (meId == null) return;

    final trimmed = clue.trim();
    if (trimmed.isEmpty) return;

    state = state.copyWith(
      cluesByPlayerId: {
        ...state.cluesByPlayerId,
        meId: trimmed,
      },
    );
  }

  void botSubmitOneClue() {
    if (state.phase != GamePhase.clues) return;
    if (state.cluePhaseLocked) return;

    final topic = state.topic;
    if (topic == null) return;

    final imposterId = state.imposterPlayerId;
    if (imposterId == null) return;

    final missing = state.players.where((p) => !state.cluesByPlayerId.containsKey(p.id)).toList();
    if (missing.isEmpty) return;

    final target = missing[_rand.nextInt(missing.length)];

    final clue = target.id == imposterId ? '??? (off-topic)'.replaceAll('???', topic) : 'Connects to $topic';
    state = state.copyWith(
      cluesByPlayerId: {
        ...state.cluesByPlayerId,
        target.id: clue,
      },
    );
  }

  void beginDiscussionPhase() {
    if (state.phase != GamePhase.clues) return;

    _clueTimer?.cancel();
    _clueTimer = null;

    state = state.copyWith(
      phase: GamePhase.discussion,
      discussionSecondsRemaining: 90,
      discussionPhaseLocked: false,
    );

    _discussionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final remaining = state.discussionSecondsRemaining;
      if (remaining <= 1) {
        _discussionTimer?.cancel();
        _discussionTimer = null;
        state = state.copyWith(
          discussionSecondsRemaining: 0,
          discussionPhaseLocked: true,
        );
      } else {
        state = state.copyWith(discussionSecondsRemaining: remaining - 1);
      }
    });
  }

  void beginVotingPhase() {
    if (state.phase != GamePhase.discussion) return;

    _discussionTimer?.cancel();
    _discussionTimer = null;

    state = state.copyWith(
      phase: GamePhase.voting,
      votesByVoterId: const {},
      majorityVotedPlayerId: null,
      scoresByPlayerId: const {},
    );
  }

  void submitMyVote(String votedPlayerId) {
    if (state.phase != GamePhase.voting) return;
    final meId = state.myPlayerId;
    if (meId == null) return;

    // One vote per player (no multi-vote in this scaffold).
    if (state.votesByVoterId.containsKey(meId)) return;

    state = state.copyWith(
      votesByVoterId: {
        ...state.votesByVoterId,
        meId: votedPlayerId,
      },
    );
  }

  void botCastOneVote() {
    if (state.phase != GamePhase.voting) return;

    final meId = state.myPlayerId;
    if (meId == null) return;

    final voters = state.players.map((p) => p.id).toList();
    final missingVoters = voters.where((id) => !state.votesByVoterId.containsKey(id)).toList();
    if (missingVoters.isEmpty) return;

    // Pick a bot voter if available; otherwise the same device "player".
    final botMissing = state.players.where((p) => p.isBot && missingVoters.contains(p.id)).toList();
    final voter = (botMissing.isNotEmpty ? botMissing : state.players.where((p) => missingVoters.contains(p.id)).toList());
    if (voter.isEmpty) return;
    final chosenVoter = voter[_rand.nextInt(voter.length)];

    final candidates = state.players.map((p) => p.id).where((id) => id != chosenVoter.id).toList();
    if (candidates.isEmpty) return;
    final votedId = candidates[_rand.nextInt(candidates.length)];

    state = state.copyWith(
      votesByVoterId: {
        ...state.votesByVoterId,
        chosenVoter.id: votedId,
      },
    );
  }

  void revealAndScore() {
    if (state.phase != GamePhase.voting) return;

    final votes = state.votesByVoterId.values.toList();
    if (votes.isEmpty) return;

    final counts = <String, int>{};
    for (final voted in votes) {
      counts[voted] = (counts[voted] ?? 0) + 1;
    }

    final maxVotes = counts.values.reduce(max);
    final majorityCandidates = counts.entries
        .where((e) => e.value == maxVotes)
        .map((e) => e.key)
        .toList();

    final majorityVotedPlayerId = majorityCandidates[_rand.nextInt(majorityCandidates.length)];
    final imposterId = state.imposterPlayerId;

    final isMajorityCorrect = imposterId != null && imposterId == majorityVotedPlayerId;

    // Simple scoring for scaffold:
    // - If majority correctly votes the imposter: non-imposters get +1
    // - Otherwise: imposter gets +1
    final scores = <String, int>{};
    for (final p in state.players) {
      final isImposter = imposterId != null && p.id == imposterId;
      if (isMajorityCorrect) {
        scores[p.id] = isImposter ? 0 : 1;
      } else {
        scores[p.id] = isImposter ? 1 : 0;
      }
    }

    state = state.copyWith(
      phase: GamePhase.scoreboard,
      majorityVotedPlayerId: majorityVotedPlayerId,
      scoresByPlayerId: scores,
    );
  }

  void playAgainToLobby() {
    // Keep room + players, but clear round-specific data.
    _clueTimer?.cancel();
    _discussionTimer?.cancel();
    _clueTimer = null;
    _discussionTimer = null;

    state = state.copyWith(
      phase: GamePhase.lobby,
      topic: null,
      imposterPlayerId: null,
      cluesByPlayerId: const {},
      votesByVoterId: const {},
      clueSecondsRemaining: 0,
      cluePhaseLocked: false,
      discussionSecondsRemaining: 0,
      discussionPhaseLocked: false,
      majorityVotedPlayerId: null,
      scoresByPlayerId: const {},
    );
  }
}

final gameControllerProvider =
    StateNotifierProvider<WhoLiedGameController, WhoLiedGameState>(
  (ref) => WhoLiedGameController(),
);

