# 碁縁（GoEn） - Premium Go Learning App

> ルールを知らなくても3分で最初の一局へ。大人が上質な世界観でハマる囲碁アプリ

**GoEn** is a premium mobile app designed to introduce the ancient game of Go to adults in a beautiful, beginner-friendly way. With stunning UI inspired by Japanese washi paper, AI-powered gameplay, and learning features, GoEn transforms Go from a "difficult hobby for the elderly" into an "elegant thinking experience for modern adults."

---

## 📋 Project Overview

### Vision
囲碁を「難しい年配の趣味」から「大人が日常で楽しむ上質な思考体験」へ

Transform Go from a niche hobby into a premium daily thinking experience for adults.

### Core Features (Must-Have)

1. **Rule-0 Onboarding** - Start playing immediately without learning complex rules
   - First move captures a stone automatically
   - Intuitive 3-tap path to first game

2. **AI Gameplay** - Play against lightweight GNU Go engine
   - Adjustable difficulty (1-10 levels)
   - Fast responses via Cloud Functions
   - Supports 9x9, 13x13, 19x19 boards

3. **AI-Explained Game Observation** - Watch and learn from games
   - Copyright-free historical games (Honinbo Shusaku era games, etc.)
   - User's own game records
   - Move-by-move AI commentary

4. **Daily Tsume-Go Puzzles** - Interactive puzzle training
   - 1 problem per day
   - Difficulty levels 1-5
   - Solution explanations
   - Streak tracking

5. **Premium UI** - Adults-focused design
   - Japanese washi paper aesthetic
   - Dark mode only (refined experience)
   - Haptic feedback on moves
   - Sound effects (toggleable)
   - NO timers (intentional - no stress)

---

## 🛠️ Tech Stack

### Frontend
- **Flutter/Dart 3.x** - Cross-platform (iOS/Android/Tablet)
- **Riverpod** - State management
- **Lottie** - Animations
- **petit_core/petit_ui/petit_ai** - Shared component libraries

### Backend
- **Firebase Firestore** - Real-time database
- **Firebase Auth** - Authentication
- **Firebase Cloud Functions** - Go engine API
- **Firebase Analytics** - Event tracking
- **Firebase Crashlytics** - Error monitoring
- **Firebase Remote Config** - Feature flags & A/B testing

### Monetization
- **RevenueCat** - Subscription management
- **In-App Purchase** - Premium access

### Go Engine
- **GNU Go 3.8.8** (or similar) - Lightweight, copyright-free
- Hosted on Cloud Functions with 15s timeout, 2-retry policy

---

## 📱 Architecture

### Directory Structure
```
lib/
├── main.dart                # App entry point
├── config/                  # Configuration (theme, constants)
├── models/                  # Data models
│   ├── user.dart
│   ├── game_record.dart
│   ├── ai_opponent_config.dart
│   ├── tsume_go_problem.dart
│   ├── user_tsume_go_log.dart
│   ├── kifu_library.dart
│   ├── observation_log.dart
│   └── index.dart           # Barrel export
├── services/                # Business logic / API layer
│   ├── go_engine_service.dart
│   ├── firestore_service.dart
│   ├── auth_service.dart
│   └── ai_explanation_service.dart
├── viewmodels/              # Riverpod providers
│   ├── auth_provider.dart
│   ├── game_provider.dart
│   ├── tsume_go_provider.dart
│   └── analytics_provider.dart
├── views/                   # UI Screens
│   ├── screens/
│   │   ├── splash_screen.dart
│   │   ├── onboarding_screen.dart
│   │   ├── home_screen.dart
│   │   ├── ai_game_screen.dart
│   │   ├── tsume_go_screen.dart
│   │   ├── kifu_observation_screen.dart
│   │   ├── game_history_screen.dart
│   │   ├── settings_screen.dart
│   │   └── paywall_screen.dart
│   └── widgets/             # Reusable UI components
│       ├── go_board_widget.dart
│       ├── move_indicator.dart
│       └── stone_animation.dart
├── widgets/                 # App-specific widgets
└── utils/                   # Utilities (logging, helpers)

assets/
├── images/                  # UI images
├── animations/              # Lottie files
├── sounds/                  # Sound effects & BGM
└── fonts/                   # Custom fonts
```

