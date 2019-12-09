/// This interface defines the Z machine's status line.
abstract class StatusLine {
  /// Updates the status of a score game.
  void updateStatusScore(String objectName, int score, int steps);

  /// Updates the status of a time game.
  void updateStatusTime(String objectName, int hours, int minutes);
}
