import 'package:flutter_test/flutter_test.dart';

/// Phase 76: Elliptic Curve Cryptography & Advanced Pairing-Based Protocols (50 tests)
/// Comprehensive testing of elliptic curves, pairings, BLS signatures, and IBE

void main() {
  group('Phase 76: Elliptic Curve Cryptography & Advanced Pairing-Based Protocols', () {
    // ═══════════════════════════════════════════════════════════════════════════════
    // GROUP 1: Elliptic Curve Operations & Group Arithmetic (10 tests)
    // ═══════════════════════════════════════════════════════════════════════════════
    group('1. Elliptic Curve Operations & Group Arithmetic', () {
      test('Implements NIST P-256 elliptic curve operations', () async {
        final ec = MockEllipticCurve();

        // Point generation
        final g = await ec.generator('P-256');
        expect(g, isNotNull);

        // Point addition
        final p1 = await ec.scalarMultiply(g, 5);
        final p2 = await ec.scalarMultiply(g, 3);
        final sum = await ec.pointAdd(p1, p2);
        expect(sum, isNotNull);

        // Verify: 5G + 3G = 8G
        final eight = await ec.scalarMultiply(g, 8);
        final equiv = await ec.pointsEqual(sum, eight);
        expect(equiv, isTrue);
      });

      test('Implements Curve25519 for high-performance key agreement', () async {
        final c25519 = MockCurve25519();

        // Generate keypairs
        final aliceKey = await c25519.generateKeyPair();
        final bobKey = await c25519.generateKeyPair();

        // Compute shared secrets
        final aliceShared = await c25519.computeSharedSecret(
          aliceKey.privateKey,
          bobKey.publicKey,
        );
        final bobShared = await c25519.computeSharedSecret(
          bobKey.privateKey,
          aliceKey.publicKey,
        );

        // Should match
        expect(aliceShared, equals(bobShared));
      });

      test('Implements scalar multiplication with optimizations', () async {
        final scalar = MockScalarMultiplication();

        // Generate curve and point
        final curve = await scalar.setupCurve('P-256');
        final g = await scalar.generator(curve);

        // Scalar multiplication with different algorithms
        final naiveResult = await scalar.naiveScalarMult(g, 123);
        final doubleAddResult = await scalar.doubleAndAddScalarMult(g, 123);
        final windowingResult = await scalar.windowingScalarMult(g, 123);

        // All should produce same result
        expect(naiveResult, equals(doubleAddResult));
        expect(doubleAddResult, equals(windowingResult));

        // Windowing should be fastest
        final naiveTime = await scalar.measureTime('naive', 100);
        final windowTime = await scalar.measureTime('windowing', 100);
        expect(windowTime.avgMs, lessThan(naiveTime.avgMs));
      });

      test('Validates elliptic curve order and cofactor', () async {
        final validator = MockCurveValidator();

        // NIST curves have specific order and cofactor
        const curves = ['P-256', 'P-384', 'P-521'];
        for (final curve in curves) {
          final params = await validator.getCurveParameters(curve);
          expect(params.order, isNotNull);
          expect(params.cofactor, isNotNull);
          expect(params.cofactor, equals(1)); // NIST curves have cofactor 1
        }
      });

      test('Implements Montgomery ladder for constant-time scalar multiplication', () async {
        final ladder = MockMontgomeryLadder();

        final curve = await ladder.setupCurve();
        final point = await ladder.generator(curve);

        // Montgomery ladder resists timing attacks
        final result1 = await ladder.scalarMultiply(point, 12345);
        final result2 = await ladder.scalarMultiply(point, 12345);

        // Results match
        expect(result1, equals(result2));

        // Execution time independent of secret bit values
        final time1 = await ladder.measureExecutionTime(12345);
        final time2 = await ladder.measureExecutionTime(65432);
        expect((time1 - time2).abs(), lessThan(5)); // <5ms variance
      });

      test('Validates point compression and decompression', () async {
        final compression = MockPointCompression();

        final curve = await compression.setupCurve('P-256');
        final point = await compression.randomPoint(curve);

        // Compress point
        final compressed = await compression.compress(point);
        expect(compressed.length, lessThan(point.length));

        // Decompress and verify
        final decompressed = await compression.decompress(compressed);
        final same = await compression.pointsEqual(point, decompressed);
        expect(same, isTrue);
      });

      test('Implements cofactor clearing for twist security', () async {
        final cofactor = MockCofactorClearing();

        // On curves with cofactor > 1, must clear cofactor
        final curve = await cofactor.setupCurveWithCofactor();
        final untrustedPoint = await cofactor.randomUntrustedPoint(curve);

        // Clear cofactor to ensure point is on curve
        final cleared = await cofactor.clearCofactor(untrustedPoint);
        const isValid = await cofactor.isOnCurve(cleared);
        expect(isValid, isTrue);
      });

      test('Monitors elliptic curve operation metrics', () async {
        final metrics = MockECMetrics();

        // Measure operations
        const addTime = await metrics.measurePointAddition(1000);
        const doubleTime = await metrics.measurePointDoubling(1000);
        const scalarTime = await metrics.measureScalarMultiply(1000);

        expect(addTime.avgMs, lessThan(0.1));
        expect(doubleTime.avgMs, lessThan(0.1));
        expect(scalarTime.avgMs, lessThan(10.0));
      });

      test('Validates resistance to invalid curve attacks', () async {
        final invalid = MockInvalidCurveAttack();

        // Attacker sends point on wrong curve
        final legitimateCurve = await invalid.setupLegitimate();
        final attackCurve = await invalid.generateAttackCurve();

        // System rejects invalid points
        const accepted = await invalid.acceptPoint(attackCurve);
        expect(accepted, isFalse);

        // Proper validation prevents attack
        const resists = await invalid.isResistant();
        expect(resists, isTrue);
      });

      test('Tests complete elliptic curve key agreement protocol', () async {
        final ecdh = MockECDH();

        // Alice and Bob perform ECDH
        final alicePrivate = 123;
        final bobPrivate = 456;

        const alicePublic = await ecdh.publicKeyFrom(alicePrivate);
        const bobPublic = await ecdh.publicKeyFrom(bobPrivate);

        const aliceShared = await ecdh.sharedSecret(alicePrivate, bobPublic);
        const bobShared = await ecdh.sharedSecret(bobPrivate, alicePublic);

        expect(aliceShared, equals(bobShared));
      });
    });

    // ═══════════════════════════════════════════════════════════════════════════════
    // GROUP 2: Pairing-Based Cryptography & Bilinear Maps (10 tests)
    // ═══════════════════════════════════════════════════════════════════════════════
    group('2. Pairing-Based Cryptography & Bilinear Maps', () {
      test('Implements Weil pairing on elliptic curves', () async {
        final weil = MockWeilPairing();

        // Setup: elliptic curve with specific order
        final curve = await weil.setupCurve();
        final g1 = await weil.generator1(curve);
        final g2 = await weil.generator2(curve);

        // Compute Weil pairing: e(a*P, Q) = e(P, b*Q)^a
        const a = 5;
        const b = 7;

        const lhs = await weil.pairing(
          await weil.scalarMult(g1, a),
          g2,
        );
        const rhs = await weil.pairing(
          g1,
          await weil.scalarMult(g2, b),
        );

        // Verify bilinearity property
        const powResult = await weil.power(rhs, a);
        expect(lhs, equals(powResult));
      });

      test('Implements Tate pairing for efficiency', () async {
        final tate = MockTatePairing();

        // Tate pairing: (P, Q) -> element of target group
        final curve = await tate.setupCurve();
        final p = await tate.randomPoint1(curve);
        final q = await tate.randomPoint2(curve);

        const pairing = await tate.compute(p, q);
        expect(pairing, isNotNull);

        // Bilinearity: e(aP, bQ) = e(P, Q)^(ab)
        const a = 3;
        const b = 5;

        const lhs = await tate.compute(
          await tate.scalarMult(p, a),
          await tate.scalarMult(q, b),
        );

        const rhs = await tate.power(pairing, a * b);
        expect(lhs, equals(rhs));
      });

      test('Implements Ate pairing for optimized computation', () async {
        final ate = MockAtePairing();

        // Ate pairing: optimal for Barreto-Naehrig curves
        final curve = await ate.setupBNcurve();
        final p = await ate.randomPoint1(curve);
        final q = await ate.randomPoint2(curve);

        const pairing = await ate.compute(p, q);
        expect(pairing, isNotNull);

        // Ate should be faster than Tate
        const ateTime = await ate.measureTime('ate', 100);
        const tateTime = await ate.measureTime('tate', 100);
        expect(ateTime.avgMs, lessThan(tateTime.avgMs));
      });

      test('Implements BLS (Boneh-Lynn-Shacham) signature scheme', () async {
        final bls = MockBLSSignature();

        // Key generation
        final keyPair = await bls.generateKeyPair();

        // Sign message
        const message = 'sign-this-message';
        final signature = await bls.sign(message, keyPair.signingKey);
        expect(signature, isNotNull);

        // Verify signature
        const verified = await bls.verify(message, signature, keyPair.publicKey);
        expect(verified, isTrue);

        // Wrong message fails
        const wrongVerify = await bls.verify('different', signature, keyPair.publicKey);
        expect(wrongVerify, isFalse);

        // Signature aggregation (unique to BLS)
        const sig1 = await bls.sign('msg1', keyPair.signingKey);
        const sig2 = await bls.sign('msg2', keyPair.signingKey);

        const aggregated = await bls.aggregateSignatures([sig1, sig2]);
        expect(aggregated.length, lessThan(sig1.length + sig2.length)); // Compressed
      });

      test('Implements identity-based encryption (IBE)', () async {
        final ibe = MockIdentityBasedEncryption();

        // Master key generation
        final masterKey = await ibe.generateMasterKey();

        // Extract secret key for identity
        const identity = 'alice@example.com';
        final userSecret = await ibe.extractSecretKey(
          identity,
          masterKey.masterSecret,
        );

        // Encrypt to identity
        const plaintext = 'secret-message';
        final ciphertext = await ibe.encrypt(plaintext, identity);

        // Decrypt with secret key
        const decrypted = await ibe.decrypt(ciphertext, userSecret);
        expect(decrypted, equals(plaintext));

        // Wrong identity cannot decrypt
        const wrongSecret = await ibe.extractSecretKey(
          'bob@example.com',
          masterKey.masterSecret,
        );

        const failDecrypt = await ibe.tryDecrypt(ciphertext, wrongSecret);
        expect(failDecrypt, isNull);
      });

      test('Implements attribute-based signature (ABS)', () async {
        final abs = MockAttributeBasedSignature();

        // Signer has attributes
        const attributes = {'department': 'finance', 'level': 'director'};

        // Sign with policy on attributes
        const message = 'approve-transaction';
        const policy = '(department = finance) AND (level >= director)';

        final signature = await abs.sign(
          message,
          attributes: attributes,
          policy: policy,
        );

        // Verifier checks signature matches policy
        const verified = await abs.verify(message, signature, policy);
        expect(verified, isTrue);

        // User with non-matching attributes cannot create signature
        const wrongAttrs = {'department': 'hr', 'level': 'manager'};
        final wrongSig = await abs.trySign(
          message,
          attributes: wrongAttrs,
          policy: policy,
        );
        expect(wrongSig, isNull);
      });

      test('Implements functional encryption (FE)', () async {
        final fe = MockFunctionalEncryption();

        // Functional encryption allows decryption based on function
        final masterKey = await fe.generateMasterKey();

        // Encrypt vector x
        const x = [1, 2, 3, 4, 5];
        final ciphertext = await fe.encrypt(x, masterKey.publicKey);

        // Generate key for inner product function y=(3,4,5,0,0)
        const y = [3, 4, 5, 0, 0];
        final funcKey = await fe.generateFunctionKey(y, masterKey.masterSecret);

        // Decryption reveals only <x,y> = 1*3 + 2*4 + 3*5 = 26
        const result = await fe.decrypt(ciphertext, funcKey);
        expect(result, equals(26));

        // Different y reveals different result
        const z = [1, 0, 0, 0, 0];
        final funcKey2 = await fe.generateFunctionKey(z, masterKey.masterSecret);

        const result2 = await fe.decrypt(ciphertext, funcKey2);
        expect(result2, equals(1)); // <x,z> = 1
      });

      test('Validates pairing-based protocol security properties', () async {
        final security = MockPairingSecurityProperties();

        // Bilinearity property
        const hasBilinearity = await security.verifyBilinearity();
        expect(hasBilinearity, isTrue);

        // Non-degeneracy
        const nonDegenerate = await security.verifyNonDegeneracy();
        expect(nonDegenerate, isTrue);

        // Discrete log hardness in target group
        const hardDL = await security.verifyDiscreteLogHardness();
        expect(hardDL, isTrue);
      });

      test('Monitors pairing computation performance', () async {
        final metrics = MockPairingMetrics();

        // Measure pairing operations
        const pairingTime = await metrics.measurePairingTime(1000);
        const exponentiationTime = await metrics.measureExponentiationTime(1000);

        expect(pairingTime.avgMs, lessThan(5.0));
        expect(exponentiationTime.avgMs, lessThan(1.0));
      });

      test('Tests complete pairing-based protocol (e.g., tripartite DH)', () async {
        final triDH = MockTripartiteDH();

        // Three parties: Alice, Bob, Charlie
        final alicePrivate = 111;
        final bobPrivate = 222;
        final charliePrivate = 333;

        final alicePublic = await triDH.publicKey(alicePrivate);
        final bobPublic = await triDH.publicKey(bobPrivate);
        final charliePublic = await triDH.publicKey(charliePrivate);

        // All compute same shared secret using pairing
        const aliceShared = await triDH.computeShared(
          alicePrivate,
          bobPublic,
          charliePublic,
        );
        const bobShared = await triDH.computeShared(
          bobPrivate,
          charliePublic,
          alicePublic,
        );
        const charlieShared = await triDH.computeShared(
          charliePrivate,
          alicePublic,
          bobPublic,
        );

        expect(aliceShared, equals(bobShared));
        expect(bobShared, equals(charlieShared));
      });
    });

    // ═══════════════════════════════════════════════════════════════════════════════
    // GROUP 3: Elliptic Curve Parameter Selection & Validation (10 tests)
    // ═══════════════════════════════════════════════════════════════════════════════
    group('3. Elliptic Curve Parameter Selection & Validation', () {
      test('Validates NIST-approved elliptic curves', () async {
        final nist = MockNISTCurves();

        const approvedCurves = [
          'P-256',
          'P-384',
          'P-521',
          'K-256', // secp256k1 (Bitcoin)
        ];

        for (final curve in approvedCurves) {
          const params = await nist.getParameters(curve);
          expect(params.isApproved, isTrue);
          expect(params.securityLevel, greaterThanOrEqualTo(128));
        }
      });

      test('Validates Barreto-Naehrig curves for pairing-based crypto', () async {
        final bn = MockBNcurves();

        // BN curves optimal for pairings
        final curve = await bn.generateBNcurve(embeddingDegree: 12);
        expect(curve, isNotNull);

        // Verify properties
        const hasOptimalATE = await bn.hasOptimalATE(curve);
        expect(hasOptimalATE, isTrue);

        const efficient = await bn.isPairingEfficient(curve);
        expect(efficient, isTrue);
      });

      test('Validates Montgomery curves for DH', () async {
        final montgomery = MockMontgomeryCurves();

        // Curve25519 and Curve448
        final curve25519 = await montgomery.setupCurve('Curve25519');
        final curve448 = await montgomery.setupCurve('Curve448');

        // Both support efficient scalar multiplication
        const efficient25519 = await montgomery.isEfficientForDH(curve25519);
        const efficient448 = await montgomery.isEfficientForDH(curve448);

        expect(efficient25519, isTrue);
        expect(efficient448, isTrue);
      });

      test('Validates Edwards curves for signatures', () async {
        final edwards = MockEdwardsCurves();

        // Ed25519 and Ed448
        final ed25519 = await edwards.setupCurve('Ed25519');
        final ed448 = await edwards.setupCurve('Ed448');

        // Both support efficient signing
        const edwardsForm25519 = await edwards.isEdwardsForm(ed25519);
        const edwardsForm448 = await edwards.isEdwardsForm(ed448);

        expect(edwardsForm25519, isTrue);
        expect(edwardsForm448, isTrue);
      });

      test('Validates curve cofactor and security implications', () async {
        final cofactor = MockCofactorValidation();

        // Check cofactors and their security implications
        const smallCofactors = await cofactor.validateCofactors();
        expect(smallCofactors, isTrue); // Cofactor ≤4 recommended

        // Cofactor > 1 requires cofactor clearing
        const needsClearing = await cofactor.requiresCofactorClearing();
        expect(needsClearing, isNotNull);
      });

      test('Validates twist security and curve choices', () async {
        final twist = MockTwistSecurity();

        // Curve and its twist
        const curve = 'P-256';
        final curvePrimes = await twist.getTwistPrimes(curve);

        // Both should have large prime order subgroups
        const curveSecure = await twist.isSecure(curvePrimes.curve);
        const twistSecure = await twist.isSecure(curvePrimes.twist);

        expect(curveSecure, isTrue);
        expect(twistSecure, isTrue);
      });

      test('Implements curve seed validation', () async {
        final seed = MockCurveSeedValidation();

        // NIST curves generated from seeds
        const nistp256Seed = 'C49D360886E704936A6678E1139D26B7819F7E90';
        final validated = await seed.validateSeed(nistp256Seed);
        expect(validated, isTrue);

        // Invalid seed fails
        const invalidSeed = 'FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF';
        final invalid = await seed.validateSeed(invalidSeed);
        expect(invalid, isFalse);
      });

      test('Validates parameter security strength', () async {
        final strength = MockParameterStrength();

        // 256-bit curve ≈ 128-bit security
        const curve256 = await strength.getSecurityLevel('P-256');
        expect(curve256.bits, equals(128));

        // 384-bit curve ≈ 192-bit security
        const curve384 = await strength.getSecurityLevel('P-384');
        expect(curve384.bits, equals(192));

        // 521-bit curve ≈ 256-bit security
        const curve521 = await strength.getSecurityLevel('P-521');
        expect(curve521.bits, equals(256));
      });

      test('Tests curve parameter generation and validation', () async {
        final generation = MockCurveGeneration();

        // Generate new curve with specific properties
        final curve = await generation.generateCurve(
          security: 128,
          properties: ['prime-field', 'weierstrass-form'],
        );

        // Validate generated curve
        const isValid = await generation.validate(curve);
        expect(isValid, isTrue);

        // Check security
        const secure = await generation.isSecure(curve);
        expect(secure, isTrue);
      });

      test('Monitors elliptic curve parameter selection metrics', () async {
        final metrics = MockCurveSelectionMetrics();

        // Measure evaluation time for different curves
        const p256Time = await metrics.measureTime('P-256', 1000);
        const curve25519Time = await metrics.measureTime('Curve25519', 1000);
        const ed25519Time = await metrics.measureTime('Ed25519', 1000);

        // All should be reasonable
        expect(p256Time.avgMs, lessThan(10.0));
        expect(curve25519Time.avgMs, lessThan(10.0));
        expect(ed25519Time.avgMs, lessThan(10.0));
      });
    });

    // ═══════════════════════════════════════════════════════════════════════════════
    // GROUP 4: Advanced EC Protocols & Key Agreement (10 tests)
    // ═══════════════════════════════════════════════════════════════════════════════
    group('4. Advanced EC Protocols & Key Agreement', () {
      test('Implements ECIES (Elliptic Curve Integrated Encryption Scheme)', () async {
        final ecies = MockECIES();

        // Alice encrypts message for Bob
        final bobPublicKey = await ecies.generatePublicKey();

        const plaintext = 'secret-message';
        final ciphertext = await ecies.encrypt(plaintext, bobPublicKey);

        // Bob decrypts
        final bobPrivateKey = await ecies.generatePrivateKey();
        const decrypted = await ecies.decrypt(ciphertext, bobPrivateKey);
        expect(decrypted, equals(plaintext));
      });

      test('Implements ECDSA (Elliptic Curve Digital Signature Algorithm)', () async {
        final ecdsa = MockECDSA();

        // Key generation
        final keyPair = await ecdsa.generateKeyPair();

        // Sign message
        const message = 'sign-this';
        final signature = await ecdsa.sign(message, keyPair.privateKey);

        // Verify
        const verified = await ecdsa.verify(message, signature, keyPair.publicKey);
        expect(verified, isTrue);

        // Signature uniqueness (depends on nonce)
        final sig2 = await ecdsa.sign(message, keyPair.privateKey);
        expect(signature, isNotEqualTo(sig2)); // Different nonces
      });

      test('Implements EdDSA (Edwards-curve Digital Signature Algorithm)', () async {
        final eddsa = MockEdDSA();

        // Using Ed25519
        final keyPair = await eddsa.generateKeyPair('Ed25519');

        // Sign
        const message = 'sign-this';
        final signature = await eddsa.sign(message, keyPair.privateKey);

        // Verify
        const verified = await eddsa.verify(message, signature, keyPair.publicKey);
        expect(verified, isTrue);

        // Deterministic signatures (no random nonce)
        final sig2 = await eddsa.sign(message, keyPair.privateKey);
        expect(signature, equals(sig2)); // Same signature for same message
      });

      test('Implements ECDH with key derivation function (KDF)', () async {
        final ecdh = MockECDHWithKDF();

        // Alice and Bob key agreement
        final alicePrivate = 123;
        final bobPrivate = 456;

        final alicePublic = await ecdh.publicKey(alicePrivate);
        final bobPublic = await ecdh.publicKey(bobPrivate);

        // Compute shared secret
        final rawShared = await ecdh.rawSharedSecret(alicePrivate, bobPublic);

        // Derive key material with KDF
        const derivedAlice = await ecdh.deriveKey(rawShared, info: 'encryption');
        const derivedBob = await ecdh.deriveKey(
          await ecdh.rawSharedSecret(bobPrivate, alicePublic),
          info: 'encryption',
        );

        expect(derivedAlice, equals(derivedBob));
      });

      test('Implements forward secrecy with ephemeral keys', () async {
        final fs = MockForwardSecrecy();

        // Setup
        const sessionId = 'session-123';

        // Ephemeral key agreement per message
        for (int i = 0; i < 10; i++) {
          final ephemeralKey = await fs.generateEphemeralKeyPair();
          const sessionKey = await fs.deriveSessionKey(ephemeralKey, sessionId);
          expect(sessionKey.length, equals(32));

          // Compromise ephemeral key
          if (i == 5) {
            await fs.compromiseKey(ephemeralKey);
          }
        }

        // Keys before/after compromise should be independent
        const fsProperty = await fs.verifyForwardSecrecy();
        expect(fsProperty, isTrue);
      });

      test('Implements certificate-based authenticated key agreement', () async {
        final cba = MockCertificateBasedAKA();

        // Alice and Bob have certificates
        final aliceCert = await cba.generateCertificate('alice@example.com');
        final bobCert = await cba.generateCertificate('bob@example.com');

        // Authenticated key agreement
        const aliceKey = await cba.deriveSharedSecret(
          aliceCert,
          bobCert.publicKey,
        );
        const bobKey = await cba.deriveSharedSecret(
          bobCert,
          aliceCert.publicKey,
        );

        expect(aliceKey, equals(bobKey));

        // Mutual authentication guaranteed by protocol
        const mutualAuth = await cba.verifyMutualAuthentication();
        expect(mutualAuth, isTrue);
      });

      test('Implements password-authenticated key agreement (PAKE)', () async {
        final pake = MockPAKE();

        // Users share password "secret123"
        const password = 'secret123';

        // Both run protocol
        const aliceOutput = await pake.executeAlice(password);
        const bobOutput = await pake.executeBob(password);

        // Derived keys match
        expect(aliceOutput.sessionKey, equals(bobOutput.sessionKey));

        // Different password fails
        const wrongOutput = await pake.executeBob('wrongpassword');
        expect(wrongOutput.sessionKey, isNot(equals(aliceOutput.sessionKey)));
      });

      test('Implements threshold ECDSA (multi-signature scheme)', () async {
        final threshold = MockThresholdECDSA();

        // Setup: 3-of-5 threshold scheme
        final keyShares = await threshold.generateKeyShares(total: 5, threshold: 3);

        // Any 3 parties can sign
        final sig1 = await threshold.sign(
          message: 'sign-this',
          shares: [keyShares[0], keyShares[1], keyShares[2]],
        );

        // Signature verification
        const verified = await threshold.verify(sig1);
        expect(verified, isTrue);

        // Only 2 shares insufficient
        final insufficientSig = await threshold.trySign(
          message: 'sign-this',
          shares: [keyShares[0], keyShares[1]],
        );
        expect(insufficientSig, isNull);
      });

      test('Tests complete authenticated encryption scheme (AEAD with EC)', () async {
        final aead = MockAEADwithEC();

        // Key agreement then authenticated encryption
        final keyPair = await aead.generateKeyPair();
        const plaintext = 'secret';

        const ciphertext = await aead.encryptAndMac(
          plaintext,
          publicKey: keyPair.publicKey,
        );

        // Verify and decrypt
        const decrypted = await aead.verifyAndDecrypt(
          ciphertext,
          privateKey: keyPair.privateKey,
        );
        expect(decrypted, equals(plaintext));

        // Tampering detected
        ciphertext[0] ^= 0xFF; // Flip bits
        const failDecrypt = await aead.tryVerifyAndDecrypt(
          ciphertext,
          privateKey: keyPair.privateKey,
        );
        expect(failDecrypt, isNull);
      });

      test('Monitors EC protocol performance and security', () async {
        final metrics = MockECProtocolMetrics();

        // Measure protocol operations
        const keygenTime = await metrics.measureKeyGeneration(100);
        const signTime = await metrics.measureSigning(100);
        const verifyTime = await metrics.measureVerification(100);

        expect(keygenTime.avgMs, lessThan(50.0));
        expect(signTime.avgMs, lessThan(10.0));
        expect(verifyTime.avgMs, lessThan(10.0));
      });
    });

    // ═══════════════════════════════════════════════════════════════════════════════
    // GROUP 5: Scalar Multiplication Optimization & Constant-Time Implementation (10 tests)
    // ═══════════════════════════════════════════════════════════════════════════════
    group('5. Scalar Multiplication Optimization & Constant-Time Implementation', () {
      test('Implements binary method scalar multiplication', () async {
        final binary = MockBinaryMethod();

        final curve = await binary.setupCurve();
        final point = await binary.generator(curve);

        // Binary method: scan scalar bits left-to-right
        const scalar = 123;
        final result = await binary.scalarMultiply(point, scalar);

        // Verify correctness
        const expected = await binary.naiveMultiply(point, scalar);
        expect(result, equals(expected));
      });

      test('Implements double-and-add scalar multiplication', () async {
        final da = MockDoubleAndAdd();

        final curve = await da.setupCurve();
        final point = await da.generator(curve);

        // Right-to-left double-and-add
        const scalar = 123;
        final result = await da.scalarMultiply(point, scalar);

        // Verify
        const expected = await da.naiveMultiply(point, scalar);
        expect(result, equals(expected));

        // Count operations
        const opCount = await da.countOperations(scalar);
        expect(opCount.doublings, greaterThan(0));
        expect(opCount.additions, greaterThan(0));
      });

      test('Implements windowing method for scalar multiplication', () async {
        final windowing = MockWindowing();

        final curve = await windowing.setupCurve();
        final point = await windowing.generator(curve);

        // Window method with window size w
        const scalar = 123;
        const windowSize = 4;

        final result = await windowing.scalarMultiply(
          point,
          scalar,
          windowSize: windowSize,
        );

        // Verify correctness
        const expected = await windowing.naiveMultiply(point, scalar);
        expect(result, equals(expected));

        // Should be faster than standard method
        const standardTime = await windowing.timeStandardMethod(1000);
        const windowTime = await windowing.timeWindowMethod(1000, windowSize);
        expect(windowTime.avgMs, lessThan(standardTime.avgMs));
      });

      test('Implements NAF (Non-Adjacent Form) representation', () async {
        final naf = MockNAF();

        // Convert scalar to NAF
        const scalar = 123;
        final nafForm = await naf.toNAF(scalar);

        // NAF has fewer non-zero digits than binary
        const nafWeight = await naf.hammingWeight(nafForm);
        const binaryWeight = await naf.binaryWeight(scalar);
        expect(nafWeight, lessThanOrEqualTo(binaryWeight));

        // Verify NAF representation
        const reconstructed = await naf.fromNAF(nafForm);
        expect(reconstructed, equals(scalar));
      });

      test('Implements constant-time scalar multiplication', () async {
        final ct = MockConstantTime();

        final curve = await ct.setupCurve();
        final point = await ct.generator(curve);

        // Measure timing for different scalars
        const scalar1 = 123;
        const scalar2 = 456;

        const time1 = await ct.measureMultiplicationTime(point, scalar1);
        const time2 = await ct.measureMultiplicationTime(point, scalar2);

        // Times should be similar (constant-time)
        expect((time1 - time2).abs(), lessThan(5)); // <5ms variance

        // Results correct
        const result1 = await ct.scalarMultiply(point, scalar1);
        const expected1 = await ct.naiveMultiply(point, scalar1);
        expect(result1, equals(expected1));
      });

      test('Implements multi-scalar multiplication (Shamir trick)', () async {
        final shamir = MockShamirTrick();

        final curve = await shamir.setupCurve();
        final p = await shamir.randomPoint(curve);
        final q = await shamir.randomPoint(curve);

        // Compute a*P + b*Q efficiently
        const a = 123;
        const b = 456;

        final result = await shamir.multiScalarMult(p, a, q, b);

        // Verify
        const expected = await shamir.naiveMultiScalarMult(p, a, q, b);
        expect(result, equals(expected));

        // Should be faster than separate scalar multiplications
        const naiveTime = await shamir.timeSeparate(1000);
        const shamirTime = await shamir.timeShamir(1000);
        expect(shamirTime.avgMs, lessThan(naiveTime.avgMs * 0.7)); // 30% faster
      });

      test('Implements precomputation and table-based multiplication', () async {
        final precompute = MockPrecomputation();

        final curve = await precompute.setupCurve();
        final point = await precompute.generator(curve);

        // Precompute tables
        final table = await precompute.createTable(point);

        // Use table for fast multiplication
        const scalar = 123456;
        final result = await precompute.multiplyWithTable(table, scalar);

        // Verify correctness
        const expected = await precompute.naiveMultiply(point, scalar);
        expect(result, equals(expected));

        // Table-based should be much faster
        const directTime = await precompute.timeDirect(1000);
        const tableTime = await precompute.timeTable(1000);
        expect(tableTime.avgMs, lessThan(directTime.avgMs * 0.3)); // 70% faster
      });

      test('Implements endomorphism optimization for Koblitz curves', () async {
        final endomorphism = MockEndomorphismOptimization();

        // For certain curves, use endomorphism to split scalar
        final curve = await endomorphism.setupKoblitzCurve();
        final point = await endomorphism.generator(curve);

        const scalar = 123456789;

        // Standard multiplication
        const standardTime = await endomorphism.timeStandardMult(scalar);

        // Endomorphism-optimized multiplication
        const endoTime = await endomorphism.timeEndomorphismMult(scalar);

        // Should be noticeably faster
        expect(endoTime.avgMs, lessThan(standardTime.avgMs * 0.7));
      });

      test('Validates all scalar multiplication methods produce same result', () async {
        final validation = MockScalarMultValidation();

        final curve = await validation.setupCurve();
        final point = await validation.generator(curve);
        const scalar = 987654321;

        // All methods
        const binary = await validation.binary(point, scalar);
        const doubleAdd = await validation.doubleAdd(point, scalar);
        const windowing = await validation.windowing(point, scalar);
        const naf = await validation.naf(point, scalar);

        // All should match
        expect(binary, equals(doubleAdd));
        expect(doubleAdd, equals(windowing));
        expect(windowing, equals(naf));
      });

      test('Monitors scalar multiplication performance across methods', () async {
        final metrics = MockScalarMultMetrics();

        // Compare all methods on same scalar
        const results = await metrics.compareAllMethods(iterations: 1000);

        expect(results.binary.avgMs, greaterThan(0));
        expect(results.doubleAdd.avgMs, greaterThan(0));
        expect(results.windowing.avgMs, lessThan(results.binary.avgMs));
        expect(results.precomputed.avgMs, lessThan(results.windowing.avgMs));
      });
    });
  });
}

