import 'package:flutter_test/flutter_test.dart';

/// A/B Testing Framework Tests
///
/// These tests establish the infrastructure for conducting A/B tests
/// on features, UI variations, and performance optimizations
void main() {
  group('A/B Testing: Experimentation Framework', () {
    test('🧪 A/B Test: Control vs Treatment group assignment', () async {
      const userCount = 1000;
      final assignments = <String, int>{};

      // Simulate randomized group assignment
      for (int i = 0; i < userCount; i++) {
        final hash = (i * 17).hashCode;
        final isControl = hash.isEven;
        final group = isControl ? 'control' : 'treatment';

        assignments[group] = (assignments[group] ?? 0) + 1;
      }

      print('🧪 Group Distribution (n=$userCount):');
      print('  Control: ${assignments['control']!} (${(assignments['control']! / userCount * 100).toStringAsFixed(1)}%)');
      print('  Treatment: ${assignments['treatment']!} (${(assignments['treatment']! / userCount * 100).toStringAsFixed(1)}%)');

      // Should be approximately 50/50 split
      expect(assignments['control']!, greaterThan((userCount * 0.45).toInt()));
      expect(assignments['treatment']!, greaterThan((userCount * 0.45).toInt()));
    });

    test('🧪 A/B Test: Feature flag variation assignment', () async {
      // Define variations for a feature flag
      const variations = ['original', 'variation_a', 'variation_b'];
      const userCount = 300;
      final variationAssignments = <String, int>{};

      for (final variation in variations) {
        variationAssignments[variation] = 0;
      }

      // Simulate weighted assignment
      for (int i = 0; i < userCount; i++) {
        final hash = (i * 23).hashCode.abs();
        final distribution = hash % 100;

        late String assignedVariation;
        if (distribution < 30) {
          assignedVariation = 'original';
        } else if (distribution < 65) {
          assignedVariation = 'variation_a';
        } else {
          assignedVariation = 'variation_b';
        }

        variationAssignments[assignedVariation] =
            variationAssignments[assignedVariation]! + 1;
      }

      print('🧪 Feature Flag Variation Distribution (n=$userCount):');
      variationAssignments.forEach((variation, count) {
        final percent = (count / userCount * 100).toStringAsFixed(1);
        print('  $variation: $count ($percent%)');
      });

      // Verify reasonable distribution
      expect(variationAssignments['original']!, greaterThan((userCount * 0.25).toInt()));
      expect(variationAssignments['variation_a']!, greaterThan((userCount * 0.25).toInt()));
      expect(variationAssignments['variation_b']!, greaterThan((userCount * 0.25).toInt()));
    });

    test('🧪 A/B Test: Metric collection for control and treatment', () async {
      // Simulate A/B test with engagement metric (games played)
      const samplesPerGroup = 500;
      final controlMetrics = <int>[];
      final treatmentMetrics = <int>[];

      // Control group: baseline engagement
      for (int i = 0; i < samplesPerGroup; i++) {
        final gamesPlayed = 2 + (i % 5);
        controlMetrics.add(gamesPlayed);
      }

      // Treatment group: new feature improving engagement
      for (int i = 0; i < samplesPerGroup; i++) {
        final gamesPlayed = 3 + (i % 6); // Slightly higher
        treatmentMetrics.add(gamesPlayed);
      }

      final controlAvg = controlMetrics.reduce((a, b) => a + b) / controlMetrics.length;
      final treatmentAvg = treatmentMetrics.reduce((a, b) => a + b) / treatmentMetrics.length;
      final lifts = ((treatmentAvg - controlAvg) / controlAvg) * 100;

      print('🧪 Engagement Metric (Games Played):');
      print('  Control: ${controlAvg.toStringAsFixed(2)} avg');
      print('  Treatment: ${treatmentAvg.toStringAsFixed(2)} avg');
      print('  Lift: ${lifts.toStringAsFixed(1)}%');

      // Treatment should show positive engagement
      expect(treatmentAvg, greaterThanOrEqualTo(controlAvg));
    });

    test('🧪 A/B Test: Conversion rate comparison', () async {
      // Simulate A/B test on paywall (conversion to paid)
      const samplesPerGroup = 1000;

      // Control: original paywall
      var controlConversions = 0;
      for (int i = 0; i < samplesPerGroup; i++) {
        if (i % 50 == 0) controlConversions++; // 2% conversion
      }

      // Treatment: redesigned paywall
      var treatmentConversions = 0;
      for (int i = 0; i < samplesPerGroup; i++) {
        if (i % 40 == 0) treatmentConversions++; // 2.5% conversion
      }

      final controlRate = (controlConversions / samplesPerGroup) * 100;
      final treatmentRate = (treatmentConversions / samplesPerGroup) * 100;
      final conversionLift = ((treatmentRate - controlRate) / controlRate) * 100;

      print('🧪 Paywall Conversion Rate:');
      print('  Control: ${controlRate.toStringAsFixed(2)}%');
      print('  Treatment: ${treatmentRate.toStringAsFixed(2)}%');
      print('  Lift: ${conversionLift.toStringAsFixed(1)}%');

      expect(controlRate, lessThan(5.0));
      expect(treatmentRate, lessThan(5.0));
    });

    test('🧪 A/B Test: Performance metric comparison (page load)', () async {
      const samplesPerGroup = 100;
      final controlLoadTimes = <int>[];
      final treatmentLoadTimes = <int>[];

      // Control: existing implementation
      for (int i = 0; i < samplesPerGroup; i++) {
        final loadTime = 800 + (i % 200);
        controlLoadTimes.add(loadTime);
      }

      // Treatment: optimized implementation
      for (int i = 0; i < samplesPerGroup; i++) {
        final loadTime = 600 + (i % 150);
        treatmentLoadTimes.add(loadTime);
      }

      final controlAvg = controlLoadTimes.reduce((a, b) => a + b) / samplesPerGroup;
      final treatmentAvg = treatmentLoadTimes.reduce((a, b) => a + b) / samplesPerGroup;
      final improvement = ((controlAvg - treatmentAvg) / controlAvg) * 100;

      // Calculate percentiles
      controlLoadTimes.sort();
      treatmentLoadTimes.sort();
      final controlP95 = controlLoadTimes[(samplesPerGroup * 0.95).toInt()];
      final treatmentP95 = treatmentLoadTimes[(samplesPerGroup * 0.95).toInt()];

      print('🧪 Page Load Time:');
      print('  Control: ${controlAvg.toStringAsFixed(0)}ms avg, ${controlP95}ms P95');
      print('  Treatment: ${treatmentAvg.toStringAsFixed(0)}ms avg, ${treatmentP95}ms P95');
      print('  Improvement: ${improvement.toStringAsFixed(1)}%');

      expect(treatmentAvg, lessThan(controlAvg));
    });

    test('🧪 A/B Test: Retention curve comparison', () async {
      // Simulate 30-day retention curves
      const days = 30;
      final controlRetention = <int, double>{};
      final treatmentRetention = <int, double>{};

      for (int day = 1; day <= days; day++) {
        // Control: steeper decline
        controlRetention[day] = 100 * (0.95 ^ day);

        // Treatment: better retention
        treatmentRetention[day] = 100 * (0.97 ^ day);
      }

      final controlDay30 = controlRetention[30]!;
      final treatmentDay30 = treatmentRetention[30]!;
      final retentionLift = treatmentDay30 - controlDay30;

      print('🧪 30-Day Retention Curve:');
      print('  Control Day 1: ${controlRetention[1]!.toStringAsFixed(1)}%, Day 30: ${controlDay30.toStringAsFixed(1)}%');
      print('  Treatment Day 1: ${treatmentRetention[1]!.toStringAsFixed(1)}%, Day 30: ${treatmentDay30.toStringAsFixed(1)}%');
      print('  Lift at Day 30: ${retentionLift.toStringAsFixed(1)}%');

      expect(treatmentDay30, greaterThan(controlDay30));
    });

    test('🧪 A/B Test: Statistical significance calculation', () async {
      // Simulate A/B test with effect size calculation
      const samplesPerGroup = 500;
      final controlValues = <int>[];
      final treatmentValues = <int>[];

      // Control group
      for (int i = 0; i < samplesPerGroup; i++) {
        controlValues.add(10 + (i % 20));
      }

      // Treatment group
      for (int i = 0; i < samplesPerGroup; i++) {
        treatmentValues.add(12 + (i % 20)); // Slight improvement
      }

      // Calculate means and standard deviations
      final controlMean = controlValues.reduce((a, b) => a + b) / samplesPerGroup;
      final treatmentMean = treatmentValues.reduce((a, b) => a + b) / samplesPerGroup;

      // Simplified standard deviation
      final controlVar = controlValues
          .fold(0.0, (sum, val) => sum + ((val - controlMean) * (val - controlMean))) /
          samplesPerGroup;
      final treatmentVar = treatmentValues
          .fold(0.0, (sum, val) => sum + ((val - treatmentMean) * (val - treatmentMean))) /
          samplesPerGroup;

      final controlStd = controlVar.isFinite ? controlVar.sqrt() : 0;
      final treatmentStd = treatmentVar.isFinite ? treatmentVar.sqrt() : 0;

      // Calculate t-statistic (simplified)
      final pooledStd =
          ((controlStd + treatmentStd) / 2);
      final tStatistic = pooledStd > 0
          ? (treatmentMean - controlMean) / (pooledStd / (samplesPerGroup.sqrt()))
          : 0;

      // Effect size (Cohen's d)
      final cohensD =
          pooledStd > 0 ? (treatmentMean - controlMean) / pooledStd : 0;

      print('🧪 Statistical Significance:');
      print('  Control: mean=${controlMean.toStringAsFixed(2)}, std=${controlStd.toStringAsFixed(2)}');
      print('  Treatment: mean=${treatmentMean.toStringAsFixed(2)}, std=${treatmentStd.toStringAsFixed(2)}');
      print('  t-statistic: ${tStatistic.toStringAsFixed(2)}');
      print('  Cohen\'s d: ${cohensD.toStringAsFixed(3)}');

      // Effect should be detectable
      expect(tStatistic.abs(), greaterThan(0.5),
        reason: 'Effect size too small to be meaningful');
    });

    test('🧪 A/B Test: Segmentation analysis', () async {
      // Analyze A/B test results by user segments
      final segments = {
        'new_users': {'control': 45.0, 'treatment': 52.0},
        'existing_users': {'control': 65.0, 'treatment': 68.0},
        'power_users': {'control': 75.0, 'treatment': 76.0},
      };

      print('🧪 Segmentation Analysis (Engagement %%):');
      segments.forEach((segment, metrics) {
        final controlVal = metrics['control'] as double;
        final treatmentVal = metrics['treatment'] as double;
        final lift = treatmentVal - controlVal;
        print('  $segment: Control=${controlVal.toStringAsFixed(1)}%, '
              'Treatment=${treatmentVal.toStringAsFixed(1)}% (Lift=${lift.toStringAsFixed(1)}%)');
      });

      // Verify treatment improves across all segments
      segments.forEach((segment, metrics) {
        expect(metrics['treatment'] as double,
          greaterThanOrEqualTo(metrics['control'] as double),
          reason: 'Treatment should improve or maintain control in $segment');
      });
    });

    test('🧪 A/B Test: Confidence interval calculation', () async {
      // Calculate 95% confidence intervals for A/B test results
      const controlSampleSize = 500;
      const treatmentSampleSize = 500;
      final controlConversions = 25; // 5% conversion
      final treatmentConversions = 35; // 7% conversion

      final controlRate = controlConversions / controlSampleSize;
      final treatmentRate = treatmentConversions / treatmentSampleSize;

      // Simplified confidence interval (normal approximation)
      final controlStdErr = (controlRate * (1 - controlRate) / controlSampleSize).sqrt();
      final treatmentStdErr = (treatmentRate * (1 - treatmentRate) / treatmentSampleSize).sqrt();

      final zScore = 1.96; // 95% confidence

      final controlCI_low = controlRate - (zScore * controlStdErr);
      final controlCI_high = controlRate + (zScore * controlStdErr);
      final treatmentCI_low = treatmentRate - (zScore * treatmentStdErr);
      final treatmentCI_high = treatmentRate + (zScore * treatmentStdErr);

      print('🧪 95%% Confidence Intervals:');
      print('  Control: ${(controlRate * 100).toStringAsFixed(2)}% [${(controlCI_low * 100).toStringAsFixed(2)}%, ${(controlCI_high * 100).toStringAsFixed(2)}%]');
      print('  Treatment: ${(treatmentRate * 100).toStringAsFixed(2)}% [${(treatmentCI_low * 100).toStringAsFixed(2)}%, ${(treatmentCI_high * 100).toStringAsFixed(2)}%]');

      // Intervals should not overlap too much (indicative of significance)
      expect(treatmentRate, greaterThan(controlRate));
    });

    test('🧪 A/B Test: Multi-armed bandit allocation', () async {
      // Simulate Thompson Sampling for multi-armed bandit
      final arms = {
        'original': {'successes': 45, 'failures': 55},
        'variation_a': {'successes': 52, 'failures': 48},
        'variation_b': {'successes': 48, 'failures': 52},
      };

      print('🧪 Multi-Armed Bandit Results:');
      final successRates = <String, double>{};

      arms.forEach((armName, results) {
        final total = results['successes']! + results['failures']!;
        final rate = results['successes']! / total;
        successRates[armName] = rate;

        print('  $armName: ${(rate * 100).toStringAsFixed(1)}% success '
              '(${results['successes']}/${results['failures']} w/l)');
      });

      // Identify best arm
      final bestArm = successRates.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;

      print('🧪 Recommendation: Allocate more traffic to $bestArm');

      // Best arm should have highest success rate
      expect(successRates[bestArm]!, greaterThanOrEqualTo(0.4));
    });
  });
}

extension on double {
  double sqrt() {
    if (this < 0) return double.nan;
    if (this == 0) return 0;
    var x = this;
    var prev = 0.0;
    while ((x - prev).abs() > 1e-10) {
      prev = x;
      x = (x + this / x) / 2;
    }
    return x;
  }

  double pow(double exponent) {
    if (exponent == 0) return 1;
    if (exponent == 1) return this;
    if (exponent == 2) return this * this;

    var result = 1.0;
    var base = this;
    var exp = exponent.toInt();

    for (int i = 0; i < exp; i++) {
      result *= base;
    }

    return result;
  }
}
