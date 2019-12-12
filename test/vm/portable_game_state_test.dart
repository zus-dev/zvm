import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:zvm/zvm.dart';

import '../helpers.dart';

int decodePcBytes(Char b0, Char b1, Char b2) {
  return ((b0.toInt() & 0xff) << 16) |
      ((b1.toInt() & 0xff) << 8) |
      (b2.toInt() & 0xff);
}

void main() {
  PortableGameState gameState;
  FormChunk formChunk;
  MockMachine machine;
  MockStoryFileHeader fileheader;
  ByteArray savedata;

  setUp(() {
    machine = MockMachine();
    fileheader = MockStoryFileHeader();
    savedata = readTestFileAsByteArray('leathersave.ifzs');
    final memaccess = DefaultMemory(savedata);
    formChunk = DefaultFormChunk(memaccess);
    gameState = PortableGameState();
  });

  final pcs = [0, 25108, 25132, 25377, 26137, 26457, 26499];
  final retvars = [0, 0, 1, 7, 0, 4, 0];
  final localLengths = [0, 1, 11, 2, 7, 4, 0];
  final stackSizes = [4, 0, 0, 0, 2, 0, 0];
  final numArgs = [0, 1, 4, 2, 4, 4, 0];

  test('ReadSaveGame', () {
    assertTrue(gameState.readSaveGame(formChunk));
    assertEquals(59, gameState.getRelease());
    assertEquals("860730", gameState.getSerialNumber());
    assertEquals(53360, gameState.getChecksum());
    assertEquals(35298, gameState.getProgramCounter());

    assertEquals(7, gameState.getStackFrames().length);

    for (int i = 0; i < gameState.getStackFrames().length; i++) {
      StackFrame sfi = gameState.getStackFrames()[i];
      assertEquals(pcs[i], sfi.getProgramCounter());
      assertEquals(retvars[i], sfi.getReturnVariable());
      assertEquals(localLengths[i], sfi.getLocals().length);
      assertEquals(stackSizes[i], sfi.getEvalStack().length);
      assertEquals(numArgs[i], sfi.getArgs().length);
    }
    assertEquals(10030, gameState.getDeltaBytes().length);
  });

  test('ReadSaveGameFormChunkIsNull', () {
    assertFalse(gameState.readSaveGame(null));
  });

  test('GetStackFrameStatusVars', () {
    StackFrame stackFrame = StackFrame();
    stackFrame.setProgramCounter(4711);
    assertEquals(4711, stackFrame.getProgramCounter());
    stackFrame.setReturnVariable(Char(5));
    assertEquals(5, stackFrame.getReturnVariable());
  });

  test('CaptureMachineState', () {
    final List<RoutineContext> emptyContexts = List<RoutineContext>();

    // Expectations

    when(machine.getFileHeader()).thenReturn(fileheader);
    when(machine.getRoutineContexts()).thenReturn(emptyContexts);
    when(machine.getSP()).thenReturn(Char(4));
    when(machine.getStackElement(argThat(isNotNull))).thenReturn(Char(42));
    when(machine.getRelease()).thenReturn(42);
    when(machine.readUnsigned16(StoryFileHeader.CHECKSUM))
        .thenReturn(Char(4712));
    when(machine.readUnsigned16(StoryFileHeader.STATIC_MEM))
        .thenReturn(Char(12345));
    when(fileheader.getSerialNumber()).thenReturn("850101");
    // when(machine.copyBytesToArray(argThat(isNotNull), 0, 0, 12345));
    when(machine.readUnsigned8(argThat(isNotNull))).thenReturn(Char(0));

    gameState.captureMachineState(machine, 4711);
    assertEquals(4711, gameState.getProgramCounter());
    assertEquals(42, gameState.getRelease());
    assertEquals(4712, gameState.getChecksum());
    assertEquals("850101", gameState.getSerialNumber());
    assertEquals(12345, gameState.getDynamicMemoryDump().length);
    assertEquals(1, gameState.getStackFrames().length);
    StackFrame stackFrame = gameState.getStackFrames()[0];
    assertEquals(4, stackFrame.getEvalStack().length);

    verify(machine.getFileHeader()).called(greaterThan(0));
    verify(machine.getRoutineContexts()).called(1);
    verify(machine.getSP()).called(1);
    verify(machine.getRelease()).called(1);
    verify(machine.readUnsigned16(StoryFileHeader.CHECKSUM)).called(1);
    verify(machine.readUnsigned16(StoryFileHeader.STATIC_MEM)).called(1);
    verify(fileheader.getSerialNumber()).called(1);
  });

  test('ExportToFormChunk', () {
    List<Char> dummyStack = [Char(1), Char(2), Char(3)];
    StackFrame dummyFrame = StackFrame();
    dummyFrame.setArgs(List<Char>(0));
    dummyFrame.setEvalStack(dummyStack);
    dummyFrame.setLocals(List<Char>(0));

    ByteArray dynamicMem = ByteArray.length(99);
    dynamicMem[35] = 12;
    dynamicMem[49] = 13;
    dynamicMem[51] = 21;
    dynamicMem[72] = 72;
    dynamicMem[98] = 1;

    gameState.setRelease(42);
    gameState.setChecksum(4712);
    gameState.setSerialNumber("850101");
    gameState.setDynamicMem(dynamicMem);
    gameState.setProgramCounter(4711);
    gameState.getStackFrames().add(dummyFrame);

    // Export our mock machine to a FormChunk verify some basic information
    WritableFormChunk exportFormChunk = gameState.exportToFormChunk();
    assertEquals("FORM", exportFormChunk.getId());
    assertEquals(156, exportFormChunk.getSize());
    assertEquals("IFZS", exportFormChunk.getSubId());
    assertNotNull(exportFormChunk.getSubChunk("IFhd"));
    assertNotNull(exportFormChunk.getSubChunk("UMem"));
    assertNotNull(exportFormChunk.getSubChunk("Stks"));

    // Read IFhd information
    Chunk ifhdChunk = exportFormChunk.getSubChunk("IFhd");
    Memory memaccess = ifhdChunk.getMemory();
    assertEquals(13, ifhdChunk.getSize());
    assertEquals(gameState.getRelease(), memaccess.readUnsigned16(8));
    ByteArray serial = ByteArray.length(6);
    memaccess.copyBytesToArray(serial, 0, 10, 6);
    assertArraysEquals(
        ByteArray.fromString(gameState.getSerialNumber()), serial);
    assertEquals(gameState.getChecksum(), memaccess.readUnsigned16(16));
    assertEquals(
        gameState.getProgramCounter(),
        decodePcBytes(memaccess.readUnsigned8(18), memaccess.readUnsigned8(19),
            memaccess.readUnsigned8(20)));

    // Read the UMem information
    Chunk umemChunk = exportFormChunk.getSubChunk("UMem");
    memaccess = umemChunk.getMemory();
    assertEquals(dynamicMem.length, umemChunk.getSize());
    for (int i = 0; i < dynamicMem.length; i++) {
      assertEquals(dynamicMem[i], memaccess.readUnsigned8(8 + i));
    }

    // Read the Stks information
    Chunk stksChunk = exportFormChunk.getSubChunk("Stks");
    memaccess = stksChunk.getMemory();

    // There is only one frame at the moment
    assertEquals(14, stksChunk.getSize());
    int retpc0 = decodePcBytes(memaccess.readUnsigned8(8),
        memaccess.readUnsigned8(9), memaccess.readUnsigned8(10));
    assertEquals(0, retpc0);
    assertEquals(0, memaccess.readUnsigned8(11)); // pv flags
    assertEquals(0, memaccess.readUnsigned8(12)); // retvar
    assertEquals(0, memaccess.readUnsigned8(13)); // argspec
    assertEquals(3, memaccess.readUnsigned16(14)); // stack size
    assertEquals(1, memaccess.readUnsigned16(16)); // stack val 0
    assertEquals(2, memaccess.readUnsigned16(18)); // stack val 1
    assertEquals(3, memaccess.readUnsigned16(20)); // stack val 2

    // Now read the form chunk into another gamestate and compare
    PortableGameState gameState2 = PortableGameState();
    gameState2.readSaveGame(exportFormChunk);
    assertEquals(gameState.getRelease(), gameState2.getRelease());
    assertEquals(gameState.getChecksum(), gameState2.getChecksum());
    assertEquals(gameState.getSerialNumber(), gameState2.getSerialNumber());
    assertEquals(gameState.getProgramCounter(), gameState2.getProgramCounter());
    assertEquals(
        gameState.getStackFrames().length, gameState2.getStackFrames().length);
    StackFrame dummyFrame1 = gameState.getStackFrames()[0];
    StackFrame dummyFrame2 = gameState2.getStackFrames()[0];
    assertEquals(
        dummyFrame1.getProgramCounter(), dummyFrame2.getProgramCounter());
    assertEquals(
        dummyFrame1.getReturnVariable(), dummyFrame2.getReturnVariable());
    assertEquals(0, dummyFrame2.getArgs().length);
    assertEquals(0, dummyFrame2.getLocals().length);
    assertEquals(3, dummyFrame2.getEvalStack().length);

    // Convert to byte array and reconstruct
    // This is in fact a test for WritableFormChunk and should be put
    // in a separate test
    ByteArray data = exportFormChunk.getBytes();
    FormChunk formChunk2 = DefaultFormChunk(DefaultMemory(data));
    assertEquals("FORM", formChunk2.getId());
    assertEquals("IFZS", formChunk2.getSubId());
    assertEquals(exportFormChunk.getSize(), formChunk2.getSize());

    // IFhd chunk
    Chunk ifhd2 = formChunk2.getSubChunk("IFhd");
    assertEquals(13, ifhd2.getSize());
    Memory ifhd1mem = exportFormChunk.getSubChunk("IFhd").getMemory();
    Memory ifhd2mem = ifhd2.getMemory();
    for (int i = 0; i < 21; i++) {
      assertEquals(ifhd2mem.readUnsigned8(i), ifhd1mem.readUnsigned8(i));
    }

    // UMem chunk
    Chunk umem2 = formChunk2.getSubChunk("UMem");
    assertEquals(dynamicMem.length, umem2.getSize());
    Memory umem1mem = exportFormChunk.getSubChunk("UMem").getMemory();
    Memory umem2mem = umem2.getMemory();
    for (int i = 0; i < umem2.getSize() + Chunk.CHUNK_HEADER_LENGTH; i++) {
      assertEquals(umem2mem.readUnsigned8(i), umem1mem.readUnsigned8(i));
    }

    // Stks chunk
    Chunk stks2 = formChunk2.getSubChunk("Stks");
    assertEquals(14, stks2.getSize());
    Memory stks1mem = exportFormChunk.getSubChunk("Stks").getMemory();
    Memory stks2mem = stks2.getMemory();
    for (int i = 0; i < stks2.getSize() + Chunk.CHUNK_HEADER_LENGTH; i++) {
      assertEquals(stks2mem.readUnsigned8(i), stks1mem.readUnsigned8(i));
    }
  });

  test('ReadStackFrameFromChunkDiscardResult', () {
    // PC
    when(machine.readUnsigned8(0)).thenReturn(Char(0x00));
    when(machine.readUnsigned8(1)).thenReturn(Char(0x12));
    when(machine.readUnsigned8(2)).thenReturn(Char(0x20));
    // Return variable/locals flag: discard result/3 locals (0x13)
    when(machine.readUnsigned8(3)).thenReturn(Char(0x13));
    // return variable is always 0 if discard result
    when(machine.readUnsigned8(4)).thenReturn(Char(0x00));
    // supplied arguments, we define a and b
    when(machine.readUnsigned8(5)).thenReturn(Char(0x03));
    // stack size, we define 2
    when(machine.readUnsigned16(6)).thenReturn(Char(2));
    // local variables
    for (int i = 0; i < 3; i++) {
      when(machine.readUnsigned16(8 + i * 2)).thenReturn(Char(i));
    }
    // stack variables
    for (int i = 0; i < 2; i++) {
      when(machine.readUnsigned16(8 + 6 + i * 2)).thenReturn(Char(i));
    }
    StackFrame stackFrame = StackFrame();
    PortableGameState gamestate = PortableGameState();
    gamestate.readStackFrame(stackFrame, machine, 0);
    assertEquals(0x1220, stackFrame.getProgramCounter());
    assertEquals(
        PortableGameState.DISCARD_RESULT, stackFrame.getReturnVariable());
    assertEquals(3, stackFrame.getLocals().length);
    assertEquals(2, stackFrame.getEvalStack().length);
    assertEquals(2, stackFrame.getArgs().length);

    // PC
    verify(machine.readUnsigned8(0)).called(1);
    verify(machine.readUnsigned8(1)).called(1);
    verify(machine.readUnsigned8(2)).called(1);
    // Return variable/locals flag: discard result/3 locals (0x13)
    verify(machine.readUnsigned8(3)).called(1);
    // return variable is always 0 if discard result
    verify(machine.readUnsigned8(4)).called(1);
    // supplied arguments, we define a and b
    verify(machine.readUnsigned8(5)).called(1);
    // stack size, we define 2
    verify(machine.readUnsigned16(6)).called(1);
    // local variables
    for (int i = 0; i < 3; i++) {
      verify(machine.readUnsigned16(8 + i * 2)).called(1);
    }
    // stack variables
    for (int i = 0; i < 2; i++) {
      verify(machine.readUnsigned16(8 + 6 + i * 2)).called(1);
    }
  });

  test('ReadStackFrameFromChunkWithReturnVar', () {
    // PC
    when(machine.readUnsigned8(0)).thenReturn(Char(0x00));
    when(machine.readUnsigned8(1)).thenReturn(Char(0x12));
    when(machine.readUnsigned8(2)).thenReturn(Char(0x21));
    // Return variable/locals flag: has return value/2 locals (0x02)
    when(machine.readUnsigned8(3)).thenReturn(Char(0x02));
    // return variable is 5
    when(machine.readUnsigned8(4)).thenReturn(Char(0x05));
    // supplied arguments, we define a, b and c
    when(machine.readUnsigned8(5)).thenReturn(Char(0x07));
    // stack size, we define 3
    when(machine.readUnsigned16(6)).thenReturn(Char(3));
    // local variables
    for (int i = 0; i < 2; i++) {
      when(machine.readUnsigned16(8 + i * 2)).thenReturn(Char(i));
    }
    // stack variables
    for (int i = 0; i < 3; i++) {
      when(machine.readUnsigned16(8 + 4 + i * 2)).thenReturn(Char(i));
    }

    StackFrame stackFrame = StackFrame();
    PortableGameState gamestate = PortableGameState();
    gamestate.readStackFrame(stackFrame, machine, 0);
    assertEquals(0x1221, stackFrame.getProgramCounter());
    assertEquals(5, stackFrame.getReturnVariable());
    assertEquals(2, stackFrame.getLocals().length);
    assertEquals(3, stackFrame.getEvalStack().length);
    assertEquals(3, stackFrame.getArgs().length);

    // PC
    verify(machine.readUnsigned8(0)).called(1);
    verify(machine.readUnsigned8(1)).called(1);
    verify(machine.readUnsigned8(2)).called(1);
    // Return variable/locals flag: has return value/2 locals (0x02)
    verify(machine.readUnsigned8(3)).called(1);
    // return variable is 5
    verify(machine.readUnsigned8(4)).called(1);
    // supplied arguments, we define a, b and c
    verify(machine.readUnsigned8(5)).called(1);
    // stack size, we define 3
    verify(machine.readUnsigned16(6)).called(1);
    // local variables
    for (int i = 0; i < 2; i++) {
      verify(machine.readUnsigned16(8 + i * 2)).called(1);
    }
    // stack variables
    for (int i = 0; i < 3; i++) {
      verify(machine.readUnsigned16(8 + 4 + i * 2)).called(1);
    }
  });

  test('WriteStackFrameToChunkDiscardResult', () {
    final List<int> byteBuffer = List<int>();
    final List<int> byteBufferExpected = [
      // pc
      0x00, 0x12, 0x20,
      // pvflag
      0x11,
      // return var
      0x00,
      // argspec
      0x03,
      // stack size
      0x00, 0x02,
      // locals
      0x00, 0x01,
      // stack
      0x00, 0x05, 0x00, 0x06,
    ];

    List<Char> args = [Char(0), Char(1)];
    List<Char> locals = [Char(1)];
    List<Char> stack = [Char(5), Char(6)];

    StackFrame stackFrame = StackFrame();
    stackFrame.setProgramCounter(0x1220);
    stackFrame.setReturnVariable(PortableGameState.DISCARD_RESULT);
    stackFrame.setArgs(args);
    stackFrame.setLocals(locals);
    stackFrame.setEvalStack(stack);

    PortableGameState gamestate = PortableGameState();
    gamestate.writeStackFrameToByteBuffer(byteBuffer, stackFrame);
    assertArraysEquals(byteBufferExpected, byteBuffer);
  });

  test('WriteStackFrameToChunkWithReturnVar', () {
    final List<int> byteBuffer = List<int>();
    final List<int> byteBufferExpected = [
      // pc
      0x00, 0x12, 0x21,
      // pvflag
      0x01,
      // return var
      0x06,
      // argspec
      0x03,
      // stack size
      0x00, 0x02,
      // locals
      0x00, 0x01,
      // stack
      0x00, 0x05, 0x00, 0x06,
    ];

    List<Char> args = [Char(0), Char(1)];
    List<Char> locals = [Char(1)];
    List<Char> stack = [Char(5), Char(6)];

    StackFrame stackFrame = StackFrame();
    stackFrame.setProgramCounter(0x1221);
    stackFrame.setReturnVariable(Char(6));
    stackFrame.setArgs(args);
    stackFrame.setLocals(locals);
    stackFrame.setEvalStack(stack);

    PortableGameState gamestate = PortableGameState();
    gamestate.writeStackFrameToByteBuffer(byteBuffer, stackFrame);

    assertArraysEquals(byteBufferExpected, byteBuffer);
  });
}