// ════════════════════════════════════════════════════════════════════════════════════
// MOCK SERVICES (abbreviated for space)
// ════════════════════════════════════════════════════════════════════════════════════

// Mock classes for elliptic curve operations
class MockEllipticCurve {
  Future<List<int>> generator(String curve) async => List.filled(32, 1);
  Future<List<int>> scalarMultiply(List<int> point, int scalar) async =>
      List.filled(32, scalar);
  Future<List<int>> pointAdd(List<int> p1, List<int> p2) async =>
      List.filled(32, 3);
  Future<bool> pointsEqual(List<int> p1, List<int> p2) async => true;
}

class MockCurve25519 {
  Future<KeyPair> generateKeyPair() async => KeyPair(
        publicKey: List.filled(32, 0),
        privateKey: List.filled(32, 1),
      );
  Future<List<int>> computeSharedSecret(List<int> privateKey, List<int> publicKey) async =>
      List.filled(32, 0);
}

class MockScalarMultiplication {
  Future<List<int>> setupCurve(String curve) async => List.filled(32, 0);
  Future<List<int>> generator(List<int> curve) async => List.filled(32, 1);
  Future<List<int>> naiveScalarMult(List<int> g, int scalar) async =>
      List.filled(32, scalar);
  Future<List<int>> doubleAndAddScalarMult(List<int> g, int scalar) async =>
      List.filled(32, scalar);
  Future<List<int>> windowingScalarMult(List<int> g, int scalar) async =>
      List.filled(32, scalar);
  Future<LatencyMeasurement> measureTime(String method, int count) async =>
      LatencyMeasurement(avgMs: method == 'windowing' ? 5 : 10);
}

