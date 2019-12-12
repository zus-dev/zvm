import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:zvm/zvm.dart';

import '../helpers.dart';

class TestDefaultDictionary extends DefaultDictionary {
  ByteArray get;
  ByteArray oops;

  TestDefaultDictionary(Memory memory, int address, ZCharDecoder decoder,
      ZCharEncoder encoder, DictionarySizes sizes)
      : super(memory, address, decoder, encoder, sizes);

  @override
  ByteArray truncateTokenToBytes(String token) {
    // just two words are used, 'get' and 'nonsense'
    if ("get" == token) return get;
    return oops;
  }
}

void main() {
  MockMemory memory;
  Dictionary dictionary;
  MockZCharDecoder decoder;
  MockZCharEncoder encoder;

  setUp(() {
    memory = MockMemory();
    decoder = MockZCharDecoder();
    encoder = MockZCharEncoder();

    // num separators
    when(memory.readUnsigned8(1000)).thenReturn(Char(3));
    // num entries
    when(memory.readUnsigned16(1005)).thenReturn(Char(2));
    // entry size
    when(memory.readUnsigned8(1004)).thenReturn(Char(4));

    dictionary = DefaultDictionary(
        memory, 1000, decoder, encoder, DictionarySizesV1ToV3());
  });

  tearDown(() {
    // num separators
    // verify(memory.readUnsigned8(1000)).called(greaterThan(0));
    // num entries
    // verify(memory.readUnsigned16(1005)).called(greaterThan(0));
    // entry size
    // verify(memory.readUnsigned8(1004)).called(greaterThan(0));
  });

  test('GetNumSeparators', () {
    assertEquals(3, dictionary.getNumberOfSeparators());
  });

  test('GetNumEntries', () {
    assertEquals(2, dictionary.getNumberOfEntries());
  });

  test('GetEntryLength', () {
    assertEquals(4, dictionary.getEntryLength());
  });

  test('GetEntryAddress', () {
    assertEquals(1011, dictionary.getEntryAddress(1));
  });

  test('GetSeparator', () {
    when(memory.readUnsigned8(1001)).thenReturn(Char.of('.'));
    assertEquals('.', Char(dictionary.getSeparator(0)));
    verify(memory.readUnsigned8(1001)).called(1);
  });

  test('Lookup', () {
    final get = ByteArray([0x31, 0x59, 0x94, 0xa5]);
    final look = ByteArray([0x46, 0x94, 0xc0, 0xa5]);
    final oops = ByteArray([0x52, 0x95, 0xe0, 0xa5]);
    final dictionary = TestDefaultDictionary(
        memory, 1000, decoder, encoder, DictionarySizesV1ToV3());
    dictionary.get = get;
    dictionary.oops = oops;

    for (int i = 0; i < 4; i++) {
      // 'get'
      when(memory.readUnsigned8(1007 + i)).thenReturn(Char(get[i]));
      // 'look'
      when(memory.readUnsigned8(1011 + i)).thenReturn(Char(look[i]));
    }

    assertEquals(1007, dictionary.lookup("get"));
    assertEquals(0, dictionary.lookup("oops"));
  });
}
