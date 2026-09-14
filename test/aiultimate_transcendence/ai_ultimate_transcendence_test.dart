import 'package:flutter_test/flutter_test.dart';

class UltimateTranscendence {
  final int counter;
  UltimateTranscendence({required this.counter});
  bool isValid() => counter >= 0 && counter <= 250;
  double calculateAccuracy() => ((250 - counter) / 250) * 100;
  String report() => 'UltimateTranscendence { counter: $counter, accuracy: ${calculateAccuracy().toStringAsFixed(2)}%, validation: ${isValid()} }';
}

class PerfectTranscendenceState {
  final int counter;
  PerfectTranscendenceState({required this.counter});
  bool isValid() => counter >= 0 && counter <= 251;
  double calculateAccuracy() => ((251 - counter) / 251) * 100;
  String report() => 'PerfectTranscendenceState { counter: $counter, accuracy: ${calculateAccuracy().toStringAsFixed(2)}%, validation: ${isValid()} }';
}

class InfiniteTranscendence {
  final int counter;
  InfiniteTranscendence({required this.counter});
  bool isValid() => counter >= 0 && counter <= 252;
  double calculateAccuracy() => ((252 - counter) / 252) * 100;
  String report() => 'InfiniteTranscendence { counter: $counter, accuracy: ${calculateAccuracy().toStringAsFixed(2)}%, validation: ${isValid()} }';
}

void main() {
  group('UltimateTranscendence', () {
    test('validates min', () => expect(UltimateTranscendence(counter: 0).isValid(), true));
    test('validates max', () => expect(UltimateTranscendence(counter: 250).isValid(), true));
    test('rejects below', () => expect(UltimateTranscendence(counter: -1).isValid(), false));
    test('rejects above', () => expect(UltimateTranscendence(counter: 251).isValid(), false));
    test('perfect accuracy', () => expect(UltimateTranscendence(counter: 0).calculateAccuracy(), closeTo(100.0, 0.01)));
    test('worst accuracy', () => expect(UltimateTranscendence(counter: 250).calculateAccuracy(), closeTo(0.0, 0.01)));
    test('midpoint accuracy', () => expect(UltimateTranscendence(counter: 125).calculateAccuracy(), closeTo(50.0, 0.5)));
    test('threshold check', () => expect(UltimateTranscendence(counter: 8).calculateAccuracy(), greaterThanOrEqualTo(96.0)));
    test('report generation', () => expect(UltimateTranscendence(counter: 50).report(), contains('UltimateTranscendence')));
    test('formula consistency', () => expect(UltimateTranscendence(counter: 50).calculateAccuracy(), closeTo(80.0, 0.5)));
  });

  group('PerfectTranscendenceState', () {
    test('validates min', () => expect(PerfectTranscendenceState(counter: 0).isValid(), true));
    test('validates max', () => expect(PerfectTranscendenceState(counter: 251).isValid(), true));
    test('rejects below', () => expect(PerfectTranscendenceState(counter: -1).isValid(), false));
    test('rejects above', () => expect(PerfectTranscendenceState(counter: 252).isValid(), false));
    test('perfect accuracy', () => expect(PerfectTranscendenceState(counter: 0).calculateAccuracy(), closeTo(100.0, 0.01)));
    test('worst accuracy', () => expect(PerfectTranscendenceState(counter: 251).calculateAccuracy(), closeTo(0.0, 0.01)));
    test('midpoint accuracy', () => expect(PerfectTranscendenceState(counter: 125).calculateAccuracy(), closeTo(50.2, 0.5)));
    test('threshold check', () => expect(PerfectTranscendenceState(counter: 8).calculateAccuracy(), greaterThanOrEqualTo(96.0)));
    test('report generation', () => expect(PerfectTranscendenceState(counter: 50).report(), contains('PerfectTranscendenceState')));
    test('formula consistency', () => expect(PerfectTranscendenceState(counter: 50).calculateAccuracy(), closeTo(80.0, 0.5)));
  });

  group('InfiniteTranscendence', () {
    test('validates min', () => expect(InfiniteTranscendence(counter: 0).isValid(), true));
    test('validates max', () => expect(InfiniteTranscendence(counter: 252).isValid(), true));
    test('rejects below', () => expect(InfiniteTranscendence(counter: -1).isValid(), false));
    test('rejects above', () => expect(InfiniteTranscendence(counter: 253).isValid(), false));
    test('perfect accuracy', () => expect(InfiniteTranscendence(counter: 0).calculateAccuracy(), closeTo(100.0, 0.01)));
    test('worst accuracy', () => expect(InfiniteTranscendence(counter: 252).calculateAccuracy(), closeTo(0.0, 0.01)));
    test('midpoint accuracy', () => expect(InfiniteTranscendence(counter: 126).calculateAccuracy(), closeTo(50.0, 0.5)));
    test('threshold check', () => expect(InfiniteTranscendence(counter: 8).calculateAccuracy(), greaterThanOrEqualTo(96.0)));
    test('report generation', () => expect(InfiniteTranscendence(counter: 50).report(), contains('InfiniteTranscendence')));
    test('formula consistency', () => expect(InfiniteTranscendence(counter: 50).calculateAccuracy(), closeTo(80.1, 0.5)));
  });
}
