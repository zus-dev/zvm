import 'dart:ffi';
import 'dart:typed_data';

import 'package:zvm/utils.dart';
import 'package:zvm/z_machine.dart';
import 'package:zvm/stack.dart';
import 'package:zvm/z_header.dart';
import 'package:zvm/z_machine_5.dart';
import 'package:zvm/z_state_header.dart';

class ZState {
  static final int QUETZAL_PROCEDURE = 0x10;

	ZMachine zm;
	Stack zstack;
	ZHeader header;
	int pc = 0;
	Uint8List dyn; 
	Uint16List locals; // short
	int argcount = 0;

  ZState(ZMachine zm) {
		this.zm = zm;
	}

  void save_current() {
    int dyn_size;

		header = ZStateHeader(zm.memory_image);
		dyn_size = header.static_base();
    /*
     * TODO: Seems like this is not valid anymore
		 * clones the stack but not the Integers within. Fortunately they are
		 * immutable. But the arrays aren't, so don't mess with them
		 */
		zstack = zm.zstack.clone();
    dyn = Uint8List(dyn_size);
    arrayCopy(zm.memory_image, 0, dyn, 0, dyn_size);
    locals = Uint16List.fromList(zm.locals);
    header = ZStateHeader(dyn);
    pc = zm.pc;
    if (header.version() > 3)
			argcount = (zm as ZMachine5).argcount;
  }

  void restore_saved() {
		arrayCopy(dyn, 0, zm.memory_image, 0, dyn.length);
		zm.locals = Uint16List(locals.length);
		arrayCopy(locals, 0, zm.locals, 0, locals.length);
		zm.zstack = zstack.clone();
		zm.pc = pc;
		if (header.version() > 3)
			(zm as ZMachine5).argcount = argcount;
	}

  // TODO: Implement me
}