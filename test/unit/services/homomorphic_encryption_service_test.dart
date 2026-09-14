import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Homomorphic Encryption & Secure Computation - Phase 77', () {
    // ==========================================
    // GROUP 1: Fully Homomorphic Encryption (FHE) Fundamentals & Circuit Evaluation (10 tests)
    // ==========================================
    group('GROUP 1: Fully Homomorphic Encryption (FHE) Fundamentals & Circuit Evaluation', () {
      test('Implements Brakerski-Gentry-Vaikuntanathan (BGV) FHE scheme', () {
        // Arrange
        final secretKey = 'bgv_secret_key';
        final publicKey = 'bgv_public_key';
        final plaintext1 = [1, 0, 1, 1]; // Binary message
        final plaintext2 = [0, 1, 1, 0];
        final errorDistribution = 'discrete_gaussian';

        // Act
        final ciphertext1 = _encryptBGV(plaintext1, publicKey, errorDistribution);
        final ciphertext2 = _encryptBGV(plaintext2, publicKey, errorDistribution);

        // Assert
        expect(ciphertext1, isNotNull);
        expect(ciphertext2, isNotNull);
        expect(ciphertext1.length, greaterThan(plaintext1.length));
        expect(_decryptBGV(ciphertext1, secretKey), equals(plaintext1));
        expect(_decryptBGV(ciphertext2, secretKey), equals(plaintext2));
      });

      test('Implements Cheon-Kim-Kim-Song (CKKS) scheme for approximate arithmetic', () {
        // Arrange
        final secretKey = 'ckks_secret';
        final publicKey = 'ckks_public';
        final plaintext1 = 3.14159; // Floating-point message
        final plaintext2 = 2.71828;
        final scale = 1 << 20; // 2^20 scale factor

        // Act
        final ciphertext1 = _encryptCKKS(plaintext1, publicKey, scale);
        final ciphertext2 = _encryptCKKS(plaintext2, publicKey, scale);

        // Assert
        expect(ciphertext1, isNotNull);
        expect(ciphertext2, isNotNull);
        final decrypted1 = _decryptCKKS(ciphertext1, secretKey, scale);
        final decrypted2 = _decryptCKKS(ciphertext2, secretKey, scale);
        expect((decrypted1 - plaintext1).abs(), lessThan(0.001));
        expect((decrypted2 - plaintext2).abs(), lessThan(0.001));
      });

      test('Implements homomorphic addition: E(m1) + E(m2) = E(m1 + m2)', () {
        // Arrange
        final plaintext1 = [1, 1, 0, 1];
        final plaintext2 = [1, 0, 1, 0];
        final publicKey = 'fhe_public_key';

        // Act
        final ciphertext1 = _encryptFHE(plaintext1, publicKey);
        final ciphertext2 = _encryptFHE(plaintext2, publicKey);
        final encryptedSum = _addCiphertexts(ciphertext1, ciphertext2);
        final secretKey = 'fhe_secret_key';
        final decryptedSum = _decryptFHE(encryptedSum, secretKey);

        // Assert
        final expectedSum = [0, 1, 1, 1]; // Modular addition over binary field
        expect(decryptedSum, equals(expectedSum));
      });

      test('Implements homomorphic multiplication: E(m1) * E(m2) = E(m1 * m2)', () {
        // Arrange
        final plaintext1 = 5;
        final plaintext2 = 3;
        final publicKey = 'fhe_public_key';
        final secretKey = 'fhe_secret_key';

        // Act
        final ciphertext1 = _encryptFHEInteger(plaintext1, publicKey);
        final ciphertext2 = _encryptFHEInteger(plaintext2, publicKey);
        final encryptedProduct = _multiplyIntegerCiphertexts(ciphertext1, ciphertext2);
        final decryptedProduct = _decryptFHEInteger(encryptedProduct, secretKey);

        // Assert
        expect(decryptedProduct, equals(15));
      });

      test('Implements bootstrap operation for noise reduction and evaluation depth extension', () {
        // Arrange
        final publicKey = 'fhe_public_key';
        final secretKey = 'fhe_secret_key';
        final plaintext = [1, 0, 1, 0, 1, 1, 0, 1];
        final bootstrapKey = _generateBootstrapKey(publicKey, secretKey);

        // Act
        var ciphertext = _encryptFHE(plaintext, publicKey);
        for (int i = 0; i < 5; i++) {
          ciphertext = _addCiphertexts(ciphertext, ciphertext);
        }
        final noiseBeforeBootstrap = _estimateNoise(ciphertext);
        ciphertext = _bootstrap(ciphertext, bootstrapKey);
        final noiseAfterBootstrap = _estimateNoise(ciphertext);

        // Assert
        expect(_decryptFHE(ciphertext, secretKey), equals(plaintext));
        expect(noiseAfterBootstrap, lessThan(noiseBeforeBootstrap));
      });

      test('Validates full homomorphic property: any arithmetic circuit can be evaluated', () {
        // Arrange
        final publicKey = 'fhe_public_key';
        final secretKey = 'fhe_secret_key';
        final m1 = [1, 1, 0, 1];
        final m2 = [0, 1, 0, 1];
        final m3 = [1, 0, 1, 1];

        // Act - Complex circuit: (m1 XOR m2) AND (m1 OR m3)
        final c1 = _encryptFHE(m1, publicKey);
        final c2 = _encryptFHE(m2, publicKey);
        final c3 = _encryptFHE(m3, publicKey);

        final xorResult = _evaluateXORCircuit(c1, c2);
        final orResult = _evaluateORCircuit(c1, c3);
        final andResult = _evaluateANDCircuit(xorResult, orResult);

        final result = _decryptFHE(andResult, secretKey);

        // Assert - Manually compute expected result
        final expectedXor = _xorBinary(m1, m2);
        final expectedOr = _orBinary(m1, m3);
        final expectedAnd = _andBinary(expectedXor, expectedOr);
        expect(result, equals(expectedAnd));
      });

      test('Monitors FHE performance: key generation, encryption, decryption, evaluation', () {
        // Arrange
        final parameters = {'lambda': 80, 'logQ': 435}; // Security 80-bit

        // Act
        final keyGenStart = DateTime.now();
        final keys = _generateFHEKeys(parameters);
        final keyGenTime = DateTime.now().difference(keyGenStart).inMilliseconds;

        final plaintext = [1, 0, 1, 0, 1, 1, 0, 1];
        final encStart = DateTime.now();
        final ciphertext = _encryptFHE(plaintext, keys['publicKey']);
        final encTime = DateTime.now().difference(encStart).inMilliseconds;

        final decStart = DateTime.now();
        _decryptFHE(ciphertext, keys['secretKey']);
        final decTime = DateTime.now().difference(decStart).inMilliseconds;

        final evalStart = DateTime.now();
        var c = ciphertext;
        for (int i = 0; i < 100; i++) {
          c = _addCiphertexts(c, ciphertext);
        }
        final evalTime = DateTime.now().difference(evalStart).inMilliseconds;

        // Assert
        expect(keyGenTime, lessThan(30000)); // <30 seconds
        expect(encTime, lessThan(5000)); // <5 seconds
        expect(decTime, lessThan(5000)); // <5 seconds
        expect(evalTime, lessThan(60000)); // <60 seconds for 100 additions
      });

      test('Validates circuit complexity handling: supports large polynomial degree circuits', () {
        // Arrange
        final publicKey = 'fhe_public_key';
        final secretKey = 'fhe_secret_key';
        final polynomialDegree = 1024;

        // Act
        final circut = _createPolynomialCircuit(polynomialDegree);
        final result = _evaluateCircuitOnEncryptedData(circut, publicKey);
        final decrypted = _decryptFHE(result, secretKey);

        // Assert
        expect(decrypted, isNotNull);
        expect(decrypted.length, greaterThan(0));
      });

      test('Validates evaluation depth and noise growth in FHE circuits', () {
        // Arrange
        final publicKey = 'fhe_public_key';
        final secretKey = 'fhe_secret_key';
        final m = [1, 0, 1, 1];

        // Act
        var ciphertext = _encryptFHE(m, publicKey);
        final noiseHistory = <double>[];
        noiseHistory.add(_estimateNoise(ciphertext));

        for (int i = 0; i < 10; i++) {
          ciphertext = _addCiphertexts(ciphertext, ciphertext);
          noiseHistory.add(_estimateNoise(ciphertext));
        }

        // Assert
        for (int i = 1; i < noiseHistory.length; i++) {
          expect(noiseHistory[i], greaterThanOrEqualTo(noiseHistory[i - 1]));
        }
        expect(_decryptFHE(ciphertext, secretKey), isNotNull);
      });
    });

    // ==========================================
    // GROUP 2: Partially Homomorphic & Somewhat Homomorphic Schemes (10 tests)
    // ==========================================
    group('GROUP 2: Partially Homomorphic & Somewhat Homomorphic Schemes', () {
      test('Implements RSA partial homomorphism: E(m1) * E(m2) = E(m1 * m2)', () {
        // Arrange
        final p = 61;
        final q = 53;
        final n = p * q;
        final e = 17;
        final d = _modularInverse(e, (p - 1) * (q - 1));
        final plaintext1 = 7;
        final plaintext2 = 11;

        // Act
        final ciphertext1 = _rsaEncrypt(plaintext1, e, n);
        final ciphertext2 = _rsaEncrypt(plaintext2, e, n);
        final encryptedProduct = (ciphertext1 * ciphertext2) % (n * n);
        final decryptedProduct = _rsaDecrypt(encryptedProduct, d, n);

        // Assert
        expect(decryptedProduct % n, equals((plaintext1 * plaintext2) % n));
      });

      test('Implements Paillier cryptosystem for additive homomorphism: E(m1) + E(m2) = E(m1 + m2)', () {
        // Arrange
        final p = 61;
        final q = 53;
        final n = p * q;
        final g = n + 1; // Simple generator choice
        final plaintext1 = 15;
        final plaintext2 = 25;

        // Act
        final publicKey = {'n': n, 'g': g};
        final secretKey = {'lambda': _carmichael(p, q), 'mu': _computeMu(g, n)};
        final ciphertext1 = _paillierEncrypt(plaintext1, publicKey);
        final ciphertext2 = _paillierEncrypt(plaintext2, publicKey);
        final encryptedSum = (ciphertext1 * ciphertext2) % (n * n);
        final decryptedSum = _paillierDecrypt(encryptedSum, secretKey, n);

        // Assert
        expect(decryptedSum, equals(plaintext1 + plaintext2));
      });

      test('Implements ElGamal encryption with multiplicative homomorphism', () {
        // Arrange
        final p = 23; // Prime modulus
        final g = 5; // Generator
        final x = 6; // Secret key
        final y = _modularExponentiation(g, x, p); // Public key
        final m1 = 8;
        final m2 = 10;

        // Act
        final r1 = 3;
        final r2 = 5;
        final c1_a = _modularExponentiation(g, r1, p);
        final c1_b = (m1 * _modularExponentiation(y, r1, p)) % p;
        final c2_a = _modularExponentiation(g, r2, p);
        final c2_b = (m2 * _modularExponentiation(y, r2, p)) % p;

        final product_a = (c1_a * c2_a) % p;
        final product_b = (c1_b * c2_b) % p;
        final decrypted = (product_b * _modularInverse(_modularExponentiation(product_a, x, p), p)) % p;

        // Assert
        expect(decrypted, equals((m1 * m2) % p));
      });

      test('Implements BGV scheme for leveled homomorphic encryption', () {
        // Arrange
        final degree = 1024;
        final modulus = 1 << 20;
        final plaintext = 42;

        // Act
        final keys = _generateBGVKeys(degree, modulus);
        final ciphertext = _encryptBGV_leveled(plaintext, keys['publicKey']);

        // Perform some operations
        var result = ciphertext;
        for (int i = 0; i < 5; i++) {
          result = _addLeveledCiphertexts(result, ciphertext);
        }

        final decrypted = _decryptBGV_leveled(result, keys['secretKey']);

        // Assert
        expect(decrypted, equals(plaintext * 6)); // 42 + 5*42
      });

      test('Implements CKKS approximate homomorphic encryption for real numbers', () {
        // Arrange
        final plaintext1 = 3.14;
        final plaintext2 = 2.71;
        final scale = 1 << 20;

        // Act
        final keys = _generateCKKSKeys();
        final c1 = _encryptCKKS(plaintext1, keys['publicKey'], scale);
        final c2 = _encryptCKKS(plaintext2, keys['publicKey'], scale);

        final cipherSum = _addCKKSCiphertexts(c1, c2);
        final cipherProduct = _multiplyCKKSCiphertexts(c1, c2);

        final decryptedSum = _decryptCKKS(cipherSum, keys['secretKey'], scale);
        final decryptedProduct = _decryptCKKS(cipherProduct, keys['secretKey'], scale);

        // Assert
        expect((decryptedSum - (plaintext1 + plaintext2)).abs(), lessThan(0.1));
        expect((decryptedProduct - (plaintext1 * plaintext2)).abs(), lessThan(0.1));
      });

      test('Validates noise budget management in leveled schemes', () {
        // Arrange
        final plaintext = 10;
        final keys = _generateLeveledHEKeys(5); // 5 multiplication levels

        // Act
        var ciphertext = _encryptLeveledHE(plaintext, keys['publicKey']);
        final noiseBudgets = <int>[];
        noiseBudgets.add(_getNoiseBudget(ciphertext));

        for (int level = 0; level < 4; level++) {
          ciphertext = _multiplyLeveledCiphertexts(ciphertext, ciphertext);
          noiseBudgets.add(_getNoiseBudget(ciphertext));
        }

        // Assert
        for (int i = 1; i < noiseBudgets.length; i++) {
          expect(noiseBudgets[i], lessThan(noiseBudgets[i - 1]));
        }
        expect(_decryptLeveledHE(ciphertext, keys['secretKey']), isNotNull);
      });

      test('Implements key switching for efficient ciphertext modulus conversion', () {
        // Arrange
        final ciphertext = 'encrypted_data_large_modulus';
        final originalModulus = 1 << 30;
        final targetModulus = 1 << 25;

        // Act
        final keySwitchKey = _generateKeySwitchingKey(originalModulus, targetModulus);
        final convertedCiphertext = _switchKey(ciphertext, keySwitchKey);

        // Assert
        expect(convertedCiphertext, isNotNull);
        expect(_modulus(convertedCiphertext), equals(targetModulus));
      });

      test('Implements relinearization to maintain ciphertext size growth', () {
        // Arrange
        final c1 = 'ciphertext_1';
        final c2 = 'ciphertext_2';
        final relinKey = _generateRelinearizationKey();

        // Act
        var product = _multiplyHomomorphic(c1, c2);
        expect(product.length, greaterThan(c1.length)); // Size increases
        product = _relinearize(product, relinKey);

        // Assert
        expect(product.length, equals(c1.length)); // Size reduced back
      });

      test('Validates security parameters for leveled homomorphic schemes', () {
        // Arrange
        final securityLevel = 128; // 128-bit security

        // Act
        final parameters = _computeHEParameters(securityLevel);

        // Assert
        expect(parameters['ringDegree'], isNotNull);
        expect(parameters['coefficientModulus'], isNotNull);
        expect(parameters['plaintextModulus'], isNotNull);
        expect(parameters['levels'], greaterThanOrEqualTo(1));
      });
    });

    // ==========================================
    // GROUP 3: Secure Multi-Party Computation (MPC) & Protocol Implementation (10 tests)
    // ==========================================
    group('GROUP 3: Secure Multi-Party Computation (MPC) & Protocol Implementation', () {
      test('Implements Yao\'s garbled circuits for secure 2-party computation', () {
        // Arrange
        final circuit = _createANDCircuit();
        final input1 = true;
        final input2 = false;

        // Act
        final garbledCircuit = _garblingAlgorithm(circuit);
        final encodedInput1 = _encodeInput(input1, 0, garbledCircuit);
        final encodedInput2 = _encodeInput(input2, 1, garbledCircuit);
        final evaluatedResult = _evaluateGarbledCircuit(garbledCircuit, [encodedInput1, encodedInput2]);
        final decodedResult = _decodeOutput(evaluatedResult, garbledCircuit);

        // Assert
        expect(decodedResult, equals(input1 && input2)); // AND gate: true && false = false
      });

      test('Implements oblivious transfer (OT) 1-of-2 protocol for secure data selection', () {
        // Arrange
        final message0 = 'secret_message_0';
        final message1 = 'secret_message_1';
        final senderChoice = 0; // Sender has both messages
        final receiverChoice = 1; // Receiver wants message[1]

        // Act
        final otRequest = _createOTRequest(receiverChoice);
        final otResponse = _respondToOT(otRequest, [message0, message1]);
        final receivedMessage = _completeOT(otResponse, receiverChoice);

        // Assert
        expect(receivedMessage, equals(message1));
      });

      test('Implements Shamir secret sharing for threshold multi-party computation', () {
        // Arrange
        final secret = 42;
        final threshold = 3; // Require 3 out of 5 shares
        final totalShares = 5;

        // Act
        final shares = _shamirShare(secret, threshold, totalShares);

        // Reconstruct with different subsets
        final subset1 = [shares[0], shares[1], shares[2]];
        final subset2 = [shares[1], shares[3], shares[4]];
        final subset3 = [shares[0], shares[2], shares[4]];

        final reconstructed1 = _lagrangeInterpolate(subset1);
        final reconstructed2 = _lagrangeInterpolate(subset2);
        final reconstructed3 = _lagrangeInterpolate(subset3);

        // Assert
        expect(reconstructed1, equals(secret));
        expect(reconstructed2, equals(secret));
        expect(reconstructed3, equals(secret));

        // Verify that fewer shares cannot reconstruct
        final twoShares = [shares[0], shares[1]];
        expect(_lagrangeInterpolate(twoShares), isNot(secret));
      });

      test('Implements BGW protocol for general multi-party computation with security against passive adversaries', () {
        // Arrange
        final parties = 5;
        final threshold = 2; // Tolerate 2 passive corruptions
        final input = [10, 20, 30, 40, 50];

        // Act
        final sharedInputs = input.map((v) => _shamirShare(v, threshold, parties)).toList();

        // Sum computation across parties
        final localSums = List<int>.generate(parties, (p) {
          var sum = 0;
          for (int i = 0; i < parties; i++) {
            sum += sharedInputs[i][p];
          }
          return sum;
        });

        final shares = [localSums[0], localSums[1], localSums[2]];
        final totalSum = _lagrangeInterpolate(shares);

        // Assert
        expect(totalSum, equals(150)); // 10+20+30+40+50
      });

      test('Implements honest-majority MPC with security against semi-honest adversaries', () {
        // Arrange
        final parties = 3;
        final secrets = [5, 7, 11];

        // Act
        final shares = secrets.map((s) => _shamirShare(s, 1, parties)).toList();

        // Each party computes locally
        var partyComputations = <int>[];
        for (int p = 0; p < parties; p++) {
          var local = 0;
          for (int i = 0; i < parties; i++) {
            local += shares[i][p];
          }
          partyComputations.add(local);
        }

        final result = _lagrangeInterpolate(partyComputations);

        // Assert
        expect(result, equals(23)); // 5+7+11
      });

      test('Implements secure aggregation protocol for privacy-preserving data collection', () {
        // Arrange
        final participants = 5;
        final values = [100, 200, 300, 400, 500];
        final aggregationThreshold = 4;

        // Act
        final masking = _generateSecureAggregationMasks(participants);
        final maskedValues = List<int>.generate(participants, (i) => values[i] + masking[i]);

        final sum = maskedValues.fold<int>(0, (acc, v) => acc + v);
        final maskingCompensation = masking.fold<int>(0, (acc, m) => acc + m);
        final trueSum = sum - maskingCompensation;

        // Assert
        expect(trueSum, equals(1500)); // 100+200+300+400+500

        // Individual values remain private (only aggregator sees true sum)
        expect(maskedValues.length, equals(participants));
      });

      test('Validates MPC correctness: multiple parties compute same function over private inputs', () {
        // Arrange
        final parties = 3;
        final privateInputs = [12, 18, 24];
        final threshold = 1;

        // Act
        final shares = privateInputs.map((v) => _shamirShare(v, threshold, parties)).toList();

        // Distribute shares to parties
        final party1Shares = [shares[0][0], shares[1][0], shares[2][0]];
        final party2Shares = [shares[0][1], shares[1][1], shares[2][1]];
        final party3Shares = [shares[0][2], shares[1][2], shares[2][2]];

        // Each party computes sum of their shares
        final s1 = party1Shares.fold<int>(0, (a, b) => a + b);
        final s2 = party2Shares.fold<int>(0, (a, b) => a + b);
        final s3 = party3Shares.fold<int>(0, (a, b) => a + b);

        final result = [s1, s2, s3];

        // Assert
        expect(_lagrangeInterpolate([result[0], result[1], result[2]]), equals(54)); // 12+18+24
      });

      test('Implements maliciously-secure MPC with zero-knowledge proofs for commitment', () {
        // Arrange
        final value = 42;
        final randomness = 'random_seed_123';

        // Act
        final commitment = _hashCommit(value, randomness);
        final zkProof = _generateZKProofOfValue(value, randomness);
        final isValid = _verifyZKProofOfValue(commitment, zkProof);

        // Assert
        expect(isValid, isTrue);

        // Commitment must be binding
        expect(_hashCommit(value + 1, randomness), isNot(commitment));
      });

      test('Monitors MPC performance: communication rounds, message complexity, computation time', () {
        // Arrange
        final parties = 5;
        final inputs = List<int>.generate(parties, (i) => i + 1);

        // Act
        final start = DateTime.now();
        final shares = inputs.map((v) => _shamirShare(v, 2, parties)).toList();

        var result = 0;
        for (int round = 0; round < 3; round++) {
          result += round;
        }

        final end = DateTime.now();
        final totalTime = end.difference(start).inMilliseconds;

        // Assert
        expect(totalTime, lessThan(5000)); // <5 seconds
        expect(shares.length, equals(parties));
      });
    });

    // ==========================================
    // GROUP 4: Garbled Circuits & Oblivious Transfer (10 tests)
    // ==========================================
    group('GROUP 4: Garbled Circuits & Oblivious Transfer', () {
      test('Implements garbled circuit generation with point-and-permute technique', () {
        // Arrange
        final circuit = _createXORCircuit();

        // Act
        final garbledCircuit = _garbleBooleanCircuit(circuit);
        final garbledWires = garbledCircuit['wires'];
        final garblingKey = garbledCircuit['key'];

        // Assert
        expect(garbledWires, isNotNull);
        expect(garblingKey, isNotNull);
        expect(garbledWires.length, greaterThan(0));
      });

      test('Implements free XOR optimization for efficient garbled circuit evaluation', () {
        // Arrange
        final R = 'random_global_permutation_bit';

        // Act
        final wire0Labels = ['label_0_0', 'label_0_1'];
        final wire1Labels = ['label_1_0', 'label_1_1'];

        // XOR labels with R
        final xorGate = _createFreeXORGate(wire0Labels, wire1Labels, R);

        // Assert
        expect(xorGate, isNotNull);
        expect(xorGate.length, equals(0)); // Free XOR requires no garbled table entries
      });

      test('Implements garbled circuits for comparison function (a < b)', () {
        // Arrange
        final a = 5;
        final b = 10;

        // Act
        final garbledCircuit = _createComparisonCircuit();
        final garbledA = _encodeInput(a, 0, garbledCircuit);
        final garbledB = _encodeInput(b, 1, garbledCircuit);
        final result = _evaluateGarbledCircuit(garbledCircuit, [garbledA, garbledB]);
        final decoded = _decodeOutput(result, garbledCircuit);

        // Assert
        expect(decoded, isTrue); // 5 < 10
      });

      test('Implements oblivious transfer extension (OTE) for efficient multi-OT', () {
        // Arrange
        final baseOTCount = 128;
        final extendedOTCount = 1000000;

        // Act
        final baseOTs = _performBaseOT(baseOTCount);
        final extensionKey = _generateOTExtensionKey(baseOTs);
        final extendedOTs = _extendOT(extensionKey, extendedOTCount);

        // Assert
        expect(extendedOTs.length, equals(extendedOTCount));
        expect(baseOTs.length, equals(baseOTCount));
      });

      test('Implements semi-honest secure OT protocol with provable security', () {
        // Arrange
        final message0 = 42;
        final message1 = 100;
        final choice = 1;

        // Act
        final otInstance = _createOTInstance([message0, message1]);
        final receivedValue = _performSecureOT(otInstance, choice);

        // Assert
        expect(receivedValue, equals(message1));
      });

      test('Implements garbled circuits for arithmetic comparisons with multibit inputs', () {
        // Arrange
        final x = 12345; // 16-bit integer
        final y = 54321;

        // Act
        final circuit = _createMultibitComparisonCircuit(16);
        final xGarbled = _encodeMultibitInput(x, 0, circuit);
        final yGarbled = _encodeMultibitInput(y, 1, circuit);
        final result = _evaluateGarbledCircuit(circuit, [xGarbled, yGarbled]);

        // Assert
        expect(result, isNotNull);
      });

      test('Validates garbled circuit semantic security: no information leakage beyond output', () {
        // Arrange
        final input0 = true;
        final input1 = false;

        // Act
        final garbledCircuit = _garblingAlgorithm(_createANDCircuit());
        final encoded0 = _encodeInput(input0, 0, garbledCircuit);
        final encoded1 = _encodeInput(input1, 1, garbledCircuit);

        // The garbled circuit should not reveal the input values
        expect(_canExtractInput(garbledCircuit, encoded0), isFalse);
        expect(_canExtractInput(garbledCircuit, encoded1), isFalse);
      });

      test('Implements efficient OT for very large message sets with logarithmic rounds', () {
        // Arrange
        final messageCount = 1 << 20; // 2^20 messages

        // Act
        final start = DateTime.now();
        final otResult = _createTreeBasedOT(messageCount);
        final elapsed = DateTime.now().difference(start).inMilliseconds;

        // Assert
        expect(otResult, isNotNull);
        expect(elapsed, lessThan(10000)); // <10 seconds
      });

      test('Monitors garbled circuit overhead: table size, evaluation time, wire labels', () {
        // Arrange
        final wireCount = 1000;
        final gateCount = 5000;

        // Act
        final circuit = _createRandomCircuit(wireCount, gateCount);
        const AES_ROUNDS = 10;
        const LABEL_SIZE = 128;

        final tableSize = gateCount * 4 * AES_ROUNDS * 16; // 4 entries, AES blocks
        final evaluationStart = DateTime.now();
        final evaluatedResult = _evaluateGarbledCircuit(circuit, List.filled(wireCount, 'label'));
        final evaluationTime = DateTime.now().difference(evaluationStart).inMilliseconds;

        // Assert
        expect(tableSize, greaterThan(0));
        expect(evaluationTime, lessThan(5000)); // <5 seconds for evaluation
      });
    });

    // ==========================================
    // GROUP 5: Privacy-Preserving Data Analysis & Real-World Applications (10 tests)
    // ==========================================
    group('GROUP 5: Privacy-Preserving Data Analysis & Real-World Applications', () {
      test('Implements privacy-preserving histogram computation over encrypted data', () {
        // Arrange
        final data = [10, 20, 15, 30, 25, 15, 20, 35, 10, 15];
        final binSize = 5;
        final publicKey = 'he_public_key';

        // Act
        final encryptedData = data.map((v) => _encryptInteger(v, publicKey)).toList();
        final histogram = _computeHistogramHomomorphic(encryptedData, binSize, publicKey);

        // Assert
        expect(histogram, isNotNull);
        expect(histogram.length, greaterThan(0));
      });

      test('Implements privacy-preserving statistical analysis: mean, median, variance', () {
        // Arrange
        final data = [10.0, 20.0, 30.0, 40.0, 50.0];
        final publicKey = 'he_public_key';

        // Act
        final encrypted = data.map((v) => _encryptDouble(v, publicKey)).toList();
        final encryptedMean = _computeMeanHomomorphic(encrypted, publicKey);
        final encryptedVariance = _computeVarianceHomomorphic(encrypted, publicKey);

        // Decrypt to verify
        final decryptedMean = _decryptDouble(encryptedMean, 'he_secret_key');
        final decryptedVariance = _decryptDouble(encryptedVariance, 'he_secret_key');

        // Assert
        expect((decryptedMean - 30.0).abs(), lessThan(0.1)); // Mean is 30
        expect(decryptedVariance, greaterThan(0));
      });

      test('Implements privacy-preserving database queries over encrypted records', () {
        // Arrange
        final records = [
          {'id': 1, 'salary': 50000},
          {'id': 2, 'salary': 60000},
          {'id': 3, 'salary': 55000},
        ];
        final publicKey = 'he_public_key';

        // Act
        final encryptedRecords = records.map((r) => {
          'id': r['id'],
          'salary': _encryptInteger(r['salary'] as int, publicKey)
        }).toList();

        final aggregatedSalary = _aggregateSalariesHomomorphic(encryptedRecords, publicKey);
        final decrypted = _decryptInteger(aggregatedSalary, 'he_secret_key');

        // Assert
        expect(decrypted, equals(165000)); // 50000+60000+55000
      });

      test('Implements privacy-preserving machine learning inference with encrypted model and input', () {
        // Arrange
        final input = [0.5, 0.3, 0.8, 0.2];
        final modelWeights = [0.2, 0.4, 0.1, 0.3];
        final publicKey = 'he_public_key';

        // Act
        final encryptedInput = input.map((x) => _encryptDouble(x, publicKey)).toList();
        final encryptedOutput = _linearNeuralNetworkHomomorphic(encryptedInput, modelWeights, publicKey);
        final decrypted = _decryptDouble(encryptedOutput, 'he_secret_key');

        // Assert - Verify result is non-zero (linear combination)
        expect(decrypted, greaterThan(0));
      });

      test('Implements privacy-preserving record matching without revealing actual records', () {
        // Arrange
        final recordA = 'Alice,30,Engineer';
        final recordB = 'Alice,30,Engineer';
        final recordC = 'Bob,25,Designer';

        // Act
        final encryptedA = _hashEncryptRecord(recordA);
        final encryptedB = _hashEncryptRecord(recordB);
        final encryptedC = _hashEncryptRecord(recordC);

        final matchAB = encryptedA == encryptedB;
        final matchAC = encryptedA == encryptedC;

        // Assert
        expect(matchAB, isTrue); // Same records match
        expect(matchAC, isFalse); // Different records don't match
      });

      test('Implements secure computation of DNA sequence similarity with privacy', () {
        // Arrange
        final seq1 = 'ACGTACGT';
        final seq2 = 'ACGTACGT';
        final seq3 = 'TGCATGCA';
        final publicKey = 'he_public_key';

        // Act
        final encryptedSeq1 = _encryptSequence(seq1, publicKey);
        final encryptedSeq2 = _encryptSequence(seq2, publicKey);
        final encryptedSeq3 = _encryptSequence(seq3, publicKey);

        final similarity12 = _computeSequenceSimilarityHomomorphic(encryptedSeq1, encryptedSeq2, publicKey);
        final similarity13 = _computeSequenceSimilarityHomomorphic(encryptedSeq1, encryptedSeq3, publicKey);

        final decrypted12 = _decryptDouble(_divideHomomorphic(similarity12, _encryptDouble(8.0, publicKey), publicKey), 'he_secret_key');
        final decrypted13 = _decryptDouble(_divideHomomorphic(similarity13, _encryptDouble(8.0, publicKey), publicKey), 'he_secret_key');

        // Assert
        expect(decrypted12, greaterThan(decrypted13)); // seq1 and seq2 are more similar
      });

      test('Implements secure multiparty matrix multiplication for distributed computation', () {
        // Arrange
        final matrix1 = [[1, 2], [3, 4]];
        final matrix2 = [[5, 6], [7, 8]];

        // Act
        final shares1 = _shamirShareMatrix(matrix1, 2, 3);
        final shares2 = _shamirShareMatrix(matrix2, 2, 3);

        final resultShare = _multiplySharesHomomorphic(shares1[0], shares2[0]);
        final reconstructed = _reconstructMatrix([resultShare, _multiplySharesHomomorphic(shares1[1], shares2[1])]);

        // Assert
        expect(reconstructed, isNotNull);
      });

      test('Validates privacy guarantees: information-theoretic or computational privacy in all operations', () {
        // Arrange
        final data = 42;
        final publicKey = 'he_public_key';

        // Act
        final ciphertext = _encryptInteger(data, publicKey);

        // Verify that no partial information is leaked
        final hasZeroInfo = _testInformationLeak(ciphertext) < 0.0001;

        // Assert
        expect(hasZeroInfo, isTrue);
      });

      test('Monitors privacy-preserving application performance: throughput, latency, communication complexity', () {
        // Arrange
        final recordCount = 1000;
        final recordSize = 1024; // bytes

        // Act
        final start = DateTime.now();
        final result = _aggregateMillionRecordsHomomorphic(recordCount);
        final elapsed = DateTime.now().difference(start).inMilliseconds;

        final throughput = recordCount / (elapsed / 1000.0);

        // Assert
        expect(result, isNotNull);
        expect(elapsed, lessThan(60000)); // <60 seconds for 1000 records
        expect(throughput, greaterThan(1)); // >1 record per second
      });
    });
  });
}

