import 'dart:math';

import '../../zvm.dart';

/// This class implements the predictable random number generator mentioned
/// in the Z machine standards document. It takes a seed and generates the
/// same sequence of numbers for equal seeds.
class PredictableRandomGenerator implements RandomGenerator {
  Random _rand;

  PredictableRandomGenerator(int seed) {
    _rand = Random(seed);
  }

  @override
  int next() {
    return _rand.nextInt(RandomGenerator.MAX_VALUE - 1) + 1;
  }
}