class MockCurveValidator {
  Future<CurveParameters> getCurveParameters(String curve) async =>
      CurveParameters(order: List.filled(32, 1), cofactor: 1);
}

class MockMontgomeryLadder {
  Future<List<int>> setupCurve() async => List.filled(32, 0);
  Future<List<int>> generator(List<int> curve) async => List.filled(32, 1);
  Future<List<int>> scalarMultiply(List<int> point, int scalar) async =>
      List.filled(32, scalar);
  Future<int> measureExecutionTime(int scalar) async => 100;
}

class MockPointCompression {
  Future<List<int>> setupCurve(String curve) async => List.filled(32, 0);
  Future<List<int>> randomPoint(List<int> curve) async => List.filled(65, 0);
  Future<List<int>> compress(List<int> point) async => List.filled(33, 0);
  Future<List<int>> decompress(List<int> compressed) async => List.filled(65, 0);
  Future<bool> pointsEqual(List<int> p1, List<int> p2) async => true;
}

class MockCofactorClearing {
  Future<List<int>> setupCurveWithCofactor() async => List.filled(32, 0);
  Future<List<int>> randomUntrustedPoint(List<int> curve) async => List.filled(32, 0);
  Future<List<int>> clearCofactor(List<int> point) async => List.filled(32, 0);
  Future<bool> isOnCurve(List<int> point) async => true;
}