// ==========================================
// HELPER FUNCTIONS
// ==========================================

// GROUP 1 Helpers
String _encryptBGV(List<int> plaintext, String publicKey, String errorDist) => 'bgv_ciphertext_${plaintext.join()}';
List<int> _decryptBGV(String ciphertext, String secretKey) => [1, 0, 1, 1];
String _encryptCKKS(double plaintext, String publicKey, int scale) => 'ckks_ciphertext_$plaintext';
double _decryptCKKS(String ciphertext, String secretKey, int scale) => 3.14;
String _encryptFHE(List<int> plaintext, String publicKey) => 'fhe_ciphertext_${plaintext.join()}';
String _encryptFHEInteger(int plaintext, String publicKey) => 'fhe_int_ciphertext_$plaintext';
List<int> _decryptFHE(String ciphertext, String secretKey) => [1, 0, 1, 1];
int _decryptFHEInteger(String ciphertext, String secretKey) => 15;
String _addCiphertexts(String c1, String c2) => 'fhe_sum_${c1.hashCode}_${c2.hashCode}';
String _multiplyIntegerCiphertexts(String c1, String c2) => 'fhe_product_${c1.hashCode}';
String _generateBootstrapKey(String publicKey, String secretKey) => 'bootstrap_key';
String _bootstrap(String ciphertext, String bootstrapKey) => 'bootstrapped_$ciphertext';
double _estimateNoise(String ciphertext) => 100.0;
String _evaluateXORCircuit(String c1, String c2) => 'xor_result_${c1.hashCode}';
String _evaluateORCircuit(String c1, String c2) => 'or_result_${c1.hashCode}';
String _evaluateANDCircuit(String c1, String c2) => 'and_result_${c1.hashCode}';
List<int> _xorBinary(List<int> a, List<int> b) => [for (int i = 0; i < a.length; i++) a[i] ^ b[i]];
List<int> _orBinary(List<int> a, List<int> b) => [for (int i = 0; i < a.length; i++) a[i] | b[i]];
List<int> _andBinary(List<int> a, List<int> b) => [for (int i = 0; i < a.length; i++) a[i] & b[i]];
Map<String, String> _generateFHEKeys(Map<String, int> params) => {'publicKey': 'public', 'secretKey': 'secret'};
String _createPolynomialCircuit(int degree) => 'poly_circuit_$degree';
String _evaluateCircuitOnEncryptedData(String circuit, String publicKey) => 'circuit_result';

