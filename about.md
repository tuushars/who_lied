# BluffRoom — Flutter Party Bluffing Game

## Project Overview
Build "BluffRoom", a real-time multiplayer social party game inspired by
the viral Imposter/FakeIt game (109M+ views). One player is the "imposter"
who doesn't know the secret topic. Everyone else gives clues, then players
vote on who they think the imposter is.

Target: Flutter (iOS + Android). Multiplayer via Firebase Realtime Database
or Firestore. Supports local (same-room) and internet play.

---

## Tech Stack
- Flutter 3.x (Dart)
- Firebase Realtime Database (game state sync)
- Firebase Auth (anonymous sign-in per session)
- Provider or Riverpod for state management
- go_router for navigation
- Google Fonts + custom animations (flutter_animate)

---

## Core Screens to Build

### 1. Home Screen
- App logo + tagline ("One room. One liar.")
- Two buttons: "Create Room" and "Join Room"
- Settings icon (sound toggle, dark mode)

### 2. Create Room Screen
- Host enters their name
- Selects topic category pack:
  [ General ] [ Family ] [ Adult 18+ ]
- Auto-generates a 6-character room code (e.g. "BF4X2Z")
- Shareable code displayed large with a copy button
- Waiting lobby shows players joining in real-time
- Host sees a "Start Game" button (enabled when 4–8 players joined)

### 3. Join Room Screen
- Player enters their name + 6-digit room code
- Validates room exists + not full + not in progress
- Redirects to lobby waiting screen

### 4. Lobby Screen (waiting room)
- Live list of joined players (avatars with initials, color-coded)
- Shows "Waiting for host to start…"
- Player count badge (e.g. 5/8)
- Animated pulse on each player tile when a new player joins

### 5. Role Reveal Screen
- Full-screen card flip animation
- "Players" see: secret topic (e.g. "Pizza") in big text
- "Imposter" sees: "You are the IMPOSTER 🕵️" with no topic shown
- Hold-to-reveal interaction (press and hold to see your role privately)
- 3-second countdown before moving to clue phase

### 6. Clue / Discussion Phase Screen
- Countdown timer (60 seconds default, configurable by host)
- Player list with turn indicators — each player gives one clue verbally
- Text field (optional): players can type their clue for others to see
- "Done" button to mark yourself as having given a clue
- Host can extend timer by 30 seconds

### 7. Voting Screen
- Grid of player avatars
- Tap a player to vote for them as the imposter
- Can change vote before timer ends
- Real-time vote count visible (number only, not who voted for whom)
- Final 5-second lock countdown

### 8. Reveal Screen
- Dramatic animated reveal of the imposter's identity
- Shows: who was the imposter, what the topic was
- Outcome states:
  - "Imposter caught! 🎉" — majority voted correctly
  - "Imposter escaped! 😈" — imposter survives
  - "Imposter guessed the topic!" — imposter gets rescue points
- Confetti animation on win

### 9. Score / Leaderboard Screen
- Points breakdown per player
- Scoring logic:
  - Player votes correctly → +2 pts
  - Imposter survives vote → +3 pts
  - Imposter correctly guesses topic after caught → +1 pt rescue
- "Next Round" and "End Game" buttons (host only)

### 10. End Game Screen
- Final leaderboard with podium (1st, 2nd, 3rd)
- "Play Again" and "Back to Home" buttons

---

## Game State (Firebase Schema)

rooms/{roomCode}/
  ├── hostId: string
  ├── status: "lobby" | "role_reveal" | "clue_phase" | "voting" | "reveal" | "ended"
  ├── category: "general" | "family" | "adult"
  ├── currentTopic: string (hidden from imposter)
  ├── imposterId: string
  ├── round: number
  ├── timerEndsAt: timestamp
  ├── players/{playerId}/
  │     ├── name: string
  │     ├── isImposter: boolean (only visible to self)
  │     ├── clue: string
  │     ├── votedFor: string (playerId)
  │     ├── score: number
  │     └── isReady: boolean
  └── votes/{targetPlayerId}: number (vote count)

---

## Topic Category Packs

### General (default, all ages)
50+ topics. Examples: Pizza, Football, Airport, Hospital, School,
Beach, Wedding, Dentist, Camping, Museum

### Family Pack
Topics safe for kids. Examples: Zoo, Birthday Party, Playground,
Christmas, Supermarket, Swimming Pool

### Adult Pack (18+, toggle-gated)
More abstract/edgy topics. Examples: Blind Date, Hangover, Poker Night,
Conspiracy Theory, Traffic Jam at 3am

Store topics in a local Dart file as a Map>.

---

## UX & Design Rules
- Mobile-first, portrait orientation only
- Dark theme default (deep navy/purple + white text)
- Large tap targets (min 48px)
- Smooth page transitions (slide + fade)
- Sound effects: role reveal sting, voting tick, confetti pop (using audioplayers)
- Haptic feedback on key interactions (HapticFeedback.mediumImpact)
- No login required — anonymous Firebase Auth per session
- Accessibility: minimum contrast 4.5:1, font size min 14sp

---

## Animations to Implement
- Card flip for role reveal (AnimationController + Transform)
- Confetti burst on game end (use confetti package)
- Pulse animation on player tiles in lobby
- Vote bar fill animation on reveal screen
- Timer ring countdown (CustomPainter)

---

## Deliverables (in order)
1. Firebase project setup + Firestore/RTDB rules
2. Folder structure (feature-based: /home, /room, /game, /score)
3. Home screen + navigation shell
4. Room creation + joining flow (Firebase)
5. Role reveal screen with card flip
6. Clue + voting screens with real-time sync
7. Reveal + score screens
8. Topic packs (Dart data file)
9. Animations + sound effects
10. Final polish: error handling, reconnect logic, empty states

---

## Out of Scope (v1)
- Video/voice chat (use in-person or phone calls)
- Custom topic creation (v2)
- Spectator mode (v2)
- Push notifications (v2)
      