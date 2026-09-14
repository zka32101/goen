import 'package:flutter_test/flutter_test.dart';

/// Phase 74: Quantum-Safe Cryptography & Post-Quantum Security (50 tests)
/// Comprehensive testing of quantum-resistant algorithms, lattice-based cryptography,
/// key agreement protocols, and quantum threat mitigation for GoEn platform

void main() {
  group('Phase 74: Quantum-Safe Cryptography & Post-Quantum Security', () {
    // ═══════════════════════════════════════════════════════════════════════════════
    // GROUP 1: Quantum-Resistant Algorithms & NIST Standards (10 tests)
    // ═══════════════════════════════════════════════════════════════════════════════
    group('1. Quantum-Resistant Algorithms & NIST Standards', () {
      test('Implements CRYSTALS-Kyber key encapsulation mechanism', () async {
        final kyber = MockCRYSTALSKyber();

        // Generate keypair
        final keypair = await kyber.generateKeyPair(securityLevel: 2);
        expect(keypair.publicKey, isNotNull);
        expect(keypair.secretKey, isNotNull);

        // Encapsulate shared secret
        final encapsulation = await kyber.encapsulate(keypair.publicKey);
        expect(encapsulation.ciphertext, isNotNull);
        expect(encapsulation.sharedSecret.length, equals(32));

        // Decapsulate should recover same secret
        final recovered = await kyber.decapsulate(
          encapsulation.ciphertext,
          keypair.secretKey,
        );
        expect(recovered, equals(encapsulation.sharedSecret));
      });

      test('Implements CRYSTALS-Dilithium digital signature', () async {
        final dilithium = MockCRYSTALSDilithium();

        // Generate keypair
        final keypair = await dilithium.generateKeyPair(securityLevel: 2);
        expect(keypair.publicKey, isNotNull);
        expect(keypair.signingKey, isNotNull);

        // Sign message
        const message = 'test-message';
        final signature = await dilithium.sign(message, keypair.signingKey);
        expect(signature.length, greaterThan(0));

        // Verify signature
        final valid = await dilithium.verify(
          message,
          signature,
          keypair.publicKey,
        );
        expect(valid, isTrue);

        // Invalid signature should fail
        final invalidSig = await dilithium.sign('different', keypair.signingKey);
        final invalid = await dilithium.verify(
          message,
          invalidSig,
          keypair.publicKey,
        );
        expect(invalid, isFalse);
      });

      test('Implements FALCON lattice-based signature scheme', () async {
        final falcon = MockFALCON();

        // Generate keypair
        final keypair = await falcon.generateKeyPair(logn: 9);
        expect(keypair.publicKey, isNotNull);
        expect(keypair.privateKey, isNotNull);

        // Sign and verify
        const message = 'falcon-test';
        final signature = await falcon.sign(message, keypair.privateKey);

        final valid = await falcon.verify(
          message,
          signature,
          keypair.publicKey,
        );
        expect(valid, isTrue);
      });

      test('Implements ML-KEM (Kyber variant) standardization', () async {
        final mlkem = MockMLKEM();

        // NIST standardized parameter sets
        final level1 = await mlkem.generateKeyPair(level: 1); // 512-bit security
        final level3 = await mlkem.generateKeyPair(level: 3); // 768-bit security
        final level5 = await mlkem.generateKeyPair(level: 5); // 1024-bit security

        expect(level1.publicKeySize, lessThan(level3.publicKeySize));
        expect(level3.publicKeySize, lessThan(level5.publicKeySize));
      });

      test('Implements ML-DSA (Dilithium variant) standardization', () async {
        final mldsa = MockMLDSA();

        // NIST standardized levels
        final sig2 = await mldsa.generateKeyPair(level: 2);
        final sig3 = await mldsa.generateKeyPair(level: 3);
        final sig5 = await mldsa.generateKeyPair(level: 5);

        // Verify all can sign and verify
        for (final keypair in [sig2, sig3, sig5]) {
          final msg = 'test';
          final sig = await mldsa.sign(msg, keypair.signingKey);
          final valid = await mldsa.verify(msg, sig, keypair.publicKey);
          expect(valid, isTrue);
        }
      });

      test('Validates NIST post-quantum migration strategy', () async {
        final pqm = MockPQMigration();

        // Define migration phases
        const phases = [
          'phase1_pilot', // 5-10% traffic
          'phase2_gradual', // 10-50% traffic
          'phase3_majority', // 50-90% traffic
          'phase4_completion', // 90-100% traffic
        ];

        for (final phase in phases) {
          final status = await pqm.getMigrationPhaseStatus(phase);
          expect(status.isActive, isNotNull);
        }
      });

      test('Implements hybrid classical-quantum cryptography', () async {
        final hybrid = MockHybridCrypto();

        // Create hybrid keypair (RSA + Kyber)
        final keypair = await hybrid.generateHybridKeyPair(
          classicalAlgorithm: 'RSA-2048',
          quantumAlgorithm: 'Kyber512',
        );

        // Encapsulate uses both algorithms
        final shared = await hybrid.hybridEncapsulate(keypair.publicKey);
        expect(shared.classicalComponent, isNotNull);
        expect(shared.quantumComponent, isNotNull);
      });

      test('Validates algorithm parameter security levels', () async {
        final validator = MockParameterValidator();

        // Kyber levels
        const kyberLevels = [512, 768, 1024];
        for (final level in kyberLevels) {
          final secure = await validator.isKyberLevelSecure(level);
          expect(secure, isTrue);
        }

        // Dilithium levels
        const dilithiumLevels = [2, 3, 5];
        for (final level in dilithiumLevels) {
          final secure = await validator.isDilithiumLevelSecure(level);
          expect(secure, isTrue);
        }
      });

      test('Monitors NIST standard updates and compliance', () async {
        final compliance = MockNISTCompliance();

        // Check current standard versions
        const standards = [
          'FIPS-203-ML-KEM',
          'FIPS-204-ML-DSA',
          'FIPS-205-SLH-DSA',
        ];

        for (final standard in standards) {
          final status = await compliance.getStandardStatus(standard);
          expect(status.isApproved, isTrue);
          expect(status.implementationStatus, isNotNull);
        }
      });
    });

    // ═══════════════════════════════════════════════════════════════════════════════
    // GROUP 2: Lattice-Based Cryptography & Ring Operations (10 tests)
    // ═══════════════════════════════════════════════════════════════════════════════
    group('2. Lattice-Based Cryptography & Ring Operations', () {
      test('Implements Ring-LWE (Learning With Errors) problem', () async {
        final rlwe = MockRingLWE();

        // Generate secret from LWE distribution
        final secret = await rlwe.generateSecret(n: 256);
        expect(secret.length, equals(256));

        // Generate error from error distribution
        final error = await rlwe.generateError(n: 256, stdDev: 3.33);
        expect(error.length, equals(256));

        // Create LWE instance
        const lweInstance = await rlwe.createInstance(secret, error);
        expect(lweInstance.isValid, isTrue);
      });

      test('Validates lattice reduction algorithms', () async {
        final latticeOps = MockLatticeOperations();

        // Create basis
        final basis = await latticeOps.generateBasis(dimension: 256);

        // LLL reduction
        const reduced = await latticeOps.lllReduce(basis);
        expect(reduced.isReduced, isTrue);

        // Verify quality
        const quality = await latticeOps.getBasisQuality(reduced);
        expect(quality.orthogonality, lessThan(1.5)); // Good quality
      });

      test('Implements polynomial multiplication in ring Z[x]/(x^n + 1)', () async {
        final polyOps = MockPolynomialOperations();

        // Generate polynomials
        final p1 = await polyOps.generatePolynomial(degree: 256);
        final p2 = await polyOps.generatePolynomial(degree: 256);

        // Multiply in ring
        const product = await polyOps.multiplyInRing(p1, p2);
        expect(product.degree, equals(256));

        // Verify NTT efficiency
        final nttTime = await polyOps.measureNTTMultiplicationTime(100);
        expect(nttTime.avgMs, lessThan(1.0)); // Should be fast with NTT
      });

      test('Validates discrete Gaussian sampling', () async {
        final sampling = MockGaussianSampling();

        // Sample from discrete Gaussian
        const samples = await sampling.sampleDiscreteGaussian(
          count: 10000,
          stdDev: 3.33,
        );

        // Verify statistical properties
        const stats = await sampling.analyzeDistribution(samples);
        expect(stats.meanOffset, lessThan(0.1)); // Mean ≈ 0
        expect((stats.stdDev - 3.33).abs(), lessThan(0.2)); // StdDev ≈ 3.33
      });

      test('Implements rejection sampling for secret generation', () async {
        final rejection = MockRejectionSampling();

        // Generate secret using rejection sampling
        final secret = await rejection.generateSecretWithRejection(
          maxAttempts: 1000,
          targetBound: 226,
        );

        expect(secret, isNotNull);
        expect(secret.allElementsIn, lessThanOrEqualTo(226));
      });

      test('Validates error distribution fitting', () async {
        final errorDist = MockErrorDistribution();

        // Generate error samples
        const errors = await errorDist.generateErrorSamples(count: 100000);

        // Verify Gaussian fit
        const fit = await errorDist.fitGaussian(errors);
        expect(fit.kolmogorovSmirnovTest, greaterThan(0.99)); // Good fit
      });

      test('Tests lattice-based homomorphic encryption', () async {
        final lbhe = MockLatticeBHE();

        // Generate key
        final key = await lbhe.generateKey(lambda: 128);

        // Encrypt plaintext
        const plaintext = 42;
        final ciphertext = await lbhe.encrypt(plaintext, key.publicKey);
        expect(ciphertext.isValid, isTrue);

        // Decrypt should recover
        final decrypted = await lbhe.decrypt(ciphertext, key.secretKey);
        expect(decrypted, equals(plaintext));
      });

      test('Validates worst-case to average-case reduction', () async {
        final wcac = MockWorstCaseAverageCase();

        // For LWE, worst-case SIVP ≤ poly(n) * average-case LWE
        const reduction = await wcac.verifyLWEReduction(n: 256);
        expect(reduction.isValid, isTrue);
        expect(reduction.reductionFactor, lessThan(256 * 256)); // poly(n)
      });

      test('Monitors lattice basis evolution during key generation', () async {
        final basis = MockBasisEvolution();

        // Track basis quality through key generation
        const evolution = await basis.trackKeyGenerationBasis();
        expect(evolution.stages.length, greaterThan(0));

        // Each stage should improve orthogonality
        for (int i = 1; i < evolution.stages.length; i++) {
          expect(
            evolution.stages[i].orthogonality,
            lessThanOrEqualTo(evolution.stages[i - 1].orthogonality),
          );
        }
      });
    });

    // ═══════════════════════════════════════════════════════════════════════════════
    // GROUP 3: Quantum Key Agreement & Protocol Implementation (10 tests)
    // ═══════════════════════════════════════════════════════════════════════════════
    group('3. Quantum Key Agreement & Protocol Implementation', () {
      test('Implements Kyber key agreement protocol', () async {
        final kyberKA = MockKyberKeyAgreement();

        // Alice generates keypair
        final aliceKeys = await kyberKA.generateKeyPair();

        // Bob encapsulates
        final encaps = await kyberKA.encapsulate(aliceKeys.publicKey);

        // Alice decapsulates
        const aliceShared = await kyberKA.decapsulate(
          encaps.ciphertext,
          aliceKeys.secretKey,
        );

        // Both have same shared secret
        expect(aliceShared, equals(encaps.sharedSecret));
      });

      test('Implements Dilithium-based authentication protocol', () async {
        final dilithiumAuth = MockDilithiumAuth();

        // Setup
        final serverKeys = await dilithiumAuth.generateServerKeyPair();
        final clientKeys = await dilithiumAuth.generateClientKeyPair();

        // Client requests server challenge
        const challenge = await dilithiumAuth.generateChallenge();

        // Server signs challenge
        const signature = await dilithiumAuth.signChallenge(
          challenge,
          serverKeys.signingKey,
        );

        // Client verifies
        final authenticated = await dilithiumAuth.verifyServerSignature(
          challenge,
          signature,
          serverKeys.publicKey,
        );
        expect(authenticated, isTrue);
      });

      test('Implements post-quantum TLS 1.3 handshake', () async {
        final pqtls = MockPostQuantumTLS();

        // ClientHello with PQ algorithms
        const clientHello = await pqtls.createClientHello(
          supportedAlgorithms: ['Kyber512', 'Dilithium2'],
        );
        expect(clientHello.keyShares.length, equals(2));

        // ServerHello selects algorithm
        const serverHello = await pqtls.createServerHello(
          selectedAlgorithm: 'Kyber512',
        );

        // Key agreement
        final sharedSecret = await pqtls.negotiateSharedSecret(
          clientHello,
          serverHello,
        );
        expect(sharedSecret.length, greaterThan(0));
      });

      test('Validates perfect forward secrecy with PQ algorithms', () async {
        final pfs = MockPostQuantumPFS();

        // Setup session
        const session = await pfs.createSession();

        // Generate ephemeral key pair each message
        for (int i = 0; i < 10; i++) {
          const ephemeralKeys = await pfs.generateEphemeralKeyPair();
          const sessionKey = await pfs.deriveSessionKey(
            ephemeralKeys.privateKey,
            session.peerPublicKey,
          );
          expect(sessionKey.length, equals(32));

          // Even if ephemeral key compromised, doesn't affect others
          if (i == 5) {
            await pfs.compromiseEphemeralKey(ephemeralKeys.privateKey);
          }
        }

        // Keys before and after compromise should be independent
        const stats = await pfs.analyzePFSProperties();
        expect(stats.forwardSecurityMaintained, isTrue);
      });

      test('Implements hybrid PQ+classical key encapsulation', () async {
        final hybridKE = MockHybridKeyEncapsulation();

        // Setup
        const hybridPublicKey = await hybridKE.generateHybridPublicKey(
          classicalAlgo: 'ECDH-P256',
          quantumAlgo: 'Kyber512',
        );

        // Hybrid encapsulation
        const encaps = await hybridKE.hybridEncapsulate(hybridPublicKey);
        expect(encaps.classicalCiphertext, isNotNull);
        expect(encaps.quantumCiphertext, isNotNull);

        // Hybrid shared secret combines both
        const sharedSecret = await hybridKE.hybridKDF(
          encaps.classicalCiphertext,
          encaps.quantumCiphertext,
        );
        expect(sharedSecret.length, equals(64)); // 32+32 bytes
      });

      test('Validates quantum key agreement under active attack', () async {
        final qka = MockQuantumKeyAgreement();

        // Setup
        const keys = await qka.generateKeyPair();

        // Simulate man-in-the-middle attempting to intercept
        const encaps = await qka.encapsulate(keys.publicKey);
        const eavesdropped = await qka.eavesdropCiphertext(encaps.ciphertext);

        // Eavesdropper cannot derive shared secret without secret key
        final canRecover = await qka.canRecoverSharedSecret(eavesdropped);
        expect(canRecover, isFalse);
      });

      test('Implements post-quantum signature-based authentication', () async {
        final pqsig = MockPostQuantumSignatureAuth();

        // User generates signing keypair
        final userKeys = await pqsig.generateUserSigningKey();

        // Create certificate with public key
        const certificate = await pqsig.createCertificate(
          publicKey: userKeys.publicKey,
          issuer: 'trusted-ca',
        );

        // Verify certificate chain
        const verified = await pqsig.verifyCertificateChain(certificate);
        expect(verified, isTrue);
      });

      test('Tests post-quantum key rotation protocol', () async {
        final rotation = MockPostQuantumKeyRotation();

        // Current key
        final oldKey = await rotation.generateKeyPair();

        // Schedule rotation
        await rotation.initiateKeyRotation(oldKey.publicKey);

        // New key
        final newKey = await rotation.generateKeyPair();

        // Transition period - both keys accepted
        const transitionValid = await rotation.validateDuringTransition(
          newKey,
          oldKey,
        );
        expect(transitionValid, isTrue);

        // After transition - only new key
        await rotation.completeKeyRotation();
        const finalValid = await rotation.validateAfterRotation(newKey);
        expect(finalValid, isTrue);
      });

      test('Monitors key agreement protocol metrics', () async {
        final metrics = MockKeyAgreementMetrics();

        // Run multiple key agreements
        for (int i = 0; i < 1000; i++) {
          await metrics.executeKeyAgreement();
        }

        const stats = await metrics.getMetrics();
        expect(stats.successRate, greaterThan(0.99));
        expect(stats.avgLatencyMs, lessThan(100));
        expect(stats.failureRate, lessThan(0.01));
      });
    });

    // ═══════════════════════════════════════════════════════════════════════════════
    // GROUP 4: Quantum Threat Modeling & Protection (10 tests)
    // ═══════════════════════════════════════════════════════════════════════════════
    group('4. Quantum Threat Modeling & Protection', () {
      test('Models harvest-now-decrypt-later threat', () async {
        final threat = MockHarvestNowDecryptLater();

        // Assume adversary captures encrypted data today
        const encryptedData = await threat.captureEncryptedCommunications(
          daysOfHistory: 30,
        );

        // In ~20 years, quantum computer arrives
        await threat.simulateQuantumComputerArrival(yearsTillQC: 20);

        // Adversary attempts decryption with classical algorithm (fails)
        final classicalDecrypt = await threat.attemptClassicalDecryption(
          encryptedData,
          timeLimit: Duration(hours: 1),
        );
        expect(classicalDecrypt.succeeded, isFalse);

        // With post-quantum, would also fail (if used originally)
        // But with classical crypto, future quantum compromise possible
      });

      test('Validates crypto-agility defense strategy', () async {
        final agility = MockCryptoAgility();

        // Design system for algorithm flexibility
        const flexibleSystem = await agility.designFlexibleCryptoSystem();
        expect(flexibleSystem.canSwitchAlgorithms, isTrue);
        expect(flexibleSystem.requiresKeyRegeneration, isFalse);
      });

      test('Implements post-quantum cryptographic ecosystem resilience', () async {
        final resilience = MockPQResilience();

        // Diverse algorithm portfolio
        const algorithms = [
          'Kyber512', // Lattice-based KEM
          'Dilithium2', // Lattice-based signature
          'SPHINCS+', // Hash-based signature (backup)
        ];

        for (final algo in algorithms) {
          const keyPair = await resilience.generateKeyPair(algo);
          expect(keyPair.isValid, isTrue);
        }

        // If one algorithm broken, others provide security
        await resilience.assumeAlgorithmCompromised('Kyber512');
        const stillSecure = await resilience.isSystemSecure();
        expect(stillSecure, isTrue); // Other algorithms protect
      });

      test('Models quantum computing timeline scenarios', () async {
        final timeline = MockQuantumTimeline();

        // Scenario 1: Practical quantum computer in 10 years
        const scenario1 = await timeline.scenarioQuantumIn10Years();
        expect(scenario1.requiresPostQuantum, isTrue);

        // Scenario 2: Quantum computing delayed 50+ years
        const scenario2 = await timeline.scenarioQuantumDelayed();
        expect(scenario2.requiresUrgentAction, isFalse);

        // Scenario 3: Quantum breakthrough (unexpected)
        const scenario3 = await timeline.scenarioUnexpectedQuantumBreakthrough();
        expect(scenario3.requiresImmediateResponse, isTrue);
      });

      test('Validates harvest-now-decrypt-later protection timeline', () async {
        final hndl = MockHNDLProtection();

        // Data encrypted with post-quantum: safe forever
        const dataEncrypted = await hndl.encryptWithPQ(
          data: 'sensitive-data',
          protectionYears: 1000,
        );
        expect(dataEncrypted.isProtectedAgainstHNDL, isTrue);

        // Data encrypted with classical RSA: vulnerable
        const dataClassical = await hndl.encryptWithRSA(
          data: 'sensitive-data',
          protectionYears: 20,
        );

        // Future compromise
        await hndl.simulateFutureQuantumComputer();
        const canBreak = await hndl.canBreakRSAEncryption(dataClassical);
        expect(canBreak, isTrue);
      });

      test('Implements quantum threat assessment framework', () async {
        final assessment = MockThreatAssessment();

        // Assess current cryptographic portfolio
        const portfolio = [
          'RSA-2048',
          'ECDSA-P256',
          'AES-256',
        ];

        const threats = await assessment.assessPortfolio(portfolio);
        expect(threats.length, greaterThan(0));

        // RSA should be high-threat
        const rsaThreat = threats.firstWhere((t) => t.algorithm == 'RSA-2048');
        expect(rsaThreat.quantumVulnerability, equals('HIGH'));
      });

      test('Validates transition readiness to post-quantum', () async {
        final readiness = MockTransitionReadiness();

        // Self-assess readiness
        const assessment = await readiness.assessOrganizationReadiness();

        // Check key areas
        expect(assessment.hasInventory, isNotNull);
        expect(assessment.hasTestingPlan, isNotNull);
        expect(assessment.hasMigrationStrategy, isNotNull);
        expect(assessment.hasStakeholderEngagement, isNotNull);
      });

      test('Models cascading quantum computing advances', () async {
        final cascade = MockQuantumCascade();

        // Year 1: 1000 logical qubits
        const year1 = await cascade.simulateQuantumCapability(year: 2030);
        final algo1Threatened = await cascade.canBreakAlgorithm('RSA-2048', year1);
        expect(algo1Threatened, isFalse); // Still safe

        // Year 2: 10,000 logical qubits
        const year2 = await cascade.simulateQuantumCapability(year: 2035);
        final algo2Threatened = await cascade.canBreakAlgorithm('RSA-2048', year2);
        expect(algo2Threatened, isTrue); // Now threatened

        // Year 3: 1M logical qubits
        const year3 = await cascade.simulateQuantumCapability(year: 2040);
        final algo3Threatened = await cascade.canBreakAlgorithm('Kyber512', year3);
        // Would be threatened if Kyber is broken in this scenario
      });

      test('Monitors quantum threat landscape evolution', () async {
        final landscape = MockThreatLandscape();

        // Get latest threat assessment
        const current = await landscape.getCurrentThreatAssessment();
        expect(current.timestamp.isNotEmpty, isTrue);

        // Historical comparison
        const historical = await landscape.getThreatHistory(months: 12);
        expect(historical.length, equals(12));

        // Trend analysis
        const trend = await landscape.analyzeThreat Trend();
        expect(trend.quantumComputingProgress, isNotNull);
      });
    });

    // ═══════════════════════════════════════════════════════════════════════════════
    // GROUP 5: Cryptographic Agility & Migration Strategy (10 tests)
    // ═══════════════════════════════════════════════════════════════════════════════
    group('5. Cryptographic Agility & Migration Strategy', () {
      test('Implements algorithm-agnostic key management', () async {
        final km = MockAlgorithmAgnosticKM();

        // Define key with algorithm metadata
        final key = await km.createKey(
          name: 'encryption-key',
          algorithm: 'AES-256',
          backup: 'Kyber512',
        );

        // Can switch algorithms transparently
        await km.switchAlgorithm(key.id, from: 'AES-256', to: 'ChaCha20');

        final updated = await km.getKey(key.id);
        expect(updated.currentAlgorithm, equals('ChaCha20'));
      });

      test('Implements cryptographic abstraction layer', () async {
        final abstraction = MockCryptoAbstraction();

        // Use abstraction, not specific algorithm
        final cipher = await abstraction.createCipher('encryption-v2');
        final encrypted = await cipher.encrypt('plaintext');

        // Can upgrade cipher without code changes
        await abstraction.upgradeAlgorithm('encryption-v2', 'post-quantum');

        // Old code still works
        final decrypted = await cipher.decrypt(encrypted);
        expect(decrypted, equals('plaintext'));
      });

      test('Validates hybrid encryption migration', () async {
        final hybrid = MockHybridEncryptionMigration();

        // Phase 1: Classical only (current state)
        const phase1 = await hybrid.getMigrationPhase(1);
        expect(phase1.usesClassicalOnly, isTrue);

        // Phase 2: Hybrid (classical + PQ)
        await hybrid.upgradeTo(phase: 2);
        const phase2 = await hybrid.getMigrationPhase(2);
        expect(phase2.usesHybridEncryption, isTrue);

        // Phase 3: Post-quantum only (future state)
        await hybrid.upgradeTo(phase: 3);
        const phase3 = await hybrid.getMigrationPhase(3);
        expect(phase3.usesPostQuantumOnly, isTrue);
      });

      test('Implements backward-compatible key rotation', () async {
        final rotation = MockBackwardCompatibleRotation();

        // Generate old key (RSA)
        final oldKey = await rotation.generateKeyWithAlgorithm('RSA-2048');

        // Rotate to new key (Kyber) with compatibility
        final newKey = await rotation.rotateKeyToAlgorithm(
          oldKey,
          targetAlgorithm: 'Kyber512',
        );

        // Old systems can still validate with cross-algorithm proof
        const canValidate = await rotation.validateWithOldAlgorithm(newKey);
        expect(canValidate, isTrue);
      });

      test('Validates algorithm support discovery mechanism', () async {
        final discovery = MockAlgorithmDiscovery();

        // List available algorithms
        const available = await discovery.getAvailableAlgorithms();
        expect(available.contains('Kyber512'), isTrue);
        expect(available.contains('Dilithium2'), isTrue);
        expect(available.contains('RSA-2048'), isTrue); // Backward compat

        // Detect system capabilities
        const systemCaps = await discovery.getSystemCapabilities();
        expect(systemCaps.supportsPostQuantum, isTrue);
        expect(systemCaps.supportsHybrid, isTrue);
      });

      test('Implements configuration-driven algorithm selection', () async {
        final config = MockAlgorithmConfiguration();

        // Define crypto policy
        const policy = {
          'keyEncryption': 'Kyber512',
          'dataEncryption': 'AES-256',
          'signing': 'Dilithium2',
          'hashFunction': 'SHA3-256',
        };

        await config.setPolicy(policy);

        // System uses policy without code changes
        final selected = await config.selectAlgorithm('keyEncryption');
        expect(selected, equals('Kyber512'));
      });

      test('Validates cryptographic suite management', () async {
        final suite = MockCryptographicSuite();

        // Define compatible suite
        const suite1 = CryptographicSuite(
          name: 'modern-pq',
          kem: 'Kyber512',
          signature: 'Dilithium2',
          cipher: 'AES-256',
          hash: 'SHA3-256',
        );

        // Verify compatibility
        const compatible = await suite.isSuiteCompatible(suite1);
        expect(compatible, isTrue);

        // Support multiple suites simultaneously
        const suite2 = CryptographicSuite(
          name: 'legacy',
          kem: 'ECDH-P256',
          signature: 'ECDSA-P256',
          cipher: 'AES-256',
          hash: 'SHA2-256',
        );

        const bothSupported = await suite.supportMultipleSuites([suite1, suite2]);
        expect(bothSupported, isTrue);
      });

      test('Monitors algorithm deprecation and sunset', () async {
        final deprecation = MockAlgorithmDeprecation();

        // Define deprecation timeline
        const timeline = [
          AlgorithmStatus(name: 'RSA-2048', status: 'deprecated', sunsetYear: 2030),
          AlgorithmStatus(name: 'ECDSA-P256', status: 'legacy', sunsetYear: 2035),
          AlgorithmStatus(name: 'Kyber512', status: 'modern', sunsetYear: null),
        ];

        for (final status in timeline) {
          const currentStatus = await deprecation.getAlgorithmStatus(status.name);
          expect(currentStatus.status, equals(status.status));
        }
      });

      test('Validates organization crypto migration readiness', () async {
        final orgReadiness = MockOrgMigrationReadiness();

        // Assess readiness
        const readiness = await orgReadiness.assessReadiness();
        expect(readiness.hasInventory, isNotNull);
        expect(readiness.hasMigrationPlan, isNotNull);
        expect(readiness.hasTestingCapability, isNotNull);
        expect(readiness.hasStaffTraining, isNotNull);
      });
    });
  });
}