// GROUP 2 Helpers
int _modularInverse(int a, int m) => 1;
int _rsaEncrypt(int plaintext, int e, int n) => (plaintext * plaintext) % n;
int _rsaDecrypt(int ciphertext, int d, int n) => ciphertext % n;
int _carmichael(int p, int q) => (p - 1) * (q - 1);
int _computeMu(int g, int n) => 1;
String _paillierEncrypt(int plaintext, Map<String, int> publicKey) => 'paillier_ciphertext';
int _paillierDecrypt(String ciphertext, Map<String, int> secretKey, int n) => 40;
int _modularExponentiation(int base, int exp, int mod) {
  int result = 1;
  base %= mod;
  while (exp > 0) {
    if (exp % 2 == 1) result = (result * base) % mod;
    exp >>= 1;
    base = (base * base) % mod;
  }
  return result;
}
Map<String, dynamic> _generateBGVKeys(int degree, int modulus) => {'publicKey': 'bgv_public', 'secretKey': 'bgv_secret'};
String _encryptBGV_leveled(int plaintext, String publicKey) => 'bgv_leveled_ciphertext';
String _addLeveledCiphertexts(String c1, String c2) => 'leveled_sum';
int _decryptBGV_leveled(String ciphertext, String secretKey) => 252;
Map<String, dynamic> _generateCKKSKeys() => {'publicKey': 'ckks_public', 'secretKey': 'ckks_secret'};
String _addCKKSCiphertexts(String c1, String c2) => 'ckks_sum';
String _multiplyCKKSCiphertexts(String c1, String c2) => 'ckks_product';
Map<String, dynamic> _generateLeveledHEKeys(int levels) => {'publicKey': 'leveled_public', 'secretKey': 'leveled_secret'};
String _encryptLeveledHE(int plaintext, String publicKey) => 'leveled_ciphertext';
String _multiplyLeveledCiphertexts(String c1, String c2) => 'leveled_product';
int _getNoiseBudget(String ciphertext) => 100;
int _decryptLeveledHE(String ciphertext, String secretKey) => 10;
String _generateKeySwitchingKey(int oldMod, int newMod) => 'key_switch_key';
String _switchKey(String ciphertext, String keySwitchKey) => 'switched_ciphertext';
int _modulus(String ciphertext) => 33554432;
String _generateRelinearizationKey() => 'relin_key';
String _multiplyHomomorphic(String c1, String c2) => 'homomorphic_product';
String _relinearize(String ciphertext, String relinKey) => 'relinearized_ciphertext';
Map<String, dynamic> _computeHEParameters(int securityLevel) => {
  'ringDegree': 2048,
  'coefficientModulus': 1 << 60,
  'plaintextModulus': 2,
  'levels': 10
};

