import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:goen/models/index.dart';
import 'package:goen/viewmodels/index.dart';
import 'package:goen/config/theme.dart';

final _logger = Logger();

/// PaywallScreen - Premium subscription upgrade flow
///
/// Features:
/// - Display premium features and benefits
/// - Show subscription pricing plans (monthly, annual, lifetime)
/// - Handle purchase via RevenueCat
/// - Track paywall view and conversion events
/// - Graceful handling of purchase failures
class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  bool _showAnnual = false;

  @override
  void initState() {
    super.initState();
    _logger.i('PaywallScreen initialized');
    ref.read(logPaywallViewedProvider)();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final isSubscriptionActive = ref.watch(isSubscriptionActiveProvider);

    // If already subscribed, show success state
    if (isSubscriptionActive) {
      return _buildSubscribedState(context);
    }

    return Scaffold(
      backgroundColor: AppColors.sumi,
      appBar: AppBar(
        title: const Text('Premium Membership'),
        centerTitle: true,
        backgroundColor: AppColors.sumi,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero section
            _buildHeroSection(context),

            // Benefits section
            _buildBenefitsSection(context),

            // Pricing section
            _buildPricingSection(context),

            // FAQ section
            _buildFaqSection(context),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.kin,
                  AppColors.kin,
                ],
              ),
            ),
            child: Center(
              child: Icon(
                Icons.star,
                size: 50,
                color: AppColors.washi,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Unlock Premium Features',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColors.washi,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Join premium adults learning Go at their own pace',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.washiDim,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitsSection(BuildContext context) {
    final benefits = [
      ('Unlimited Games', 'Play as many AI games as you want'),
      ('Kifu Library', 'Learn from 1000+ historical games'),
      ('Advanced Stats', 'Track your progress with detailed analytics'),
      ('No Ads', 'Enjoy distraction-free learning'),
      ('Early Access', 'Try new features first'),
      ('Premium Support', 'Priority customer support'),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What You Get',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.washi,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...benefits.map((benefit) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 20,
                    color: AppColors.wakatake,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          benefit.$1,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.washi,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          benefit.$2,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.washiDim,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildPricingSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Toggle between monthly and annual
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white10),
              borderRadius: BorderRadius.circular(8),
              color: AppColors.washi.withOpacity(0.03),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _showAnnual = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        color: !_showAnnual
                            ? AppColors.kin.withOpacity(0.2)
                            : Colors.transparent,
                      ),
                      child: Text(
                        'Monthly',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: !_showAnnual ? AppColors.kin : AppColors.washiDim,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _showAnnual = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        color: _showAnnual
                            ? AppColors.kin.withOpacity(0.2)
                            : Colors.transparent,
                      ),
                      child: Text(
                        'Annual',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: _showAnnual ? AppColors.kin : AppColors.washiDim,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          if (!_showAnnual)
            _buildPricingCard(
              context,
              'Monthly',
              '9.99',
              '/month',
              'Perfect for trying premium features',
              false,
            )
          else
            Column(
              children: [
                _buildPricingCard(
                  context,
                  'Annual',
                  '79.99',
                  '/year',
                  'Save 33% with annual billing',
                  false,
                ),
                const SizedBox(height: 12),
                _buildPricingCard(
                  context,
                  'Lifetime',
                  '299.99',
                  'one-time',
                  'Unlock forever with one payment',
                  true,
                ),
              ],
            ),

          const SizedBox(height: 16),

          Text(
            'Cancel anytime. No hidden fees.',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.washiDim,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _handlePurchase(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.kin,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                'Continue with ${_showAnnual ? "Annual" : "Monthly"}',
                style: const TextStyle(
                  color: AppColors.sumi,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingCard(
    BuildContext context,
    String title,
    String price,
    String period,
    String description,
    bool isHighlighted,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(
          color: isHighlighted ? AppColors.kin : Colors.white10,
          width: isHighlighted ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
        color: isHighlighted
            ? AppColors.kin.withOpacity(0.1)
            : AppColors.washi.withOpacity(0.03),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.washi,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isHighlighted)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.kin,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'BEST VALUE',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.sumi,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '\$$price',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.washi,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: period,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.washiDim,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.washiDim,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'FAQ',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.washi,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildFaqItem(
            context,
            'Can I cancel anytime?',
            'Yes! Your subscription will be active until the end of the billing period. Cancel from the app settings at any time.',
          ),
          const SizedBox(height: 12),
          _buildFaqItem(
            context,
            'What payment methods are accepted?',
            'We accept all major credit cards via our secure payment processor.',
          ),
          const SizedBox(height: 12),
          _buildFaqItem(
            context,
            'Is there a free trial?',
            'Not currently, but our free plan gives you access to 3 AI games to try the experience.',
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem(BuildContext context, String question, String answer) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white10),
        borderRadius: BorderRadius.circular(8),
        color: AppColors.washi.withOpacity(0.03),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.washi,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            answer,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.washiDim,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscribedState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.wakatake.withOpacity(0.2),
              border: Border.all(
                color: AppColors.wakatake,
                width: 3,
              ),
            ),
            child: Icon(
              Icons.check_circle,
              size: 60,
              color: AppColors.wakatake,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'You\'re Premium!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColors.washi,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Enjoy unlimited access to all premium features',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.washiDim,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _handlePurchase(BuildContext context) {
    _logger.i('Processing purchase');

    final plan = _showAnnual ? 'annual' : 'monthly';
    final price = plan == 'annual' ? 79.99 : 9.99;
    ref.read(logPaywallConvertedProvider)(
      plan: plan,
      price: price,
      currency: 'USD',
    );

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(AppColors.kin),
        ),
      ),
    );

    // Simulate purchase processing
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context); // Close loading

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Purchase processing - RevenueCat integration (Phase 5.5)'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    });
  }
}