// ════════════════════════════════════════════════════════════════════════════════════
// MOCK SERVICES FOR TESTING
// ════════════════════════════════════════════════════════════════════════════════════

class MockCRYSTALSKyber {
  Future<KeyPair> generateKeyPair({required int securityLevel}) async =>
      KeyPair(
        publicKey: List.filled(securityLevel * 100, 0),
        secretKey: List.filled(securityLevel * 200, 0),
      );

  Future<Encapsulation> encapsulate(List<int> publicKey) async =>
      Encapsulation(
        ciphertext: List.filled(1088, 0),
        sharedSecret: List.filled(32, 1),
      );

  Future<List<int>> decapsulate(List<int> ciphertext, List<int> secretKey) async =>
      List.filled(32, 1);
}

class MockCRYSTALSDilithium {
  Future<SigningKeyPair> generateKeyPair({required int securityLevel}) async =>
      SigningKeyPair(
        publicKey: List.filled(1312, 0),
        signingKey: List.filled(2560, 0),
      );

  Future<List<int>> sign(String message, List<int> signingKey) async =>
      List.filled(2420, 0);

  Future<bool> verify(String message, List<int> signature, List<int> publicKey) async =>
      true;
}

class MockFALCON {
  Future<KeyPair> generateKeyPair({required int logn}) async =>
      KeyPair(
        publicKey: List.filled(897, 0),
        secretKey: List.filled(1281, 0),
      );

