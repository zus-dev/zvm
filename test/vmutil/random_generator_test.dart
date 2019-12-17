import 'package:test/test.dart';
import 'package:zvm/zvm.dart';

import '../helpers.dart';

void main() {
  RandomGenerator predictable1, predictable2, random1, random2;

  setUp(() {
    int seed = 4711;
    predictable1 = PredictableRandomGenerator(seed);
    predictable2 = PredictableRandomGenerator(seed);
    random1 = UnpredictableRandomGenerator();
    random2 = UnpredictableRandomGenerator();
  });

  test('UnpredictableRandomSequence', () {
    int rnd1 = random1.next();
    int rnd2 = random1.next();
    assertNotSame(rnd1, rnd2);
    assertTrue(1 <= rnd1 && rnd1 <= RandomGenerator.MAX_VALUE);
  });

  test('UnpredictableRandomDifferentSequences', () {
    int rnd11 = random1.next();
    int rnd12 = random1.next();
    int rnd21 = random2.next();
    int rnd22 = random2.next();

    assertNotSame(rnd11, rnd12);
    assertNotSame(rnd21, rnd22);
  });

  test('PredictableRandomSequence', () {
    int rnd1 = predictable1.next();
    int rnd2 = predictable1.next();
    assertNotSame(rnd1, rnd2);
    assertTrue(1 <= rnd1 && rnd1 <= RandomGenerator.MAX_VALUE);
  });

  test('PredictableSameSequences', () {
    int rnd11 = predictable1.next();
    int rnd12 = predictable1.next();
    int rnd21 = predictable2.next();
    int rnd22 = predictable2.next();
    assertEquals(rnd11, rnd21);
    assertEquals(rnd12, rnd22);
  });
}