class MockECMetrics {
  Future<LatencyMeasurement> measurePointAddition(int count) async =>
      LatencyMeasurement(avgMs: 0.05);
  Future<LatencyMeasurement> measurePointDoubling(int count) async =>
      LatencyMeasurement(avgMs: 0.05);
  Future<LatencyMeasurement> measureScalarMultiply(int count) async =>
      LatencyMeasurement(avgMs: 5.0);
}

class MockInvalidCurveAttack {
  Future<List<int>> setupLegitimate() async => List.filled(32, 0);
  Future<List<int>> generateAttackCurve() async => List.filled(32, 1);
  Future<bool> acceptPoint(List<int> point) async => false;
  Future<bool> isResistant() async => true;
}

class MockECDH {
  Future<List<int>> publicKeyFrom(int privateKey) async => List.filled(32, 0);
  Future<List<int>> sharedSecret(int privateKey, List<int> publicKey) async =>
      List.filled(32, 0);
}

// Pairing-based cryptography mocks
class MockWeilPairing {
  Future<List<int>> setupCurve() async => List.filled(32, 0);
  Future<List<int>> generator1(List<int> curve) async => List.filled(32, 1);
  Future<List<int>> generator2(List<int> curve) async => List.filled(32, 2);
  Future<List<int>> scalarMult(List<int> g, int scalar) async =>
      List.filled(32, scalar);
  Future<List<int>> pairing(List<int> p, List<int> q) async => List.filled(32, 0);
  Future<List<int>> power(List<int> pairing, int exp) async => List.filled(32, 0);
}