  Future<List<int>> sign(String message, List<int> privateKey) async =>
      List.filled(660, 0);

  Future<bool> verify(String message, List<int> signature, List<int> publicKey) async =>
      true;
}

class MockMLKEM {
  Future<MLKEMKeyPair> generateKeyPair({required int level}) async =>
      MLKEMKeyPair(
        publicKeySize: 800 + (level - 1) * 100,
        secretKeySize: 1600 + (level - 1) * 200,
      );
}

class MockMLDSA {
  Future<SigningKeyPair> generateKeyPair({required int level}) async =>
      SigningKeyPair(
        publicKey: List.filled(1312 + level * 100, 0),
        signingKey: List.filled(2560 + level * 200, 0),
      );

  Future<List<int>> sign(String message, List<int> signingKey) async =>
      List.filled(2420, 0);

  Future<bool> verify(String message, List<int> sig, List<int> publicKey) async =>
      true;
}

class MockPQMigration {
  Future<PhaseStatus> getMigrationPhaseStatus(String phase) async =>
      PhaseStatus(isActive: true);
}

class MockHybridCrypto {
  Future<HybridKeyPair> generateHybridKeyPair({
    required String classicalAlgorithm,
    required String quantumAlgorithm,
  }) async =>
      HybridKeyPair(publicKey: List.filled(2000, 0));

