class AppConstants {
  // Firebase Configuration
  static const String firebaseDatabaseUrl =
      'https://tuushars-who-lied-default-rtdb.asia-southeast1.firebasedatabase.app/';

  // Game Logic Constants
  static const int roomCodeLength = 6;
  static const int maxPlayers = 8;
  static const int minPlayersToStart = 2;

  // Timers (in seconds)
  static const int revealPhaseDuration = 5;
  static const int cluePhaseDuration = 60;
  static const int discussionPhaseDuration = 90;

  // Topic Categories
  static const String defaultCategory = 'General';
}
