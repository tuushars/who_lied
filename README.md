# WhoLied? 🕵️

A real-time multiplayer party bluffing game built with Flutter & Firebase — inspired by the viral Imposter/FakeIt game with 109M+ views.

One player is secretly the **imposter** who doesn't know the topic. Everyone gives clues. Everyone votes. Can you spot the liar?

---

## Gameplay

1. **Host creates a room** and shares the 6-character code
2. **Players join** from their own phones
3. **Roles are revealed** — players see the secret topic, imposter sees nothing
4. **Clue phase** — every player gives a one-word clue
5. **Discussion phase** — 90 seconds to talk it out
6. **Voting phase** — everyone votes for who they think the imposter is
7. **Scoreboard** — imposter revealed, points awarded

---

## Features

- 🔴 Real-time multiplayer via Firebase Realtime Database
- 📱 Mobile-first Flutter app (iOS + Android)
- 🏠 Local or internet play — just share the room code
- 👥 4–8 players per room
- ⏱️ Timer-based clue and discussion phases
- 🗳️ Live vote tracking
- 🏆 Score tracking across rounds
- 🎭 Topic category packs (General, Family, Adult)
- 🔌 Auto-disconnect cleanup with Firebase presence

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3.x (Dart) |
| State Management | Riverpod |
| Navigation | go_router |
| Backend | Firebase Realtime Database |
| Auth | Firebase Anonymous Auth |
| UI | Custom design system (StitchTheme) |

---

## Project Structure

```
lib/
├── main.dart                  # App entry, Firebase init, anonymous auth
├── state/
│   ├── game_controller.dart   # All game logic + Firebase writes
│   └── game_state.dart        # Immutable state model
├── screens/
│   ├── home/
│   ├── room/
│   │   ├── create_room_screen.dart
│   │   ├── join_room_screen.dart
│   │   └── lobby_screen.dart
│   ├── game/
│   │   ├── reveal_screen.dart
│   │   ├── clues_screen.dart
│   │   ├── discussion_screen.dart
│   │   └── voting_screen.dart
│   └── scoreboard/
│       └── scoreboard_screen.dart
├── ui/
│   ├── stitch_theme.dart      # Colors, typography
│   └── stitch_scaffold.dart   # Shared scaffold
└── data/
    └── topic_packs.dart       # Topic categories
```

---

## Firebase Schema

```
rooms/{roomCode}/
  ├── hostId: string
  ├── status: "lobby" | "reveal" | "clues" | "discussion" | "voting" | "scoreboard"
  ├── topic: string
  ├── imposterId: string
  ├── round: number
  ├── majorityVotedPlayerId: string
  ├── players/{uid}/
  │     ├── name: string
  │     └── score: number
  ├── clues/{uid}: string
  ├── votes/{uid}: string
  └── scores/{uid}: number
```

---

## Getting Started

### Prerequisites
- Flutter 3.x
- Firebase project with Realtime Database enabled
- Anonymous Auth enabled in Firebase Console

### Setup

1. Clone the repo
```bash
git clone https://github.com/tuushars/who_lied.git
cd who_lied
```

2. Install dependencies
```bash
flutter pub get
```

3. Add your Firebase config files
    - `android/app/google-services.json`
    - `ios/Runner/GoogleService-Info.plist`

4. Set your Firebase Realtime Database URL in `main.dart`
```dart
FirebaseDatabase.instance.databaseURL = 'https://your-project-id-default-rtdb.firebaseio.com/';
```

5. Set Firebase rules in your console
```json
{
  "rules": {
    "rooms": {
      "$roomCode": {
        ".read": "auth != null",
        ".write": "auth != null"
      }
    }
  }
}
```

6. Run the app
```bash
flutter run
```

---

## Scoring

| Action | Points |
|---|---|
| Voted for the imposter correctly | +1 |
| Imposter survives the vote | +1 |

---

## Roadmap

- [ ] Custom topic creation
- [ ] Voice/video chat integration
- [ ] Spectator mode
- [ ] Animated role reveal
- [ ] Push notifications for game events
- [ ] Web support

---

## Acknowledgements

Inspired by [FakeIt](https://apps.apple.com/app/fakeit) and the viral Imposter party game format.

---

## License

MIT