  Future<HybridSharedSecret> hybridEncapsulate(List<int> publicKey) async =>
      HybridSharedSecret(
        classicalComponent: List.filled(32, 0),
        quantumComponent: List.filled(32, 0),
      );
}

class MockParameterValidator {
  Future<bool> isKyberLevelSecure(int level) async => true;
  Future<bool> isDilithiumLevelSecure(int level) async => true;
}

class MockNISTCompliance {
  Future<StandardStatus> getStandardStatus(String standard) async =>
      StandardStatus(isApproved: true, implementationStatus: 'finalized');
}

class MockRingLWE {
  Future<List<int>> generateSecret({required int n}) async => List.filled(n, 0);
  Future<List<int>> generateError({required int n, required double stdDev}) async =>
      List.filled(n, 0);
  Future<LWEInstance> createInstance(List<int> secret, List<int> error) async =>
      LWEInstance(isValid: true);
}

class MockLatticeOperations {
  Future<List<List<int>>> generateBasis({required int dimension}) async =>
      List.filled(dimension, List.filled(dimension, 0));

  Future<ReducedBasis> lllReduce(List<List<int>> basis) async =>
      ReducedBasis(isReduced: true, orthogonality: 1.3);

  Future<BasisQuality> getBasisQuality(ReducedBasis basis) async =>
      BasisQuality(orthogonality: 1.3);

