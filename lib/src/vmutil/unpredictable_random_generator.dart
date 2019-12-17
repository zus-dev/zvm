import 'dart:math';

import '../../zvm.dart';

/// This class implements the "random" random number generator mentioned
/// in the Z-machine standard document.
class UnpredictableRandomGenerator implements RandomGenerator {
  Random rand;

  UnpredictableRandomGenerator() {
    rand = Random( DateTime.now().millisecondsSinceEpoch);
  }

  @override
  int next() { return rand.nextInt(RandomGenerator.MAX_VALUE - 1) + 1; }
}