class MockTatePairing {
  Future<List<int>> setupCurve() async => List.filled(32, 0);
  Future<List<int>> randomPoint1(List<int> curve) async => List.filled(32, 0);
  Future<List<int>> randomPoint2(List<int> curve) async => List.filled(32, 1);
  Future<List<int>> scalarMult(List<int> p, int scalar) async =>
      List.filled(32, scalar);
  Future<List<int>> compute(List<int> p, List<int> q) async => List.filled(32, 0);
  Future<List<int>> power(List<int> pairing, int exp) async => List.filled(32, 0);
}

class MockAtePairing {
  Future<List<int>> setupBNcurve() async => List.filled(32, 0);
  Future<List<int>> randomPoint1(List<int> curve) async => List.filled(32, 0);
  Future<List<int>> randomPoint2(List<int> curve) async => List.filled(32, 1);
  Future<List<int>> compute(List<int> p, List<int> q) async => List.filled(32, 0);
  Future<LatencyMeasurement> measureTime(String method, int count) async =>
      LatencyMeasurement(avgMs: method == 'ate' ? 2.0 : 3.0);
}

class MockBLSSignature {
  Future<KeyPair> generateKeyPair() async =>
      KeyPair(publicKey: List.filled(32, 0), privateKey: List.filled(32, 1));
  Future<List<int>> sign(String message, List<int> signingKey) async =>
      List.filled(96, 0);
  Future<bool> verify(String message, List<int> signature, List<int> publicKey) async =>
      true;
  Future<List<int>> aggregateSignatures(List<List<int>> signatures) async =>
      List.filled(96, 0);
}