### MVVM Architecture
- **Models** - Pure data classes (Firestore mappable)
- **Services** - Business logic, API calls, external integrations
- **ViewModels** - Riverpod providers, state management, reducers
- **Views** - UI, widgets, navigation

---

## 🎮 Aha Moment Design

**Critical Path (3 taps to first game):**
```
Splash Screen → Onboarding (3 cards) → Home → AI Game → [Capture Stone] ✨
```

- Captures stone on first move
- First success triggers dopamine hit
- Leads to retention & tutorial completion

**Target Metrics:**
- Tutorial completion: 70%+
- Aha moment reached: 60%+
- Day1 retention: 25%+
- Day7 retention: 20%+
- Day30 retention: 10%+
- Premium conversion: 5%+

---

## 💰 Monetization Strategy

**Free Tier:**
- AI play (all difficulty levels)
- Daily tsume-go (1 puzzle/day)
- Copyright-free game observation (basic)

**Premium Tier** (Paywall at 3rd game):
- Unlimited tsume-go puzzles
- Detailed AI commentary for observations
- Rank certification (Dan/Kyu system)
- Ad-free experience

---

## 🔐 Security & Privacy

- API keys in environment variables
- HTTPS for all network calls
- Cloud Functions behind authentication
- No personal data collection beyond Firebase Auth
- Compliance: Standard level (not Kids Category)

---

## 📊 Analytics & Monitoring

**Key Events Tracked:**
1. `aha_moment_reached` - First stone captured
2. `ai_game_completed` - Game finished
3. `tsumego_solved` - Puzzle solved
4. `kifu_watched` - Game observation completed
5. `paywall_converted` - Premium purchase

**Monitoring:**
- Firebase Crashlytics for errors
- Remote Config for feature flags
- Analytics for funnel tracking (Acquisition → Aha → Retention → Revenue)

---

## 🚀 Implementation Roadmap

### Phase 1: Foundation (Current)
- [x] Project structure
- [x] Data models
- [ ] Services layer
- [ ] Riverpod state management
- [ ] Core screens (Splash, Onboarding, Home)

### Phase 2: Core Gameplay
- [ ] Go board widget & stone logic
- [ ] AI game flow
- [ ] End-game detection & scoring (Chinese rules)
- [ ] Game result UI

### Phase 3: Learning Features
- [ ] Tsume-go problem rendering
- [ ] Solution verification
- [ ] Explanation UI
- [ ] Kifu observation player

### Phase 4: Monetization & Polish
- [ ] Paywall screen
- [ ] Premium features logic
- [ ] RevenueCat integration
- [ ] Animations & sound

### Phase 5: Testing & Release
- [ ] Unit tests (coverage 50%+)
- [ ] Widget tests
- [ ] Integration tests
- [ ] CI/CD pipeline (GitHub Actions)
- [ ] TestFlight soft launch
- [ ] App Store preparation

---

## ⚠️ Known Risks & Mitigation

| Risk | Impact | Mitigation |
|------|--------|-----------|
| Go engine cost overruns | Budget | GNU Go lightweight engine + Cloud Functions cost limits |
| Pro game copyright issues | Legal | Use only copyright-free historical games + user games |
| Weak retention after Aha | Business | Tsume-go streaks + retention notifications via Remote Config |
| Beginner confuses rules | UX | Extensive onboarding validation + tutorial completion gates |

---

## 📚 References

- **Design Spec**: See `PROJECT_SPEC.md` for detailed requirements
- **API Docs**: `docs/api_spec.md`
- **Test Strategy**: `docs/test_strategy.md`
- **Data Models**: `docs/data_models.md`

---

## 🔄 Development Workflow

1. Create feature branch: `git checkout -b feature/your-feature`
2. Follow Dart/Flutter conventions (dart format, dart analyze)
3. Write tests for business logic (50%+ coverage)
4. Push & create PR with detailed description
5. Ensure CI/CD passes (tests, lints, coverage)
6. Merge to main after review

---

## 📞 Support

For questions about the spec or architecture, refer to the design document or contact the project lead.

---

**Made with ❤️ for Go (碁) enthusiasts worldwide**

v1.1 | Updated: 2026-09-01 | Platform: Flutter/Dart 3.x
