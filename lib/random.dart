import 'package:zvm/d_random.dart';

class Random {
  DRandom _rnd;

  Random() {
    _rnd = DRandom();
  }

  void setSeed(int seed) {
    _rnd = DRandom.withSeed(seed);
  }

  int nextInt() {
    return _rnd.Next();
  }
}