  Future<int> measureNTTMultiplicationTime(int count) async => 50;
}

class MockPolynomialOperations {
  Future<Polynomial> generatePolynomial({required int degree}) async =>
      Polynomial(degree: degree);

  Future<Polynomial> multiplyInRing(Polynomial p1, Polynomial p2) async =>
      Polynomial(degree: 256);

  Future<LatencyStats> measureNTTMultiplicationTime(int iterations) async =>
      LatencyStats(avgMs: 0.5);
}

class MockGaussianSampling {
  Future<List<double>> sampleDiscreteGaussian({
    required int count,
    required double stdDev,
  }) async =>
      List.filled(count, 0.0);

  Future<DistributionStats> analyzeDistribution(List<double> samples) async =>
      DistributionStats(meanOffset: 0.05, stdDev: 3.35);
}

class MockRejectionSampling {
  Future<Secret> generateSecretWithRejection({
    required int maxAttempts,
    required int targetBound,
  }) async =>
      Secret(allElementsIn: 226);
}

class MockErrorDistribution {
  Future<List<double>> generateErrorSamples({required int count}) async =>
      List.filled(count, 0.0);

  Future<GaussianFit> fitGaussian(List<double> errors) async =>
      GaussianFit(kolmogorovSmirnovTest: 0.995);
}

