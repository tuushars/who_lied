enum GamePhase {
  home,
  lobby,
  reveal,
  clues,
  discussion,
  voting,
  scoreboard,
}

class WhoLiedPlayer {
  final String id;
  final String name;
  final bool isBot;

  const WhoLiedPlayer({
    required this.id,
    required this.name,
    required this.isBot,
  });
}

class WhoLiedGameState {
  final GamePhase phase;

  final String? roomCode;
  final bool isHost;
  final String? myPlayerId;
  final List<WhoLiedPlayer> players;

  // Round data
  final String? topic;
  final String? imposterPlayerId;
  final Map<String, String> cluesByPlayerId; // playerId -> clue
  final Map<String, String> votesByVoterId; // voterId -> votedPlayerId

  // Timers (local UI scaffold only)
  final int clueSecondsRemaining;
  final bool cluePhaseLocked;
  final int discussionSecondsRemaining;
  final bool discussionPhaseLocked;

  // Reveal & scoring
  final String? majorityVotedPlayerId;
  final Map<String, int> scoresByPlayerId;

  const WhoLiedGameState({
    required this.phase,
    required this.roomCode,
    required this.isHost,
    required this.myPlayerId,
    required this.players,
    required this.topic,
    required this.imposterPlayerId,
    required this.cluesByPlayerId,
    required this.votesByVoterId,
    required this.clueSecondsRemaining,
    required this.cluePhaseLocked,
    required this.discussionSecondsRemaining,
    required this.discussionPhaseLocked,
    required this.majorityVotedPlayerId,
    required this.scoresByPlayerId,
  });

  factory WhoLiedGameState.initial() {
    return WhoLiedGameState(
      phase: GamePhase.home,
      roomCode: null,
      isHost: false,
      myPlayerId: null,
      players: const [],
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

  WhoLiedGameState copyWith({
    GamePhase? phase,
    String? roomCode,
    bool? isHost,
    String? myPlayerId,
    List<WhoLiedPlayer>? players,
    String? topic,
    String? imposterPlayerId,
    Map<String, String>? cluesByPlayerId,
    Map<String, String>? votesByVoterId,
    int? clueSecondsRemaining,
    bool? cluePhaseLocked,
    int? discussionSecondsRemaining,
    bool? discussionPhaseLocked,
    String? majorityVotedPlayerId,
    Map<String, int>? scoresByPlayerId,
  }) {
    return WhoLiedGameState(
      phase: phase ?? this.phase,
      roomCode: roomCode ?? this.roomCode,
      isHost: isHost ?? this.isHost,
      myPlayerId: myPlayerId ?? this.myPlayerId,
      players: players ?? this.players,
      topic: topic ?? this.topic,
      imposterPlayerId: imposterPlayerId ?? this.imposterPlayerId,
      cluesByPlayerId: cluesByPlayerId ?? this.cluesByPlayerId,
      votesByVoterId: votesByVoterId ?? this.votesByVoterId,
      clueSecondsRemaining: clueSecondsRemaining ?? this.clueSecondsRemaining,
      cluePhaseLocked: cluePhaseLocked ?? this.cluePhaseLocked,
      discussionSecondsRemaining:
          discussionSecondsRemaining ?? this.discussionSecondsRemaining,
      discussionPhaseLocked:
          discussionPhaseLocked ?? this.discussionPhaseLocked,
      majorityVotedPlayerId:
          majorityVotedPlayerId ?? this.majorityVotedPlayerId,
      scoresByPlayerId: scoresByPlayerId ?? this.scoresByPlayerId,
    );
  }
}

