import 'package:flutter/material.dart';
import 'package:goen/config/theme.dart';

/// Displays the privacy policy or terms of service in-app.
///
/// This is boilerplate reflecting what the app's own code actually does
/// (Firebase Auth/Firestore/Analytics/Crashlytics, in-app purchases via
/// the platform store) — not a substitute for legal review before a real
/// store submission. Replace the bracketed placeholders (contact email,
/// company/developer name) before release.
class LegalDocumentScreen extends StatelessWidget {
  final LegalDocumentKind kind;

  const LegalDocumentScreen({Key? key, required this.kind}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final title = kind == LegalDocumentKind.privacyPolicy ? 'Privacy Policy' : 'Terms of Service';
    final body = kind == LegalDocumentKind.privacyPolicy ? _privacyPolicyText : _termsOfServiceText;

    return Scaffold(
      backgroundColor: AppColors.sumi,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: AppColors.sumi,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Text(
          body,
          style: const TextStyle(color: AppColors.washiDim, height: 1.6, fontSize: 14),
        ),
      ),
    );
  }
}

enum LegalDocumentKind { privacyPolicy, termsOfService }

const _lastUpdated = '2026-09-20';

const _privacyPolicyText = '''
Privacy Policy
Last updated: $_lastUpdated

碁縁 (GoEn) ("the App") is developed by [Developer/Company Name] ("we", "us"). This policy explains what data we collect and how it's used.

1. Information We Collect
- Account information: email address and display name, via Firebase Authentication.
- Gameplay data: game records, moves, results, tsume-go/puzzle progress, and preferences you set in the App, stored in Cloud Firestore.
- Usage analytics: app events (e.g. screens viewed, features used) via Firebase Analytics, and crash/error reports via Firebase Crashlytics.
- Purchase information: subscription plan and status when you buy premium access. Payment details themselves (card numbers, etc.) are handled entirely by Apple's App Store or Google Play and never reach our servers.

2. How We Use Information
- To operate core features: authentication, saving your games and progress, matchmaking, and social features (friends, tournaments, spectating) that you choose to use.
- To maintain and improve the App: diagnosing crashes and understanding feature usage in aggregate.
- To manage your subscription and unlock premium features you've purchased.

3. Data Sharing
We do not sell your personal data to third parties. Data is shared only with:
- Firebase/Google Cloud, which hosts our backend (authentication, database, analytics, crash reporting).
- Apple/Google, for processing in-app purchases.
- Other users, only for information you choose to make visible through app features (e.g. your display name to friends, spectators of a game you host, or match participants).

4. Data Retention & Deletion
Your account data is retained while your account is active. You can delete your account from Settings, which removes your Firebase Authentication account; associated Firestore data deletion may take additional time to fully propagate. Contact us at [privacy@example.com] to request full data deletion.

5. Children's Privacy
The App is intended for general audiences and is not directed at children under 13. We do not knowingly collect personal information from children under 13.

6. Changes to This Policy
We may update this policy from time to time. Continued use of the App after changes constitutes acceptance of the updated policy.

7. Contact
Questions about this policy: [privacy@example.com]
''';

const _termsOfServiceText = '''
Terms of Service
Last updated: $_lastUpdated

These Terms govern your use of 碁縁 (GoEn) ("the App"), developed by [Developer/Company Name]. By using the App, you agree to these Terms.

1. Accounts
You're responsible for maintaining the confidentiality of your account credentials and for all activity under your account. You must provide accurate information when creating an account.

2. Acceptable Use
You agree not to: cheat or manipulate game results, harass other players, attempt to access another user's account or data, or reverse-engineer or interfere with the App's operation.

3. Subscriptions & Purchases
Premium features are offered via auto-renewing subscriptions or one-time purchases, billed through the Apple App Store or Google Play. Pricing, billing cycles, and cancellation are managed through your platform account settings (App Store/Play Store), not directly by us. Refunds are subject to Apple's/Google's respective policies.

4. User Content
Game records, comments, and other content you create in the App remain yours, but you grant us a license to store and display it as needed to operate App features (e.g. sharing a game with spectators or friends you invite).

5. Availability
We aim to keep the App available but do not guarantee uninterrupted access. Features that depend on third-party services (e.g. live streaming integrations) may be unavailable if those integrations are not yet configured or the third party's service is down.

6. Termination
We may suspend or terminate accounts that violate these Terms. You may stop using the App and delete your account at any time from Settings.

7. Disclaimer & Liability
The App is provided "as is" without warranties of any kind. To the maximum extent permitted by law, we are not liable for indirect or consequential damages arising from your use of the App.

8. Changes to These Terms
We may update these Terms from time to time. Continued use of the App after changes constitutes acceptance of the updated Terms.

9. Contact
Questions about these Terms: [support@example.com]
''';
