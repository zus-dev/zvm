import 'package:zvm/z_machine.dart';
import 'package:zvm/stack.dart';
import 'package:zvm/z_header.dart';
import 'package:zvm/z_state_header.dart';

class ZState {
  static final int QUETZAL_PROCEDURE = 0x10;

	ZMachine zm;
	Stack zstack;
	ZHeader header;
	int pc;
	List<int> dyn; //dyn - dynamic
	List<int> locals;
	int argcount;

  ZState(ZMachine zm) {
		this.zm = zm;
	}

  void save_current() {
    int dyn_size;

		header = ZStateHeader(zm.memory_image);
		dyn_size = header.static_base();
    /*
		 * clones the stack but not the Integers within. Fortunately they are
		 * immutable. But the arrays aren't, so don't mess with them
		 */
		zstack = zm.zstack.clone();
    // ...
    // TODO: Implement me
  }
  // TODO: Implement me
}