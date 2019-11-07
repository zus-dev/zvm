/// This interface indicates that objects implementing it can interrupt
/// their current execution temporarily, executing the given routine and
/// returning to the former execution after finishing with that routine.
abstract class Interruptable {

  /// Indicates to the receiver that a interrupt should be started.
  void setInterruptRoutine(int routineAddress);
}