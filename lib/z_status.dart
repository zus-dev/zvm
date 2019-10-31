import 'dart:core';

class ZStatus {
	bool timegame;
	String location;
	int score;
	int turns;
	int hours;
	int minutes;
	
	StringBuffer buffer;

	ZStatus() {
		buffer = new StringBuffer();
	}

	void update_score_line(String location, int score, int turns) {
		this.timegame = false;
		this.location = location;
		this.score = score;
		this.turns = turns;
	}

	void update_time_line(String location, int hours, int minutes) {
		this.timegame = true;
		this.location = location;
		this.hours = hours;
		this.minutes = minutes;
	}
	
	String toString() {
		// FIXME: Yes, this should be properly formated and localized, but since
		// there are only a handful Z3 games, this is very low priority.
		buffer.clear();
		buffer.write(location);
		buffer.write("                ");
		if (timegame) {
			if (hours<10) {
				buffer.write("0");
			}
			buffer.write(hours);
			buffer.write(":");
			buffer.write(minutes);
		}
		else {
			buffer.write("Score: ");
			buffer.write(score);
			buffer.write(" Turn: ");
			buffer.write(turns);
		}
		
		return buffer.toString();
	}
}