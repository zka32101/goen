# Phase 58: SNS Integration & Next-Generation Game Modes

**Status**: In Development 🚀  
**Target Completion**: 2026-09-20  
**Test Coverage**: 50 comprehensive tests across 5 dimensions

## Overview

Phase 58 focuses on expanding GoEn's social capabilities through advanced SNS integration and introducing new gameplay modes that cater to different playing styles and time commitments.

## Dimension 1: Twitter/X Integration & Content Optimization (10 tests)

### Features
- **Twitter/X API v2 Integration**: Direct API integration for posting game results and analysis
- **Tweet Composition**: Automatic tweet generation with:
  - Game results with emojis and scoring
  - Board state visualization (text-based representation)
  - Hashtag optimization (#碁 #Go #碁縁 #AI碁)
  - Mentions of friends and opponents
- **Media Upload**: Upload board images as media attachments
- **Thread Support**: Create tweet threads for detailed game analysis
- **Analytics**: Track tweet engagement (likes, retweets, replies)

### Implementation Files
- `lib/services/sns_api_service.dart` - Twitter API wrapper
- `lib/models/sns_models.dart` - TwitterTweetResponse, TweetMetrics models

### Key Methods
```dart
// Post a game result
await snsApiService.postGameResultTweet(
  text: '碁縁でAIに勝利しました！\n19路盤\nAIレベル: 10',
  mediaIds: ['12345'], // Board image
);

// Get tweet metrics
final metrics = await snsApiService.getTweetMetrics(tweetId: 'tweet123');
print('Likes: ${metrics.likes}, Retweets: ${metrics.retweets}');

// Post analysis thread
final responses = await snsApiService.postGameAnalysisThread(
  gameId: 'game123',
  threadTexts: ['初手の戦略...', '序盤の変化...', '終盤の決着...'],
  mediaIds: ['img1', 'img2', 'img3'],
);
```

### Test Coverage
1. Twitter API authentication and token validation
2. Tweet composition with various game results
3. Media upload and attachment to tweets
4. Thread creation with sequential IDs
5. Rate limiting and error handling
6. Tweet metrics fetching and caching
7. Hashtag optimization and validation
8. Character limit compliance (280 chars)
9. Emoji encoding in tweets
10. Timeline caching and updates

---

## Dimension 2: Multi-Platform SNS & Unified Share Experience (10 tests)

### Features
- **Facebook/Instagram Integration**: Share game achievements and progress
- **WhatsApp Messaging**: Send game invitations and results to contacts
- **LINE Messaging**: Direct messaging with LINE users
- **Unified Content Generation**: Adapt content for each platform
- **Platform-Specific Formatting**: 
  - Twitter: Concise with hashtags
  - Facebook: Longer form with image focus
  - WhatsApp: Personal messages with quick actions
  - LINE: Japanese-optimized with stickers

### Implementation Files
- `lib/services/sns_api_service.dart` - Multi-platform posting
- `lib/models/sns_models.dart` - FacebookPostResponse models
- Enhanced `lib/services/social_share_service.dart`

### Key Methods
```dart
// Facebook sharing
await snsApiService.postToFacebook(
  message: '碁縁でAIに勝利！19路盤でAIレベル10に勝ちました。',
  pageId: 'goen-official',
  imageUrl: 'https://example.com/board.jpg',
);

// WhatsApp sharing (via deep link)
await socialShareService.shareToWhatsApp(
  content: ShareContent(
    text: '碁縁をやってみて！\nhttps://goen.app/download',
    hashtags: '#碁',
  ),
);

// LINE sharing
await socialShareService.shareToLine(
  content: ShareContent(
    text: 'GoEn（碁縁）で碁を上達させよう！\nhttps://goen.app/line',
    hashtags: '#Go学習',
  ),
);
```

### Test Coverage
1. Facebook API authentication and token refresh
2. Instagram Stories vs. Feed posting
3. WhatsApp message formatting and link generation
4. LINE sticker integration
5. Cross-platform content adaptation
6. Error handling for unavailable platforms
7. Deep link generation for app installs
8. Image optimization for each platform
9. Message length adaptation
10. Platform-specific analytics tracking

---

## Dimension 3: New Game Modes & Gameplay Innovation (10 tests)

### Game Modes

#### 3.1 Blitz Mode (5-Minute Rapid)
**Description**: Fast-paced games with 5-minute time control per player

**Features**:
- Real-time timer with visual countdown
- No undo/takeback allowed
- Automatic time forfeit
- Blitz-specific leaderboard
- Session-based rapid matchmaking

**Implementation**:
```dart
final blitzMode = await gameModeService.getBlitzMode();
final session = await gameModeService.startGameSession(
  gameMode: blitzMode,
  blackPlayerId: currentUser.id,
  whitePlayerId: opponent.id,
);
```

#### 3.2 Correspondence Mode (Turn-Based)
**Description**: Mail-like turn-based gameplay with no time pressure

**Features**:
- Unlimited think time per move
- Email notifications for opponent's moves
- Move history with timestamps
- Perfect for busy professionals
- Persistent game state

**Implementation**:
```dart
final correspondenceMode = await gameModeService.getCorrespondenceMode();
final session = await gameModeService.startGameSession(
  gameMode: correspondenceMode,
  blackPlayerId: user1.id,
  whitePlayerId: user2.id,
);
// No timer updates needed
```

#### 3.3 Team Play Mode (2vs2)
**Description**: Collaborative 2v2 team battles

**Features**:
- 4-player teams with role assignments
- Team chat during gameplay
- Combined rating calculation
- Team leaderboards
- Cooperative strategy requirements

**Implementation**:
```dart
final teamMode = await gameModeService.getTeamPlayMode();
// Teams: (Player1 + Player2) vs (Player3 + Player4)
final session = await gameModeService.startGameSession(
  gameMode: teamMode,
  blackPlayerId: team1Player1.id,
  whitePlayerId: team2Player1.id,
);
```

#### 3.4 Puzzle Rush Mode (Timed Marathon)
**Description**: Solve as many puzzles as possible in 30 minutes

**Features**:
- 30-minute total time limit
- Difficulty escalation
- Streak counter
- Leaderboard by:
  - Puzzles solved
  - Correct ratio
  - Points earned
- Practice vs. competitive modes

**Implementation**:
```dart
final rushMode = await gameModeService.getPuzzleRushMode();
// 30 minutes total: 1800 seconds
final session = await gameModeService.startGameSession(
  gameMode: rushMode,
  blackPlayerId: currentUser.id,
  whitePlayerId: currentUser.id, // Single player
);
```

#### 3.5 Handicap Mode (Skill Equalization)
**Description**: Games with handicap stones to balance different skill levels

**Features**:
- Automatic handicap calculation based on ratings
- 2-9 stone handicaps
- Black always places handicap stones
- Komi adjustment (typically 0.5)
- Educational value for strength improvement

**Implementation**:
```dart
final handicapMode = await gameModeService.getHandicapMode();
final session = await gameModeService.startGameSession(
  gameMode: handicapMode,
  blackPlayerId: strongerPlayer.id,
  whitePlayerId: weakerPlayer.id,
);
await gameModeService.setHandicapStones(
  gameId: session.gameId,
  handicapCount: 4, // Based on rating difference
);
```

### Test Coverage
1. Blitz timer implementation and accuracy
2. Correspondence notification system
3. Team mode 4-player coordination
4. Puzzle Rush scoring algorithm
5. Handicap stone placement validation
6. Mode-specific leaderboard calculations
7. Time management for each mode
8. Mode switching and session migration
9. Statistics tracking per mode
10. Mode-specific achievements and badges

---

## Dimension 4: Social Features & Community Building (10 tests)

### 4.1 Friend System
**Features**:
- Add/remove friends
- Friend requests with accept/decline
- Friend profiles with stats
- Block functionality
- Friend-only games

**Implementation**:
```dart
// Send friend request
await socialFeaturesService.addFriend(
  userId: currentUser.id,
  friendId: targetUser.id,
);

// Get friends list
final friends = await socialFeaturesService.getFriendsList(
  userId: currentUser.id,
);

// Check if users are friends
final isFriend = await socialFeaturesService.areFriends(
  userId1: user1.id,
  userId2: user2.id,
);
```

### 4.2 Game Invitations
**Features**:
- Invite friends to specific game modes
- Invitation notifications
- Accept/decline/expire logic
- Invitation history

**Implementation**:
```dart
// Send game invitation
final invitation = await socialFeaturesService.sendGameInvitation(
  fromUserId: currentUser.id,
  toUserId: friendId,
  gameModeId: 'blitz',
);

// Get pending invitations
final pending = await socialFeaturesService.getPendingInvitations(
  userId: currentUser.id,
);

// Accept invitation
await socialFeaturesService.acceptInvitation(
  invitationId: invitation.invitationId,
);
```

### 4.3 Leaderboards
**Features**:
- Global leaderboard (all time)
- Monthly leaderboard (fresh reset)
- Seasonal leaderboard (quarterly)
- Regional leaderboards
- User rank lookup

**Implementation**:
```dart
// Get global top 100
final global = await socialFeaturesService.getGlobalLeaderboard(limit: 100);

// Get current month's leaderboard
final monthly = await socialFeaturesService.getMonthlyLeaderboard(limit: 100);

// Get user's rank
final rank = await socialFeaturesService.getUserRank(
  userId: currentUser.id,
  scope: LeaderboardScope.global,
);

// Update rating after game
await socialFeaturesService.updateUserRating(
  userId: winner.id,
  newRating: 1650, // New rating calculation
);
```

### 4.4 Tournaments
**Features**:
- Tournament creation and scheduling
- Bracket generation (single/double elimination, round-robin)
- Registration and seeding
- Match scheduling
- Real-time results

**Implementation**:
```dart
// Get active tournaments
final active = await socialFeaturesService.getActiveTournaments();

// Register for tournament
await socialFeaturesService.registerForTournament(
  tournamentId: 'tournament-sep-2026',
  userId: currentUser.id,
);

// Get bracket
final bracket = await socialFeaturesService.getTournamentBracket(
  tournamentId: 'tournament-sep-2026',
);
```

### 4.5 In-Game Chat
**Features**:
- Chat during observation mode
- Real-time message streaming
- Moderation (report, mute, block)
- Emoji and Japanese support

**Implementation**:
```dart
// Send chat message
await socialFeaturesService.sendChatMessage(
  userId: currentUser.id,
  displayName: currentUser.displayName,
  content: 'すばらしい手ですね！',
  gameId: 'game123',
);

// Get message history
final messages = await socialFeaturesService.getGameChat(
  gameId: 'game123',
  limit: 50,
);

// Stream live messages
socialFeaturesService.streamGameChat(gameId: 'game123').listen((message) {
  print('${message.fromDisplayName}: ${message.content}');
});
```

### Test Coverage
1. Friend request lifecycle (pending → accepted/blocked)
2. Game invitation expiration (24 hours)
3. Leaderboard ranking accuracy
4. Tournament bracket generation
5. Chat message persistence
6. Real-time chat streaming
7. Notification delivery
8. User blocking and muting
9. Moderation flag handling
10. Analytics for friend network growth

---

## Dimension 5: Analytics & Social Metrics (10 tests)

### 5.1 Share Attribution Tracking
**Features**:
- Track which content was shared on which platform
- Attribution chain (share → click → install → signup)
- Referral codes and links
- Platform-specific UTM parameters

**Implementation**:
```dart
// Log share action
await socialFeaturesService.updateSocialAnalytics(
  userId: currentUser.id,
  updates: {
    'lastSharedAt': DateTime.now().toIso8601String(),
    'totalShares': FieldValue.increment(1),
  },
);

// Track with attribution
final tracking = SocialShareTracking(
  trackingId: 'track-${DateTime.now().millisecondsSinceEpoch}',
  userId: currentUser.id,
  contentType: 'game',
  contentId: gameId,
  platform: 'twitter',
  sharedAt: DateTime.now(),
  externalUrl: 'https://twitter.com/user/status/123456',
);
```

### 5.2 Engagement Analytics
**Features**:
- Share count per content type
- Engagement metrics (likes, retweets, comments)
- Content performance analysis
- Trending content detection

**Implementation**:
```dart
// Get share metrics for content
final metrics = ShareMetrics(
  contentId: gameId,
  twitterShares: 45,
  facebookShares: 12,
  whatsappShares: 23,
  lineShares: 8,
  totalShares: 88,
  totalEngagement: 234, // likes + retweets + comments
  viralCoefficient: 2.66, // engagement / shares
);
```

### 5.3 Viral Coefficient Measurement
**Metrics**:
- Viral Coefficient = (New Users from Referral / Existing Users) × (Invitations Sent / User)
- Track user acquisition from social shares
- Monitor growth velocity
- Identify viral content patterns

### 5.4 User Retention by Social Features
**Tracking**:
- Retention rate for users with:
  - Active friend networks
  - Regular tournament participation
  - High social share count
  - Chat engagement
- Cohort analysis by onboarding source

### 5.5 Content Performance Analysis
**Metrics**:
- Top shared game types
- Best performing times for sharing
- Platform-specific content preferences
- User demographic analysis

### Test Coverage
1. Share tracking data persistence
2. Attribution chain validation
3. Viral coefficient calculation accuracy
4. Retention cohort analysis
5. Engagement metric aggregation
6. Platform-specific analytics
7. Real-time metric updates
8. Historical trend analysis
9. Anomaly detection in metrics
10. Analytics data export and reporting

---

## Architecture & Integration

### Service Integration
```dart
// Initialize all Phase 58 services
final snsApi = SnsApiService(
  twitterBearerToken: config.twitterToken,
  facebookAccessToken: config.facebookToken,
  instagramAccessToken: config.instagramToken,
);

final gameMode = GameModeService();
final socialFeatures = SocialFeaturesService();

// Use in providers
final snsApiProvider = Provider((ref) => snsApi);
final gameModeProvider = Provider((ref) => gameMode);
final socialFeaturesProvider = Provider((ref) => socialFeatures);
```

### Data Flow
1. **User Action** → Game Result / Achievement
2. **Share Trigger** → Content Generation
3. **SNS API** → Post to Platform
4. **Tracking** → Log Share Attribution
5. **Analytics** → Update Metrics
6. **Notification** → Notify Friends/Followers

### Error Handling
- Platform API failures → Fallback to native share
- Network timeouts → Queue for retry
- Rate limits → Exponential backoff
- Missing tokens → Graceful degradation

---

## Configuration

### Twitter/X API Setup
```env
TWITTER_BEARER_TOKEN=<your-token>
TWITTER_API_KEY=<key>
TWITTER_API_SECRET=<secret>
TWITTER_ACCESS_TOKEN=<token>
TWITTER_ACCESS_SECRET=<secret>
```

### Facebook Setup
```env
FACEBOOK_APP_ID=<app-id>
FACEBOOK_APP_SECRET=<secret>
FACEBOOK_ACCESS_TOKEN=<token>
```

### Firebase Collections
```
game_modes/
├── blitz/
├── correspondence/
├── team_play/
├── puzzle_rush/
└── handicap/

game_sessions/
├── {sessionId}/
│   ├── gameId
│   ├── modeId
│   ├── blackPlayerId
│   ├── whitePlayerId
│   ├── startedAt
│   ├── endedAt
│   ├── timeRemainingBlack
│   └── timeRemainingWhite

users/{userId}/friends/
├── {friendId}/
│   ├── status: 'pending' | 'accepted' | 'blocked'
│   ├── addedAt
│   └── displayName

game_invitations/
├── {invitationId}/
│   ├── fromUserId
│   ├── toUserId
│   ├── gameMode
│   ├── status
│   └── createdAt

leaderboard_global/
├── {userId}/
│   ├── rating
│   ├── gamesPlayed
│   └── winRate

tournaments/
├── {tournamentId}/
│   ├── name
│   ├── status
│   ├── format
│   └── participants/

chat_messages/
├── {messageId}/
│   ├── gameId
│   ├── fromUserId
│   ├── content
│   └── sentAt

social_share_tracking/
└── {trackingId}/
    ├── userId
    ├── platform
    ├── contentType
    └── sharedAt
```

---

## Testing Strategy

### Unit Tests
- Service method validation
- Data model serialization
- Metric calculations
- Time management logic

### Integration Tests
- SNS API posting workflow
- Friend request lifecycle
- Tournament bracket generation
- Leaderboard updates

### E2E Tests
- Complete game share flow (play → share → track)
- Friend invitation and game creation
- Tournament registration and participation
- Real-time chat during observation

### Performance Tests
- Leaderboard query performance (< 500ms for top 100)
- Chat message latency (< 1 second)
- Share API response time (< 2 seconds)
- Metric aggregation efficiency

---

## Rollout Plan

### Phase 58.1 (Sept 15-18)
- SNS API integration (Twitter/X)
- Game modes foundation
- Social features scaffolding

### Phase 58.2 (Sept 18-20)
- Multi-platform SNS (Facebook, WhatsApp, LINE)
- Complete game modes implementation
- Analytics tracking

### Phase 58.3 (Sept 20+)
- Tournament system
- Advanced leaderboards
- Real-time chat system

---

## Success Metrics

- **Social Sharing**: 40%+ of users share at least one game
- **Viral Coefficient**: > 1.5 (each user invites > 1.5 new players)
- **Friend Network**: Avg 5+ friends per active user
- **Tournament Participation**: 15%+ of users join tournaments
- **Chat Engagement**: Avg 50+ messages per 100 observations
- **Retention**: +10% 30-day retention with active social features

---

## Future Enhancements

- **Streaming Integration**: YouTube/Twitch game broadcasts
- **AI Commentary**: Automated tweet generation with move analysis
- **Sponsorship Integrations**: Tournament prizes and rewards
- **Mobile Notifications**: Push notifications for friend activities
- **Community Moderators**: User-elected community leaders
- **Content Creation Tools**: Built-in board image editor and filters

---

## Files Implemented

### Services
- `lib/services/sns_api_service.dart` - SNS API integration
- `lib/services/game_mode_service.dart` - Game mode management
- `lib/services/social_features_service.dart` - Social features

### Models
- `lib/models/sns_models.dart` - SNS and social data models

### Index
- `lib/services/index.dart` - Updated barrel exports

### Documentation
- `README_PHASE_58.md` - This file

---

## Related Documents

- **Phase 57**: Testing infrastructure foundation
- **Phase 59+**: Advanced community features, streaming, and analytics dashboards