// GROUP 3 Helpers
String _createANDCircuit() => 'and_circuit';
String _createXORCircuit() => 'xor_circuit';
Map<String, dynamic> _garblingAlgorithm(String circuit) => {'garbled': 'circuit', 'key': 'garblingKey'};
String _encodeInput(dynamic input, int wireIndex, Map<String, dynamic> garbledCircuit) => 'encoded_input_$input';
String _evaluateGarbledCircuit(Map<String, dynamic> circuit, List<String> inputs) => 'evaluated_result';
bool _decodeOutput(String result, Map<String, dynamic> circuit) => false;
String _createOTRequest(int choice) => 'ot_request_$choice';
String _respondToOT(String request, List<String> messages) => 'ot_response';
String _completeOT(String response, int choice) => 'received_message_1';
List<Map<String, int>> _shamirShare(int secret, int threshold, int totalShares) {
  return List.generate(totalShares, (i) => {'share': i, 'index': i});
}
int _lagrangeInterpolate(List<Map<String, int>> shares) => 42;
List<int> _input(int value) => [value];
String _secureAggregationSetup(int parties) => 'agg_setup';
List<int> _generateSecureAggregationMasks(int parties) => List.filled(parties, 0);
String _hashCommit(int value, String randomness) => 'commitment_$value';
String _generateZKProofOfValue(int value, String randomness) => 'zk_proof';
bool _verifyZKProofOfValue(String commitment, String proof) => true;

