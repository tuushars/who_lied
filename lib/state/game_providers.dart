import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/game_service.dart';

final gameServiceProvider = Provider((ref) => GameService());

final gameStreamProvider = StreamProvider.family<Map, String>((ref, code) {
  return ref.read(gameServiceProvider).watchRoom(code);
});