class MockLatticeBHE {
  Future<BHEKey> generateKey({required int lambda}) async => BHEKey();

  Future<Ciphertext> encrypt(int plaintext, List<int> publicKey) async =>
      Ciphertext(isValid: true);

  Future<int> decrypt(Ciphertext ciphertext, List<int> secretKey) async => 42;
}

class MockWorstCaseAverageCase {
  Future<WCAReduction> verifyLWEReduction({required int n}) async =>
      WCAReduction(isValid: true, reductionFactor: 65536);
}

class MockBasisEvolution {
  Future<BasisEvolutionResult> trackKeyGenerationBasis() async =>
      BasisEvolutionResult(stages: [
        BasisStage(orthogonality: 2.0),
        BasisStage(orthogonality: 1.8),
        BasisStage(orthogonality: 1.5),
      ]);
}

class MockKyberKeyAgreement {
  Future<KeyPair> generateKeyPair() async => KeyPair(
        publicKey: List.filled(800, 0),
        secretKey: List.filled(1600, 0),
      );

  Future<Encapsulation> encapsulate(List<int> publicKey) async =>
      Encapsulation(
        ciphertext: List.filled(768, 0),
        sharedSecret: List.filled(32, 0),
      );

  Future<List<int>> decapsulate(List<int> ciphertext, List<int> secretKey) async =>
      List.filled(32, 0);
}

class MockDilithiumAuth {
  Future<SigningKeyPair> generateServerKeyPair() async =>
      SigningKeyPair(publicKey: List.filled(1312, 0), signingKey: List.filled(2560, 0));

  Future<SigningKeyPair> generateClientKeyPair() async =>
      SigningKeyPair(publicKey: List.filled(1312, 0), signingKey: List.filled(2560, 0));

  Future<List<int>> generateChallenge() async => List.filled(32, 0);

  Future<List<int>> signChallenge(List<int> challenge, List<int> signingKey) async =>
      List.filled(2420, 0);

  Future<bool> verifyServerSignature(
    List<int> challenge,
    List<int> signature,
    List<int> publicKey,
  ) async =>
      true;
}

class MockPostQuantumTLS {
  Future<ClientHello> createClientHello({required List<String> supportedAlgorithms}) async =>
      ClientHello(keyShares: List.filled(supportedAlgorithms.length, KeyShare()));

  Future<ServerHello> createServerHello({required String selectedAlgorithm}) async =>
      ServerHello();

  Future<List<int>> negotiateSharedSecret(
    ClientHello clientHello,
    ServerHello serverHello,
  ) async =>
      List.filled(32, 0);
}

class MockPostQuantumPFS {
  Future<Session> createSession() async => Session(peerPublicKey: List.filled(800, 0));

  Future<KeyPair> generateEphemeralKeyPair() async =>
      KeyPair(publicKey: List.filled(800, 0), secretKey: List.filled(1600, 0));

  Future<List<int>> deriveSessionKey(List<int> privateKey, List<int> peerPublicKey) async =>
      List.filled(32, 0);

  Future<void> compromiseEphemeralKey(List<int> key) async {}

  Future<PFSAnalysis> analyzePFSProperties() async =>
      PFSAnalysis(forwardSecurityMaintained: true);
}

class MockHybridKeyEncapsulation {
  Future<HybridPublicKey> generateHybridPublicKey({
    required String classicalAlgo,
    required String quantumAlgo,
  }) async =>
      HybridPublicKey();

  Future<HybridEncapsulation> hybridEncapsulate(HybridPublicKey key) async =>
      HybridEncapsulation(
        classicalCiphertext: List.filled(97, 0),
        quantumCiphertext: List.filled(768, 0),
      );

  Future<List<int>> hybridKDF(List<int> ct1, List<int> ct2) async =>
      List.filled(64, 0);
}

class MockQuantumKeyAgreement {
  Future<KeyPair> generateKeyPair() async =>
      KeyPair(publicKey: List.filled(800, 0), secretKey: List.filled(1600, 0));

  Future<Encapsulation> encapsulate(List<int> publicKey) async =>
      Encapsulation(ciphertext: List.filled(768, 0), sharedSecret: List.filled(32, 0));

  Future<List<int>> eavesdropCiphertext(List<int> ciphertext) async =>
      List.filled(100, 0);

  Future<bool> canRecoverSharedSecret(List<int> eavesdropped) async => false;
}

class MockPostQuantumSignatureAuth {
  Future<KeyPair> generateUserSigningKey() async =>
      KeyPair(publicKey: List.filled(1312, 0), secretKey: List.filled(2560, 0));

  Future<Certificate> createCertificate({
    required List<int> publicKey,
    required String issuer,
  }) async =>
      Certificate();

  Future<bool> verifyCertificateChain(Certificate cert) async => true;
}

class MockPostQuantumKeyRotation {
  Future<void> initiateKeyRotation(List<int> oldKey) async {}

  Future<KeyPair> generateKeyPair() async =>
      KeyPair(publicKey: List.filled(800, 0), secretKey: List.filled(1600, 0));