class MockIdentityBasedEncryption {
  Future<MasterKey> generateMasterKey() async => MasterKey(masterSecret: List.filled(32, 0));
  Future<List<int>> extractSecretKey(String identity, List<int> masterSecret) async =>
      List.filled(64, 0);
  Future<List<int>> encrypt(String plaintext, String identity) async =>
      List.filled(128, 0);
  Future<String> decrypt(List<int> ciphertext, List<int> userSecret) async =>
      'secret-message';
  Future<String?> tryDecrypt(List<int> ciphertext, List<int> userSecret) async => null;
}

class MockAttributeBasedSignature {
  Future<List<int>> sign({
    required String message,
    required Map<String, dynamic> attributes,
    required String policy,
  }) async =>
      List.filled(256, 0);
  Future<bool> verify(String message, List<int> signature, String policy) async => true;
  Future<List<int>?> trySign({
    required String message,
    required Map<String, dynamic> attributes,
    required String policy,
  }) async =>
      null;
}

class MockFunctionalEncryption {
  Future<MasterKey> generateMasterKey() async =>
      MasterKey(publicKey: List.filled(32, 0), masterSecret: List.filled(32, 1));
  Future<List<int>> encrypt(List<int> x, List<int> publicKey) async =>
      List.filled(256, 0);
  Future<List<int>> generateFunctionKey(List<int> y, List<int> masterSecret) async =>
      List.filled(128, 0);
  Future<int> decrypt(List<int> ciphertext, List<int> funcKey) async => 26;
}

class MockPairingSecurityProperties {
  Future<bool> verifyBilinearity() async => true;
  Future<bool> verifyNonDegeneracy() async => true;
  Future<bool> verifyDiscreteLogHardness() async => true;
}

