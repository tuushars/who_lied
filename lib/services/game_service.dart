import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GameService {
  final _db = FirebaseDatabase.instance;
  final _uid = FirebaseAuth.instance.currentUser!.uid;

  Future<String> createRoom(String category) async {
    final code = _generateCode();
    await _db.ref('rooms/$code').set({
      'hostId': _uid,
      'status': 'lobby',
      'category': category,
      'round': 1,
    });
    await _db.ref('rooms/$code/players/$_uid').set({'name': 'Host', 'score': 0});
    return code;
  }

  Future<void> joinRoom(String code, String name) async {
    await _db.ref('rooms/$code/players/$_uid').set({'name': name, 'score': 0});
    await _db.ref('rooms/$code/players/$_uid').onDisconnect().remove();
  }

  Stream<Map> watchRoom(String code) {
    return _db.ref('rooms/$code').onValue.map((e) =>
    Map<String, dynamic>.from(e.snapshot.value as Map));
  }

  Future<void> advanceStatus(String code, String status) async {
    await _db.ref('rooms/$code/status').set(status);
  }

  Future<void> submitVote(String code, String targetId) async {
    await _db.ref('rooms/$code/players/$_uid/votedFor').set(targetId);
  }

  String _generateCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(6, (_) => chars[DateTime.now().microsecondsSinceEpoch % chars.length]).join();
  }
}