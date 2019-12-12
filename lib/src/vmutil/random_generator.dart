/// This interface defines the functions of a random number generator within
/// the Z machine.
abstract class RandomGenerator {
  /// The maximum generated value.
  int MAX_VALUE = 32767;

  /// Returns the next random value between 1 and MAX_VALUE.
  int next();
}