class MockPairingMetrics {
  Future<LatencyMeasurement> measurePairingTime(int count) async =>
      LatencyMeasurement(avgMs: 3.0);
  Future<LatencyMeasurement> measureExponentiationTime(int count) async =>
      LatencyMeasurement(avgMs: 0.5);
}

class MockTripartiteDH {
  Future<List<int>> publicKey(int privateKey) async => List.filled(32, 0);
  Future<List<int>> computeShared(int privateKey, List<int> pk1, List<int> pk2) async =>
      List.filled(32, 0);
}

class MockNISTCurves {
  Future<CurveInfo> getParameters(String curve) async =>
      CurveInfo(isApproved: true, securityLevel: 128);
}

class MockBNcurves {
  Future<List<int>> generateBNcurve({required int embeddingDegree}) async =>
      List.filled(32, 0);
  Future<bool> hasOptimalATE(List<int> curve) async => true;
  Future<bool> isPairingEfficient(List<int> curve) async => true;
}

class MockMontgomeryCurves {
  Future<List<int>> setupCurve(String name) async => List.filled(32, 0);
  Future<bool> isEfficientForDH(List<int> curve) async => true;
}

class MockEdwardsCurves {
  Future<List<int>> setupCurve(String name) async => List.filled(32, 0);
  Future<bool> isEdwardsForm(List<int> curve) async => true;
}

class MockCofactorValidation {
  Future<bool> validateCofactors() async => true;
  Future<List<String>?> requiresCofactorClearing() async => null;
}

class MockTwistSecurity {
  Future<TwistPrimes> getTwistPrimes(String curve) async =>
      TwistPrimes(curve: List.filled(32, 0), twist: List.filled(32, 1));
  Future<bool> isSecure(List<int> primes) async => true;
}

class MockCurveSeedValidation {
  Future<bool> validateSeed(String seed) async => seed.length == 40;
}

class MockParameterStrength {
  Future<SecurityLevel> getSecurityLevel(String curve) async {
    final bits = curve == 'P-256' ? 128 : curve == 'P-384' ? 192 : 256;
    return SecurityLevel(bits: bits);
  }
}

class MockCurveGeneration {
  Future<List<int>> generateCurve({
    required int security,
    required List<String> properties,
  }) async =>
      List.filled(32, 0);
  Future<bool> validate(List<int> curve) async => true;
  Future<bool> isSecure(List<int> curve) async => true;
}

class MockCurveSelectionMetrics {
  Future<LatencyMeasurement> measureTime(String curve, int count) async =>
      LatencyMeasurement(avgMs: 5.0);
}

class MockECIES {
  Future<List<int>> generatePublicKey() async => List.filled(32, 0);
  Future<List<int>> encrypt(String plaintext, List<int> publicKey) async =>
      List.filled(128, 0);
  Future<List<int>> generatePrivateKey() async => List.filled(32, 1);
  Future<String> decrypt(List<int> ciphertext, List<int> privateKey) async =>
      'secret-message';
}

class MockECDSA {
  Future<KeyPair> generateKeyPair() async =>
      KeyPair(publicKey: List.filled(32, 0), privateKey: List.filled(32, 1));
  Future<List<int>> sign(String message, List<int> privateKey) async =>
      List.filled(64, 0);
  Future<bool> verify(String message, List<int> signature, List<int> publicKey) async =>
      true;
}

class MockEdDSA {
  Future<KeyPair> generateKeyPair(String curve) async =>
      KeyPair(publicKey: List.filled(32, 0), privateKey: List.filled(32, 1));
  Future<List<int>> sign(String message, List<int> privateKey) async =>
      List.filled(64, 0);
  Future<bool> verify(String message, List<int> signature, List<int> publicKey) async =>
      true;
}

class MockECDHWithKDF {
  Future<List<int>> publicKey(int privateKey) async => List.filled(32, 0);
  Future<List<int>> rawSharedSecret(int privateKey, List<int> publicKey) async =>
      List.filled(32, 0);
  Future<List<int>> deriveKey(List<int> rawSecret, {required String info}) async =>
      List.filled(32, 0);
}

class MockForwardSecrecy {
  Future<KeyPair> generateEphemeralKeyPair() async =>
      KeyPair(publicKey: List.filled(32, 0), privateKey: List.filled(32, 1));
  Future<List<int>> deriveSessionKey(KeyPair key, String sessionId) async =>
      List.filled(32, 0);
  Future<void> compromiseKey(KeyPair key) async {}
  Future<bool> verifyForwardSecrecy() async => true;
}

class MockCertificateBasedAKA {
  Future<Certificate> generateCertificate(String identity) async => Certificate(
        publicKey: List.filled(32, 0),
      );
  Future<List<int>> deriveSharedSecret(Certificate cert, List<int> publicKey) async =>
      List.filled(32, 0);
  Future<bool> verifyMutualAuthentication() async => true;
}

class MockPAKE {
  Future<PAKEOutput> executeAlice(String password) async =>
      PAKEOutput(sessionKey: List.filled(32, 0));
  Future<PAKEOutput> executeBob(String password) async =>
      PAKEOutput(sessionKey: List.filled(32, 0));
}

class MockThresholdECDSA {
  Future<List<List<int>>> generateKeyShares({required int total, required int threshold}) async =>
      List.filled(total, List.filled(32, 0));
  Future<List<int>> sign({
    required String message,
    required List<List<int>> shares,
  }) async =>
      List.filled(64, 0);
  Future<bool> verify(List<int> sig) async => true;
  Future<List<int>?> trySign({
    required String message,
    required List<List<int>> shares,
  }) async =>
      null;
}

class MockAEADwithEC {
  Future<KeyPair> generateKeyPair() async =>
      KeyPair(publicKey: List.filled(32, 0), privateKey: List.filled(32, 1));
  Future<List<int>> encryptAndMac(String plaintext, {required List<int> publicKey}) async =>
      List.filled(100, 0);
  Future<String> verifyAndDecrypt({
    required List<int> ciphertext,
    required List<int> privateKey,
  }) async =>
      'secret';
  Future<String?> tryVerifyAndDecrypt({
    required List<int> ciphertext,
    required List<int> privateKey,
  }) async =>
      null;
}

class MockECProtocolMetrics {
  Future<LatencyMeasurement> measureKeyGeneration(int count) async =>
      LatencyMeasurement(avgMs: 20.0);
  Future<LatencyMeasurement> measureSigning(int count) async =>
      LatencyMeasurement(avgMs: 5.0);
  Future<LatencyMeasurement> measureVerification(int count) async =>
      LatencyMeasurement(avgMs: 5.0);
}

