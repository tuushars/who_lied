import 'dart:async';
import 'dart:math';

import 'package:context_holder/context_holder.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'game_state.dart';
import 'topics.dart';

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

  String _newId() => FirebaseAuth.instance.currentUser?.uid ?? "unauthenticated";

  String createRandomRoomCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // avoid confusing chars
    return List.generate(6, (_) => chars[_rand.nextInt(chars.length)]).join();
  }

  void resetToHome() {
    _clueTimer?.cancel();
    _discussionTimer?.cancel();
    _clueTimer = null;
    _discussionTimer = null;
    state = WhoLiedGameState.initial();
  }

  Future<void> createRoom({required String myName}) async{
    print("Hello from createRoom");
    try {
      print("Hello from createRoom 2");
      _clueTimer?.cancel();
      print("Hello from createRoom 3");
      _discussionTimer?.cancel();
      _clueTimer = null;
      _discussionTimer = null;

      final meId = _newId();
      final code = createRandomRoomCode();
      print("Hello from createRoom 4");
      state = state.copyWith(
        phase: GamePhase.lobby,
        roomCode: code,
        hostId: meId,
        myPlayerId: meId,
        players: [
          WhoLiedPlayer(id: meId, name: myName.trim().isEmpty ? 'Host' : myName),
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
      print("Hello from createRoom 5");

      final db = FirebaseDatabase.instance;
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        await FirebaseAuth.instance.signInAnonymously();
      }
      final uid = FirebaseAuth.instance.currentUser!.uid;
      print("Hello from createRoom 6");
      await db.ref('rooms/$code').set({
        'hostId': uid,
        'status': 'lobby',
        'round': 1,
      }).timeout(const Duration(seconds: 10), onTimeout: () {
        print("TIMEOUT - check databaseURL");
      }).catchError((e) {
        print("FIREBASE ERROR: $e");
      });
      print("Hello from createRoom 7");
      await db.ref('rooms/$code/players/$uid').set({
        'name': myName.trim().isEmpty ? 'Host' : myName,
        'score': 0,
      });
      print("Hello from createRoom 9");

      listenToRoom(code);
      print("Hello from createRoom 10");
    } catch (e) {
      print("Error: $e");
    }
  }

  void joinRoom({
    required String roomCode,
    required String myName,
  }) async {  // add async here
    _clueTimer?.cancel();
    _discussionTimer?.cancel();
    _clueTimer = null;
    _discussionTimer = null;

    final meId = _newId();
    state = state.copyWith(
      phase: GamePhase.lobby,
      roomCode: roomCode.trim().toUpperCase(),
      hostId: "",
      myPlayerId: meId,
      players: [
        WhoLiedPlayer(
          id: meId,
          name: myName.trim().isEmpty ? 'Player' : myName,
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

    // ADD THIS BELOW 👇
    final code = roomCode.trim().toUpperCase();
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final db = FirebaseDatabase.instance;

    await db.ref('rooms/$code/players/$uid').set({
      'name': myName.trim().isEmpty ? 'Player' : myName,
      'score': 0,
    });

    await db.ref('rooms/$code/players/$uid').onDisconnect().remove();
    listenToRoom(code);
  }

  void setCategory(String category) {
    if (state.hostId != state.myPlayerId) return;
    state = state.copyWith(selectedCategory: category);
  }

  Future<void> startRound() async{
    if (state.hostId != state.myPlayerId) return;
    if (state.players.length < 2) {
      return;
    }

    _clueTimer?.cancel();
    _discussionTimer?.cancel();
    _clueTimer = null;
    _discussionTimer = null;

    final imposter = state.players[_rand.nextInt(state.players.length)];
    final categoryTopics = topicPacks[state.selectedCategory] ?? topicPacks['General']!;
    final topic = categoryTopics[_rand.nextInt(categoryTopics.length)];

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

    final code = state.roomCode!;
    final db = FirebaseDatabase.instance;
    await db.ref('rooms/$code').update({
      'status': 'reveal',
      'topic': topic,
      'imposterId': imposter.id,
    });
  }

  Future<void> beginCluePhase() async{
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

    final code = state.roomCode!;
    final db = FirebaseDatabase.instance;
    await db.ref('rooms/$code').update({
      'status': 'clues',
    });
  }

  Future<void> submitMyClue(String clue) async{
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

    final code = state.roomCode!;
    await FirebaseDatabase.instance
        .ref('rooms/$code/clues/$meId')
        .set(trimmed);
  }

  void listenToRoom(String code) {
    FirebaseDatabase.instance.ref('rooms/$code/players').onValue.listen((event) {
      final data = Map<String, dynamic>.from(event.snapshot.value as Map? ?? {});
      final updatedPlayers = data.entries.map((e) {
        final p = Map<String, dynamic>.from(e.value);
        return WhoLiedPlayer(id: e.key, name: p['name'] ?? '');
      }).toList();
      state = state.copyWith(players: updatedPlayers);
    });

    FirebaseDatabase.instance.ref('rooms/$code').onValue.listen((event) {
      final data = Map<String, dynamic>.from(event.snapshot.value as Map? ?? {});
      final status = data['status'];
      final topic = data['topic'];
      final imposterId = data['imposterId'];

      // sync hostId
      state = state.copyWith(hostId: data['hostId'].toString());

      // sync clues always
      final cluesRaw = data['clues'];
      if (cluesRaw != null) {
        final clues = Map<String, String>.from(
            (cluesRaw as Map).map((k, v) => MapEntry(k.toString(), v.toString()))
        );
        state = state.copyWith(cluesByPlayerId: clues);
      }

      final isHost = state.hostId == state.myPlayerId;

      // only navigate if phase actually changed 👇
      if (status == 'reveal' && state.phase != GamePhase.reveal && !isHost) {
        state = state.copyWith(
          phase: GamePhase.reveal,
          topic: topic,
          imposterPlayerId: imposterId,
        );
        ContextHolder.currentContext.go('/reveal');
      }

      if (status == 'discussion' && state.phase != GamePhase.discussion && !isHost) {
        beginDiscussionPhase(callFirebaseService: false);
        state = state.copyWith(phase: GamePhase.discussion);
        beginDiscussionPhase();
        ContextHolder.currentContext.go('/discussion');
      }

      if (status == 'voting' && state.phase != GamePhase.voting && !isHost) {
        state = state.copyWith(phase: GamePhase.voting);
        ContextHolder.currentContext.go('/voting');
      }

      final votesRaw = data['votes'];
      if (votesRaw != null) {
        final votes = Map<String, String>.from(
            (votesRaw as Map).map((k, v) => MapEntry(k.toString(), v.toString()))
        );
        state = state.copyWith(votesByVoterId: votes);
      }

      if (status == 'scoreboard' && state.phase != GamePhase.scoreboard && !isHost) {
        final scoresRaw = data['scores'];
        final scores = scoresRaw != null
            ? Map<String, int>.from(
            (scoresRaw as Map).map((k, v) => MapEntry(k.toString(), (v as num).toInt()))
        )
            : <String, int>{};
        state = state.copyWith(
          phase: GamePhase.scoreboard,
          majorityVotedPlayerId: data['majorityVotedPlayerId'],
          scoresByPlayerId: scores,
        );
        ContextHolder.currentContext.go('/scoreboard');
      }
    });
  }

  Future<void> beginDiscussionPhase({bool callFirebaseService = true}) async{
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

    if (callFirebaseService) {
      final code = state.roomCode!;
      await FirebaseDatabase.instance
          .ref('rooms/$code')
          .update({'status': 'discussion'});
    }
  }

  Future<void> beginVotingPhase() async{
    if (state.phase != GamePhase.discussion) return;

    _discussionTimer?.cancel();
    _discussionTimer = null;

    state = state.copyWith(
      phase: GamePhase.voting,
      votesByVoterId: const {},
      majorityVotedPlayerId: null,
      scoresByPlayerId: const {},
    );

    final code = state.roomCode!;
    await FirebaseDatabase.instance
        .ref('rooms/$code')
        .update({'status': 'voting'});
  }

  Future<void> submitMyVote(String votedPlayerId) async{
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

    final code = state.roomCode!;
    await FirebaseDatabase.instance
        .ref('rooms/$code/votes/$meId')
        .set(votedPlayerId);
  }

  Future<void> revealAndScore() async{
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

    final code = state.roomCode!;
    await FirebaseDatabase.instance.ref('rooms/$code').update({
      'status': 'scoreboard',
      'majorityVotedPlayerId': majorityVotedPlayerId,
      'scores': scores,
    });
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