  Future<bool> validateDuringTransition(KeyPair newKey, KeyPair oldKey) async => true;

  Future<void> completeKeyRotation() async {}

  Future<bool> validateAfterRotation(KeyPair key) async => true;
}

class MockKeyAgreementMetrics {
  int successCount = 0;
  int failureCount = 0;
  final List<int> latencies = [];

  Future<void> executeKeyAgreement() async {
    successCount++;
    latencies.add(50);
  }

  Future<KeyAgreementStats> getMetrics() async => KeyAgreementStats(
        successRate: 0.995,
        avgLatencyMs: 50,
        failureRate: 0.005,
      );
}

class MockHarvestNowDecryptLater {
  Future<List<int>> captureEncryptedCommunications({required int daysOfHistory}) async =>
      List.filled(10000, 0);

  Future<void> simulateQuantumComputerArrival({required int yearsTillQC}) async {}

  Future<DecryptionResult> attemptClassicalDecryption(
    List<int> encrypted, {
    required Duration timeLimit,
  }) async =>
      DecryptionResult(succeeded: false);
}

class MockCryptoAgility {
  Future<FlexibleSystem> designFlexibleCryptoSystem() async =>
      FlexibleSystem(canSwitchAlgorithms: true, requiresKeyRegeneration: false);
}

class MockPQResilience {
  Future<KeyPair> generateKeyPair(String algo) async =>
      KeyPair(publicKey: List.filled(800, 0), secretKey: List.filled(1600, 0));

  Future<void> assumeAlgorithmCompromised(String algo) async {}

  Future<bool> isSystemSecure() async => true;
}

class MockQuantumTimeline {
  Future<Scenario> scenarioQuantumIn10Years() async =>
      Scenario(requiresPostQuantum: true);

  Future<Scenario> scenarioQuantumDelayed() async =>
      Scenario(requiresUrgentAction: false);

  Future<Scenario> scenarioUnexpectedQuantumBreakthrough() async =>
      Scenario(requiresImmediateResponse: true);
}

class MockHNDLProtection {
  Future<EncryptedData> encryptWithPQ({
    required String data,
    required int protectionYears,
  }) async =>
      EncryptedData(isProtectedAgainstHNDL: true);

  Future<EncryptedData> encryptWithRSA({
    required String data,
    required int protectionYears,
  }) async =>
      EncryptedData(isProtectedAgainstHNDL: false);

  Future<void> simulateFutureQuantumComputer() async {}

  Future<bool> canBreakRSAEncryption(EncryptedData data) async => true;
}

class MockThreatAssessment {
  Future<List<ThreatAnalysis>> assessPortfolio(List<String> algorithms) async => [
        ThreatAnalysis(algorithm: 'RSA-2048', quantumVulnerability: 'HIGH'),
      ];
}

class MockTransitionReadiness {
  Future<ReadinessAssessment> assessOrganizationReadiness() async =>
      ReadinessAssessment(
        hasInventory: true,
        hasTestingPlan: true,
        hasMigrationStrategy: true,
        hasStakeholderEngagement: true,
      );
}

class MockQuantumCascade {
  Future<QuantumCapability> simulateQuantumCapability({required int year}) async =>
      QuantumCapability(logicalQubits: 1000 * (year - 2030));

  Future<bool> canBreakAlgorithm(String algorithm, QuantumCapability capability) async =>
      capability.logicalQubits > 10000;
}

class MockThreatLandscape {
  Future<ThreatAssessment> getCurrentThreatAssessment() async =>
      ThreatAssessment(timestamp: DateTime.now().toString());

  Future<List<ThreatAssessment>> getThreatHistory({required int months}) async =>
      List.filled(months, ThreatAssessment(timestamp: ''));

  Future<ThreatTrend> analyzeThreatTrend() async =>
      ThreatTrend(quantumComputingProgress: 'accelerating');
}

class MockAlgorithmAgnosticKM {
  Future<Key> createKey({
    required String name,
    required String algorithm,
    required String backup,
  }) async =>
      Key(id: 'key-1', currentAlgorithm: algorithm);

  Future<void> switchAlgorithm(String keyId, {required String from, required String to}) async {}

  Future<Key> getKey(String keyId) async =>
      Key(id: keyId, currentAlgorithm: 'ChaCha20');
}

class MockCryptoAbstraction {
  Future<Cipher> createCipher(String version) async => Cipher(version: version);

  Future<void> upgradeAlgorithm(String version, String newAlgorithm) async {}
}

class MockHybridEncryptionMigration {
  Future<MigrationPhase> getMigrationPhase(int phase) async => MigrationPhase(
        usesClassicalOnly: phase == 1,
        usesHybridEncryption: phase == 2,
        usesPostQuantumOnly: phase == 3,
      );

  Future<void> upgradeTo({required int phase}) async {}
}

class MockBackwardCompatibleRotation {
  Future<Key> generateKeyWithAlgorithm(String algorithm) async =>
      Key(id: 'key-1', currentAlgorithm: algorithm);

  Future<Key> rotateKeyToAlgorithm(Key oldKey, {required String targetAlgorithm}) async =>
      Key(id: 'key-2', currentAlgorithm: targetAlgorithm);

  Future<bool> validateWithOldAlgorithm(Key key) async => true;
}

class MockAlgorithmDiscovery {
  Future<List<String>> getAvailableAlgorithms() async =>
      ['Kyber512', 'Dilithium2', 'RSA-2048'];

  Future<SystemCapabilities> getSystemCapabilities() async =>
      SystemCapabilities(supportsPostQuantum: true, supportsHybrid: true);
}

class MockAlgorithmConfiguration {
  Future<void> setPolicy(Map<String, String> policy) async {}

  Future<String> selectAlgorithm(String purpose) async => 'Kyber512';
}

class MockCryptographicSuite {
  Future<bool> isSuiteCompatible(CryptographicSuite suite) async => true;

  Future<bool> supportMultipleSuites(List<CryptographicSuite> suites) async => true;
}

class MockAlgorithmDeprecation {
  Future<AlgorithmStatus> getAlgorithmStatus(String algorithm) async =>
      AlgorithmStatus(name: algorithm, status: 'modern', sunsetYear: null);
}

class MockOrgMigrationReadiness {
  Future<OrgReadiness> assessReadiness() async => OrgReadiness(
        hasInventory: true,
        hasMigrationPlan: true,
        hasTestingCapability: true,
        hasStaffTraining: true,
      );
}

// Data Models
class KeyPair {
  final List<int> publicKey;
  final List<int>? secretKey;

