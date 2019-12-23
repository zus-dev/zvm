import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:zvm/zvm.dart';

import '../helpers.dart';
import 'mini_zork_setup.dart';

class MockStatusLine extends Mock implements StatusLine {}

class MockScreenModel extends Mock implements ScreenModel {}

class MockSaveGameDataStore extends Mock implements SaveGameDataStore {}

class MockInputStream extends Mock implements InputStream {
  String name;

  MockInputStream(this.name);
}

class TestMemoryOutputStream extends MemoryOutputStream {
  int tableAddress;

  TestMemoryOutputStream(Machine machine) : super(machine);

  @override
  void selectWithTable(int table, int tableWidth) {
    tableAddress = table;
  }
}

void main() {
  final mz = MiniZorkSetup();
  MachineImpl machine;
  StoryFileHeader fileheader;

  MockOutputStream outputStream1, outputStream2, outputStream3;
  InputStream inputStream1, inputStream0;
  MockStatusLine statusLine;
  MockScreenModel screen;
  MockSaveGameDataStore datastore;

  setUp(() {
    mz.setUp();
    machine = mz.machine;
    fileheader = mz.fileheader;

    statusLine = MockStatusLine();
    screen = MockScreenModel();
    outputStream1 = MockOutputStream("outputStream1");
    outputStream2 = MockOutputStream("outputStream2");
    outputStream3 = MockOutputStream("outputStream3");

    inputStream0 = MockInputStream("inputStream0");
    inputStream1 = MockInputStream("inputStrean1");

    machine.setScreen(screen);

    machine.setOutputStream(Output.OUTPUTSTREAM_SCREEN, outputStream1);
    machine.setOutputStream(Output.OUTPUTSTREAM_TRANSCRIPT, outputStream2);
    machine.setOutputStream(Output.OUTPUTSTREAM_MEMORY, outputStream3);

    machine.setInputStream(Input.INPUTSTREAM_KEYBOARD, inputStream0);
    machine.setInputStream(Input.INPUTSTREAM_FILE, inputStream1);

    datastore = MockSaveGameDataStore();
  });

  test('InitialState', () {
    assertEquals(fileheader, machine.getFileHeader());
    assertTrue(machine.hasValidChecksum());
  });

  test('SetOutputStream', () {
    when(outputStream1.isSelected()).thenReturn(true);
    when(outputStream2.isSelected()).thenReturn(false);
    when(outputStream3.isSelected()).thenReturn(false);

    machine.selectOutputStream(1, true);
    machine.print("test");

    verify(outputStream1.select(true)).called(1);
    verify(outputStream2.select(false)).called(1);
    verify(outputStream1.isSelected()).called(greaterThan(0));
    verify(outputStream2.isSelected()).called(greaterThan(0));
    verify(outputStream3.isSelected()).called(greaterThan(0));
    verify(outputStream1.print(Char.of('t'))).called(2);
    verify(outputStream1.print(Char.of('e'))).called(1);
    verify(outputStream1.print(Char.of('s'))).called(1);
  });

  test('SelectOutputStream', () {
    machine.selectOutputStream(1, true);
    verify(outputStream1.select(true)).called(1);
  });

  test('InputStream1', () {
    machine.setInputStream(Input.INPUTSTREAM_KEYBOARD, inputStream0);
    machine.setInputStream(Input.INPUTSTREAM_FILE, inputStream1);
    machine.selectInputStream(Input.INPUTSTREAM_FILE);
    assertEquals(inputStream1, machine.getSelectedInputStream());
  });

  test('InputStream0', () {
    machine.setInputStream(Input.INPUTSTREAM_KEYBOARD, inputStream0);
    machine.setInputStream(Input.INPUTSTREAM_FILE, inputStream1);
    machine.selectInputStream(Input.INPUTSTREAM_KEYBOARD);
    assertEquals(inputStream0, machine.getSelectedInputStream());
  });

  test('Random', () {
    final random1 = machine.random(23).toInt();
    assertTrue(0 < random1 && random1 <= 23);
    assertEquals(0, machine.random(0));

    final random2 = machine.random(23).toInt();
    assertTrue(0 < random2 && random2 <= 23);
    assertEquals(0, machine.random(-23));

    final random3 = machine.random(23).toInt();
    assertTrue(0 < random3 && random3 <= 23);
  });

  test('Random1', () {
    Char value;
    for (int i = 0; i < 10; i++) {
      value = machine.random(1);
      assertEquals(value, 1);
    }
  });

  test('Random2', () {
    int value;
    bool contains1 = false;
    bool contains2 = false;
    for (int i = 0; i < 10; i++) {
      value = machine.random(2).toInt();
      assertTrue(0 < value && value <= 2);
      if (value == 1) contains1 = true;
      if (value == 2) contains2 = true;
    }
    assertTrue(contains1);
    assertTrue(contains2);
  });

  test('StartQuit', () {
    when(outputStream1.isSelected()).thenReturn(true);
    when(outputStream2.isSelected()).thenReturn(false);
    when(outputStream3.isSelected()).thenReturn(false);

    machine.start();
    assertEquals(MachineRunState.RUNNING, machine.getRunState());
    machine.quit();
    assertEquals(MachineRunState.STOPPED, machine.getRunState());

    verify(outputStream2.select(false)).called(1);
    verify(outputStream1.isSelected()).called(greaterThan(0));
    verify(outputStream2.isSelected()).called(greaterThan(0));
    verify(outputStream3.isSelected()).called(greaterThan(0));
    verify(outputStream1.print(any)).called(greaterThan(0));
    verify(outputStream1.flush()).called(greaterThan(0));
    verify(outputStream1.close()).called(1);
    verify(outputStream2.flush()).called(greaterThan(0));
    verify(outputStream2.close()).called(1);
    verify(outputStream3.flush()).called(greaterThan(0));
    verify(outputStream3.close()).called(1);
    verify(inputStream0.close()).called(1);
    verify(inputStream1.close()).called(1);
  });

  test('StatusLineScore', () {
    machine.setVariable(Char(0x10), Char(2));
    machine.setStatusLine(statusLine);
    machine.updateStatusLine();
    verify(statusLine.updateStatusScore(any, any, any)).called(1);
  });

  test('StatusLineTime', () {
    machine.setVariable(Char(0x10), Char(2));
    machine.setStatusLine(statusLine); // set the "time" flag
    machine.writeUnsigned8(1, Char(2));
    machine.updateStatusLine();

    verify(statusLine.updateStatusTime(any, any, any)).called(1);
  });

  test('GetSetScreen', () {
    machine.setScreen(screen);
    assertTrue(screen == machine.getScreen());
  });

  test('Halt', () {
    when(outputStream1.isSelected()).thenReturn(true);
    when(outputStream2.isSelected()).thenReturn(false);
    when(outputStream3.isSelected()).thenReturn(false);

    machine.start();
    assertEquals(MachineRunState.RUNNING, machine.getRunState());
    machine.halt("error");
    assertEquals(MachineRunState.STOPPED, machine.getRunState());

    verify(outputStream2.select(false)).called(1);
    verify(outputStream1.isSelected()).called(greaterThan(0));
    verify(outputStream2.isSelected()).called(greaterThan(0));
    verify(outputStream3.isSelected()).called(greaterThan(0));
    verify(outputStream1.print(any)).called(greaterThan(0));
  });

  test('Restart', () {
    machine.restart();

    verify(outputStream1.flush()).called(1);
    verify(outputStream2.flush()).called(1);
    verify(outputStream3.flush()).called(1);
    verify(screen.reset()).called(1);
  });

  test('Save', () {
    when(datastore.saveFormChunk(any)).thenReturn(true);
    machine.setSaveGameDataStore(datastore);
    assertTrue(machine.save(4711));
    verify(datastore.saveFormChunk(any)).called(1);
  });

  test('SelectTranscriptOutputStream', () {
    machine.selectOutputStream(Output.OUTPUTSTREAM_TRANSCRIPT, true);
    assertTrue(machine.getFileHeader().isEnabled(Attribute.TRANSCRIPTING));
    verify(outputStream2.select(true)).called(1);
  });

  test('SelectMemoryOutputStreamWithoutTable', () {
    when(outputStream1.isSelected()).thenReturn(true);
    when(outputStream2.isSelected()).thenReturn(false);
    when(outputStream3.isSelected()).thenReturn(false);

    machine.selectOutputStream(Output.OUTPUTSTREAM_MEMORY, true);

    verify(outputStream2.select(false)).called(greaterThan(0));
    verify(outputStream3.select(true)).called(1);
    verify(outputStream1.isSelected()).called(1);
    verify(outputStream2.isSelected()).called(greaterThan(0));
    verify(outputStream3.isSelected()).called(greaterThan(0));
    // error message
    verify(outputStream1.print(any)).called(greaterThan(0));
  });

  test('SelectMemoryOutputStreamWithTable', () {
    final memstream = TestMemoryOutputStream(machine);
    machine.setOutputStream(Output.OUTPUTSTREAM_MEMORY, memstream);
    machine.selectOutputStream3(4711, 0);

    assertEquals(4711, memstream.tableAddress);
  });
}