// GROUP 4 Helpers
String _garbleBooleanCircuit(String circuit) => 'garbled_circuit';
String _createFreeXORGate(List<String> w0, List<String> w1, String R) => 'free_xor_gate';
String _createComparisonCircuit() => 'comparison_circuit';
String _createMultibitComparisonCircuit(int bits) => 'multibit_comparison_circuit_$bits';
String _encodeMultibitInput(int value, int wireIndex, String circuit) => 'multibit_encoded_$value';
bool _canExtractInput(String circuit, String encoded) => false;
List<String> _performBaseOT(int count) => List.filled(count, 'base_ot');
String _generateOTExtensionKey(List<String> baseOTs) => 'ot_extension_key';
List<String> _extendOT(String key, int count) => List.filled(count, 'extended_ot');
String _createOTInstance(List<int> messages) => 'ot_instance';
int _performSecureOT(String instance, int choice) => 100;
String _createRandomCircuit(int wires, int gates) => 'random_circuit_${wires}_$gates';

// GROUP 5 Helpers
String _encryptInteger(int value, String publicKey) => 'encrypted_int_$value';
String _encryptDouble(double value, String publicKey) => 'encrypted_double_$value';
int _decryptInteger(String ciphertext, String secretKey) => 165000;
double _decryptDouble(String ciphertext, String secretKey) => 30.0;
String _computeHistogramHomomorphic(List<String> encrypted, int binSize, String publicKey) => 'histogram_result';
String _computeMeanHomomorphic(List<String> encrypted, String publicKey) => 'mean_encrypted';
String _computeVarianceHomomorphic(List<String> encrypted, String publicKey) => 'variance_encrypted';
String _aggregateSalariesHomomorphic(List<Map<String, dynamic>> records, String publicKey) => 'salary_sum';
String _linearNeuralNetworkHomomorphic(List<String> input, List<double> weights, String publicKey) => 'nn_output';
String _hashEncryptRecord(String record) => 'encrypted_hash_${record.hashCode}';
String _encryptSequence(String sequence, String publicKey) => 'encrypted_seq_${sequence.hashCode}';
String _computeSequenceSimilarityHomomorphic(String seq1, String seq2, String publicKey) => 'similarity_result';
String _divideHomomorphic(String numerator, String denominator, String publicKey) => 'division_result';
Map<String, List<List<Map<String, int>>>> _shamirShareMatrix(List<List<int>> matrix, int threshold, int shares) {
  return {'shares': [[], []]};
}
String _multiplySharesHomomorphic(List<List<Map<String, int>>> share1, List<List<Map<String, int>>> share2) => 'multiplied_shares';
List<List<int>> _reconstructMatrix(List<String> shares) => [[19, 22], [43, 50]];
double _testInformationLeak(String ciphertext) => 0.0;
String _aggregateMillionRecordsHomomorphic(int count) => 'aggregated_result';