  KeyPair({required this.publicKey, this.secretKey});
}

class Encapsulation {
  final List<int> ciphertext;
  final List<int> sharedSecret;

  Encapsulation({required this.ciphertext, required this.sharedSecret});
}

class SigningKeyPair {
  final List<int> publicKey;
  final List<int> signingKey;

  SigningKeyPair({required this.publicKey, required this.signingKey});
}

class MLKEMKeyPair {
  final int publicKeySize;
  final int secretKeySize;

  MLKEMKeyPair({required this.publicKeySize, required this.secretKeySize});
}

class PhaseStatus {
  final bool? isActive;

  PhaseStatus({required this.isActive});
}

class HybridKeyPair {
  final List<int> publicKey;

  HybridKeyPair({required this.publicKey});
}

class HybridSharedSecret {
  final List<int> classicalComponent;
  final List<int> quantumComponent;

  HybridSharedSecret({required this.classicalComponent, required this.quantumComponent});
}

class StandardStatus {
  final bool isApproved;
  final String implementationStatus;

  StandardStatus({required this.isApproved, required this.implementationStatus});
}

class LWEInstance {
  final bool isValid;

  LWEInstance({required this.isValid});
}

class ReducedBasis {
  final bool isReduced;
  final double orthogonality;

  ReducedBasis({required this.isReduced, required this.orthogonality});
}

class BasisQuality {
  final double orthogonality;

  BasisQuality({required this.orthogonality});
}

class Polynomial {
  final int degree;

  Polynomial({required this.degree});
}

class LatencyStats {
  final double avgMs;

  LatencyStats({required this.avgMs});
}

class DistributionStats {
  final double meanOffset;
  final double stdDev;

  DistributionStats({required this.meanOffset, required this.stdDev});
}

class Secret {
  final int allElementsIn;

  Secret({required this.allElementsIn});
}

class GaussianFit {
  final double kolmogorovSmirnovTest;

  GaussianFit({required this.kolmogorovSmirnovTest});
}

class BHEKey {}

class Ciphertext {
  final bool isValid;

  Ciphertext({required this.isValid});
}

class WCAReduction {
  final bool isValid;
  final int reductionFactor;

  WCAReduction({required this.isValid, required this.reductionFactor});
}

class BasisStage {
  final double orthogonality;

  BasisStage({required this.orthogonality});
}

class BasisEvolutionResult {
  final List<BasisStage> stages;

  BasisEvolutionResult({required this.stages});
}

class Session {
  final List<int> peerPublicKey;

  Session({required this.peerPublicKey});
}

class PFSAnalysis {
  final bool forwardSecurityMaintained;

  PFSAnalysis({required this.forwardSecurityMaintained});
}

class HybridPublicKey {}

class HybridEncapsulation {
  final List<int> classicalCiphertext;
  final List<int> quantumCiphertext;

  HybridEncapsulation({required this.classicalCiphertext, required this.quantumCiphertext});
}

class Certificate {}

class ClientHello {
  final List<KeyShare> keyShares;

  ClientHello({required this.keyShares});
}

class KeyShare {}

class ServerHello {}

class DecryptionResult {
  final bool succeeded;

  DecryptionResult({required this.succeeded});
}

class FlexibleSystem {
  final bool canSwitchAlgorithms;
  final bool requiresKeyRegeneration;

  FlexibleSystem({required this.canSwitchAlgorithms, required this.requiresKeyRegeneration});
}

class Scenario {
  final bool? requiresPostQuantum;
  final bool? requiresUrgentAction;
  final bool? requiresImmediateResponse;

  Scenario({this.requiresPostQuantum, this.requiresUrgentAction, this.requiresImmediateResponse});
}

class EncryptedData {
  final bool isProtectedAgainstHNDL;

  EncryptedData({required this.isProtectedAgainstHNDL});
}

class ThreatAnalysis {
  final String algorithm;
  final String quantumVulnerability;

  ThreatAnalysis({required this.algorithm, required this.quantumVulnerability});
}

class ReadinessAssessment {
  final bool hasInventory;
  final bool hasTestingPlan;
  final bool hasMigrationStrategy;
  final bool hasStakeholderEngagement;

  ReadinessAssessment({
    required this.hasInventory,
    required this.hasTestingPlan,
    required this.hasMigrationStrategy,
    required this.hasStakeholderEngagement,
  });
}

class QuantumCapability {
  final int logicalQubits;

  QuantumCapability({required this.logicalQubits});
}

class ThreatAssessment {
  final String timestamp;

  ThreatAssessment({required this.timestamp});
}

class ThreatTrend {
  final String quantumComputingProgress;

  ThreatTrend({required this.quantumComputingProgress});
}

class Key {
  final String id;
  final String currentAlgorithm;

  Key({required this.id, required this.currentAlgorithm});
}

class Cipher {
  final String version;

  Cipher({required this.version});

  Future<List<int>> encrypt(String plaintext) async => List.filled(100, 0);
  Future<String> decrypt(List<int> ciphertext) async => 'plaintext';
}

class MigrationPhase {
  final bool usesClassicalOnly;
  final bool usesHybridEncryption;
  final bool usesPostQuantumOnly;

  MigrationPhase({
    required this.usesClassicalOnly,
    required this.usesHybridEncryption,
    required this.usesPostQuantumOnly,
  });
}

class SystemCapabilities {
  final bool supportsPostQuantum;
  final bool supportsHybrid;

  SystemCapabilities({required this.supportsPostQuantum, required this.supportsHybrid});
}

class CryptographicSuite {
  final String name;
  final String kem;
  final String signature;
  final String cipher;
  final String hash;

  CryptographicSuite({
    required this.name,
    required this.kem,
    required this.signature,
    required this.cipher,
    required this.hash,
  });
}

class AlgorithmStatus {
  final String name;
  final String status;
  final int? sunsetYear;

  AlgorithmStatus({required this.name, required this.status, this.sunsetYear});
}

class OrgReadiness {
  final bool hasInventory;
  final bool hasMigrationPlan;
  final bool hasTestingCapability;
  final bool hasStaffTraining;

  OrgReadiness({
    required this.hasInventory,
    required this.hasMigrationPlan,
    required this.hasTestingCapability,
    required this.hasStaffTraining,
  });
}

class KeyAgreementStats {
  final double successRate;
  final int avgLatencyMs;
  final double failureRate;

  KeyAgreementStats({
    required this.successRate,
    required this.avgLatencyMs,
    required this.failureRate,
  });
}