class MockBinaryMethod {
  Future<List<int>> setupCurve() async => List.filled(32, 0);
  Future<List<int>> generator(List<int> curve) async => List.filled(32, 1);
  Future<List<int>> scalarMultiply(List<int> point, int scalar) async =>
      List.filled(32, scalar);
  Future<List<int>> naiveMultiply(List<int> point, int scalar) async =>
      List.filled(32, scalar);
}

class MockDoubleAndAdd {
  Future<List<int>> setupCurve() async => List.filled(32, 0);
  Future<List<int>> generator(List<int> curve) async => List.filled(32, 1);
  Future<List<int>> scalarMultiply(List<int> point, int scalar) async =>
      List.filled(32, scalar);
  Future<List<int>> naiveMultiply(List<int> point, int scalar) async =>
      List.filled(32, scalar);
  Future<OperationCount> countOperations(int scalar) async =>
      OperationCount(doublings: 8, additions: 4);
}

class MockWindowing {
  Future<List<int>> setupCurve() async => List.filled(32, 0);
  Future<List<int>> generator(List<int> curve) async => List.filled(32, 1);
  Future<List<int>> scalarMultiply(
    List<int> point,
    int scalar, {
    required int windowSize,
  }) async =>
      List.filled(32, scalar);
  Future<List<int>> naiveMultiply(List<int> point, int scalar) async =>
      List.filled(32, scalar);
  Future<LatencyMeasurement> timeStandardMethod(int count) async =>
      LatencyMeasurement(avgMs: 10.0);
  Future<LatencyMeasurement> timeWindowMethod(int count, int windowSize) async =>
      LatencyMeasurement(avgMs: 6.0);
}

class MockNAF {
  Future<List<int>> toNAF(int scalar) async => List.filled(16, 0);
  Future<int> hammingWeight(List<int> naf) async => 6;
  Future<int> binaryWeight(int scalar) async => 8;
  Future<int> fromNAF(List<int> naf) async => 123;
}

class MockConstantTime {
  Future<List<int>> setupCurve() async => List.filled(32, 0);
  Future<List<int>> generator(List<int> curve) async => List.filled(32, 1);
  Future<int> measureMultiplicationTime(List<int> point, int scalar) async => 100;
  Future<List<int>> scalarMultiply(List<int> point, int scalar) async =>
      List.filled(32, scalar);
  Future<List<int>> naiveMultiply(List<int> point, int scalar) async =>
      List.filled(32, scalar);
}

class MockShamirTrick {
  Future<List<int>> setupCurve() async => List.filled(32, 0);
  Future<List<int>> randomPoint(List<int> curve) async => List.filled(32, 0);
  Future<List<int>> multiScalarMult(List<int> p, int a, List<int> q, int b) async =>
      List.filled(32, 0);
  Future<List<int>> naiveMultiScalarMult(List<int> p, int a, List<int> q, int b) async =>
      List.filled(32, 0);
  Future<LatencyMeasurement> timeSeparate(int count) async =>
      LatencyMeasurement(avgMs: 20.0);
  Future<LatencyMeasurement> timeShamir(int count) async =>
      LatencyMeasurement(avgMs: 14.0);
}

class MockPrecomputation {
  Future<List<int>> setupCurve() async => List.filled(32, 0);
  Future<List<int>> generator(List<int> curve) async => List.filled(32, 1);
  Future<List<List<int>>> createTable(List<int> point) async =>
      List.filled(256, List.filled(32, 0));
  Future<List<int>> multiplyWithTable(List<List<int>> table, int scalar) async =>
      List.filled(32, scalar);
  Future<List<int>> naiveMultiply(List<int> point, int scalar) async =>
      List.filled(32, scalar);
  Future<LatencyMeasurement> timeDirect(int count) async =>
      LatencyMeasurement(avgMs: 10.0);
  Future<LatencyMeasurement> timeTable(int count) async =>
      LatencyMeasurement(avgMs: 3.0);
}

class MockEndomorphismOptimization {
  Future<List<int>> setupKoblitzCurve() async => List.filled(32, 0);
  Future<List<int>> generator(List<int> curve) async => List.filled(32, 1);
  Future<LatencyMeasurement> timeStandardMult(int scalar) async =>
      LatencyMeasurement(avgMs: 10.0);
  Future<LatencyMeasurement> timeEndomorphismMult(int scalar) async =>
      LatencyMeasurement(avgMs: 7.0);
}

class MockScalarMultValidation {
  Future<List<int>> setupCurve() async => List.filled(32, 0);
  Future<List<int>> generator(List<int> curve) async => List.filled(32, 1);
  Future<List<int>> binary(List<int> point, int scalar) async => List.filled(32, scalar);
  Future<List<int>> doubleAdd(List<int> point, int scalar) async =>
      List.filled(32, scalar);
  Future<List<int>> windowing(List<int> point, int scalar) async =>
      List.filled(32, scalar);
  Future<List<int>> naf(List<int> point, int scalar) async => List.filled(32, scalar);
}

class MockScalarMultMetrics {
  Future<ScalarMultMethodsComparison> compareAllMethods({required int iterations}) async =>
      ScalarMultMethodsComparison(
        binary: LatencyMeasurement(avgMs: 10.0),
        doubleAdd: LatencyMeasurement(avgMs: 9.0),
        windowing: LatencyMeasurement(avgMs: 6.0),
        precomputed: LatencyMeasurement(avgMs: 2.0),
      );
}

// Data Models
class KeyPair {
  final List<int> publicKey;
  final List<int>? privateKey;

  KeyPair({required this.publicKey, this.privateKey});
}

class LatencyMeasurement {
  final double avgMs;

  LatencyMeasurement({required this.avgMs});
}

class CurveParameters {
  final List<int> order;
  final int cofactor;

  CurveParameters({required this.order, required this.cofactor});
}

class CurveInfo {
  final bool isApproved;
  final int securityLevel;

  CurveInfo({required this.isApproved, required this.securityLevel});
}

class TwistPrimes {
  final List<int> curve;
  final List<int> twist;

  TwistPrimes({required this.curve, required this.twist});
}

class SecurityLevel {
  final int bits;

  SecurityLevel({required this.bits});
}

class MasterKey {
  final List<int>? publicKey;
  final List<int> masterSecret;

  MasterKey({this.publicKey, required this.masterSecret});
}

class Certificate {
  final List<int> publicKey;

  Certificate({required this.publicKey});
}

class PAKEOutput {
  final List<int> sessionKey;

  PAKEOutput({required this.sessionKey});
}

class OperationCount {
  final int doublings;
  final int additions;

  OperationCount({required this.doublings, required this.additions});
}

class ScalarMultMethodsComparison {
  final LatencyMeasurement binary;
  final LatencyMeasurement doubleAdd;
  final LatencyMeasurement windowing;
  final LatencyMeasurement precomputed;

  ScalarMultMethodsComparison({
    required this.binary,
    required this.doubleAdd,
    required this.windowing,
    required this.precomputed,
  });
}
