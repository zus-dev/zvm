import 'package:test/test.dart';
import 'package:zvm/zvm.dart';

import '../helpers.dart';

void main() {
  ZCharEncoder encoderV4;
  int sourceAddress = 100;
  int targetAddress = 199;
  var data = ByteArray.length(206);
  Memory realmem;

  setUp(() {
    AlphabetTable alphabetTable = DefaultAlphabetTable();
    ZCharTranslator translator = DefaultZCharTranslator(alphabetTable);
    //encoderV1 = new ZCharEncoder(translator, new DictionarySizesV1ToV3());
    encoderV4 = ZCharEncoder(translator, DictionarySizesV4ToV8());
    realmem = DefaultMemory(data);
  });

  /**
   * A single character to be encoded. We need to make sure it is in lower
   * case and the string is padded out with shift characters.
   */
  test('EncodeSingleCharacter', () {
    int length = 1;

    // we expect to have an end word, padded out with shift 5's
    data[sourceAddress] = codeOf('a'); // Encode an 'a'
    encoderV4.encode(realmem, sourceAddress, length, targetAddress);

    // 'a' + 2 pad
    assertEquals(0x18a5, realmem.readUnsigned16(targetAddress));

    // Test that the rest is padded and marked with the end bit
    assertEquals(0x14a5, realmem.readUnsigned16(targetAddress + 2));
    assertEquals(0x94a5, realmem.readUnsigned16(targetAddress + 4));
  });

  test('EncodeTwoCharacters', () {
    int length = 2;
    data[sourceAddress] = codeOf('a');
    data[sourceAddress + 1] = codeOf('b');

    encoderV4.encode(realmem, sourceAddress, length, targetAddress);

    // 'ab' + pad
    assertEquals(0x18e5, realmem.readUnsigned16(targetAddress));

    // Test that the rest is padded and marked with the end bit
    assertEquals(0x14a5, realmem.readUnsigned16(targetAddress + 2));
    assertEquals(0x94a5, realmem.readUnsigned16(targetAddress + 4));
  });

  test('Encode4Characters', () {
    int length = 4;
    data[sourceAddress] = codeOf('a');
    data[sourceAddress + 1] = codeOf('b');
    data[sourceAddress + 2] = codeOf('c');
    data[sourceAddress + 3] = codeOf('d');

    encoderV4.encode(realmem, sourceAddress, length, targetAddress);
    // 'abc'
    assertEquals(0x18e8, realmem.readUnsigned16(targetAddress));
    // 'd' + 2 pads
    assertEquals(0x24a5, realmem.readUnsigned16(targetAddress + 2));
    // Test that the rest is padded and marked with the end bit
    assertEquals(0x94a5, realmem.readUnsigned16(targetAddress + 4));
  });

  // Test with a different alphabet
  test('EncodeAlphabet1', () {
    int length = 1;
    data[sourceAddress] = codeOf('A');

    encoderV4.encode(realmem, sourceAddress, length, targetAddress);

    // Shift-4 + 'a' + Pad
    assertEquals(0x10c5, realmem.readUnsigned16(targetAddress));

    // Test that the rest is padded and marked with the end bit
    assertEquals(0x14a5, realmem.readUnsigned16(targetAddress + 2));
    assertEquals(0x94a5, realmem.readUnsigned16(targetAddress + 4));
  });

  test('EncodeAlphabet1SpanWordBound', () {
    int length = 3;
    data[sourceAddress] = codeOf('a');
    data[sourceAddress + 1] = codeOf('b');
    data[sourceAddress + 2] = codeOf('C');

    encoderV4.encode(realmem, sourceAddress, length, targetAddress);

    // 'ab' + Shift 4
    assertEquals(0x18e4, realmem.readUnsigned16(targetAddress));

    // 'c'
    assertEquals(0x20a5, realmem.readUnsigned16(targetAddress + 2));

    // Test that the rest is padded and marked with the end bit
    assertEquals(0x94a5, realmem.readUnsigned16(targetAddress + 4));
  });

  test('EncodeAlphabet2SpanWordBound', () {
    int length = 3;
    data[sourceAddress] = codeOf('a');
    data[sourceAddress + 1] = codeOf('b');
    data[sourceAddress + 2] = codeOf('3');

    encoderV4.encode(realmem, sourceAddress, length, targetAddress);

    // 'ab' + Shift 5
    assertEquals(0x18e5, realmem.readUnsigned16(targetAddress));

    // '3'
    assertEquals(0x2ca5, realmem.readUnsigned16(targetAddress + 2));

    // Test that the rest is padded and marked with the end bit
    assertEquals(0x94a5, realmem.readUnsigned16(targetAddress + 4));
  });

  // Encoding of special characters in the unicode has to work.
  // We test this on our favorite character: '@'
  // Do not forget the testing across word boundaries
  //
  // How are characters handled that are larger than a byte ?
  // See how Frotz handles this
  test('EncodeEscapeA2', () {
    int length = 1;
    data[sourceAddress] = codeOf('@');

    encoderV4.encode(realmem, sourceAddress, length, targetAddress);

    // Tricky, tricky (and memory-inefficient)
    // Shift-5 + 6 + '@' (64), encoded in 10 bit, the upper half contains 2
    assertEquals(0x14c2, realmem.readUnsigned16(targetAddress));

    // the lower half contains 0 + 2 pads
    assertEquals(0x00a5, realmem.readUnsigned16(targetAddress + 2));

    // Test that the rest is padded and marked with the end bit
    assertEquals(0x94a5, realmem.readUnsigned16(targetAddress + 4));
  });

  // For triangulation, we use another character (126)
  test('EncodeEscapeA2Tilde', () {
    int length = 1;
    data[sourceAddress] = codeOf('~');

    encoderV4.encode(realmem, sourceAddress, length, targetAddress);

    // Tricky, tricky (and memory-inefficient)
    // Shift-5 + 6 + '~' (126), encoded in 10 bit, the upper half contains 3
    assertEquals(0x14c3, realmem.readUnsigned16(targetAddress));

    // the lower half contains 30 + 2 pads
    assertEquals(0x78a5, realmem.readUnsigned16(targetAddress + 2));

    // Test that the rest is padded and marked with the end bit
    assertEquals(0x94a5, realmem.readUnsigned16(targetAddress + 4));
  });

  test('EncodeEscapeA2TildeSpansWord', () {
    int length = 2;
    data[sourceAddress] = codeOf('a');
    data[sourceAddress + 1] = codeOf('~');

    encoderV4.encode(realmem, sourceAddress, length, targetAddress);

    // Tricky, tricky (and memory-inefficient)
    // 'a' + Shift-5 + 6
    assertEquals(0x18a6, realmem.readUnsigned16(targetAddress));

    // both halves of '~' + 1 pad
    assertEquals(0x0fc5, realmem.readUnsigned16(targetAddress + 2));

    // Test that the rest is padded and marked with the end bit
    assertEquals(0x94a5, realmem.readUnsigned16(targetAddress + 4));
  });

  // We test a situation where the 6 bytes are exceeded by the 9 source
  // characters. In practice, this happens, when there are characters
  // in the source buffer that need to be escaped, since they take the
  // space of 4 lower case characters, which means that one special character
  // can be combined with 5 lower case characters
  test('EncodeCharExceedsTargetBuffer', () {
    // Situation 1: there are lower case letters at the end, we need
    // to ensure that the dictionary is cropped and the characters
    // that exceed the buffer are ommitted
    int length = 7;
    data[sourceAddress] = codeOf('@');
    data[sourceAddress + 1] = codeOf('a');
    data[sourceAddress + 2] = codeOf('b');
    data[sourceAddress + 3] = codeOf('c');
    data[sourceAddress + 4] = codeOf('d');
    data[sourceAddress + 5] = codeOf('e');
    data[sourceAddress + 6] = codeOf('f');

    encoderV4.encode(realmem, sourceAddress, length, targetAddress);

    // Shift-5 + 6 + '@' (64), encoded in 10 bit, the upper half contains 2
    assertEquals(0x14c2, realmem.readUnsigned16(targetAddress));

    // the lower half contains 0, 'ab'
    assertEquals(0x00c7, realmem.readUnsigned16(targetAddress + 2));

    // 'cde' + end bit
    assertEquals(0xa12a, realmem.readUnsigned16(targetAddress + 4));
  });

  test('EncodeCharExceedsTargetBufferEscapeAtEnd', () {
    // Situation 2: in this case the escaped character is at the end,
    // so we need to ommit that escape sequence completely, padding
    // out the rest of the string
    int length = 7;
    data[sourceAddress] = codeOf('a');
    data[sourceAddress + 1] = codeOf('b');
    data[sourceAddress + 2] = codeOf('c');
    data[sourceAddress + 3] = codeOf('d');
    data[sourceAddress + 4] = codeOf('e');
    data[sourceAddress + 5] = codeOf('f');
    data[sourceAddress + 6] = codeOf('@');

    encoderV4.encode(realmem, sourceAddress, length, targetAddress);

    // 'abc'
    assertEquals(0x18e8, realmem.readUnsigned16(targetAddress));

    // 'def'
    assertEquals(0x254b, realmem.readUnsigned16(targetAddress + 2));

    // not long enough, pad it out
    assertEquals(0x94a5, realmem.readUnsigned16(targetAddress + 4));
  });

  // **********************************************************************
  // ***** encode() with source String
  // **********************************************************************
  test('EncodeStringSingleCharacter', () {
    // we expect to have an end word, padded out with shift 5's
    encoderV4.encodeString("a", realmem, targetAddress);

    // 'a' + 2 pad
    assertEquals(0x18a5, realmem.readUnsigned16(targetAddress));

    // Test that the rest is padded and marked with the end bit
    assertEquals(0x14a5, realmem.readUnsigned16(targetAddress + 2));
    assertEquals(0x94a5, realmem.readUnsigned16(targetAddress + 4));
  });

  test('EncodeStringTwoCharacters', () {
    encoderV4.encodeString("ab", realmem, targetAddress);

    // 'ab' + pad
    assertEquals(0x18e5, realmem.readUnsigned16(targetAddress));

    // Test that the rest is padded and marked with the end bit
    assertEquals(0x14a5, realmem.readUnsigned16(targetAddress + 2));
    assertEquals(0x94a5, realmem.readUnsigned16(targetAddress + 4));
  });

  test('EncodeString4Characters', () {
    encoderV4.encodeString("abcd", realmem, targetAddress);

    // 'abc'
    assertEquals(0x18e8, realmem.readUnsigned16(targetAddress));

    // 'd' + 2 pads
    assertEquals(0x24a5, realmem.readUnsigned16(targetAddress + 2));

    // Test that the rest is padded and marked with the end bit
    assertEquals(0x94a5, realmem.readUnsigned16(targetAddress + 4));
  });

  // Test with a different alphabet
  test('EncodeStringAlphabet1', () {
    encoderV4.encodeString("a", realmem, targetAddress);

    // 'a' + Pad
    assertEquals(0x18a5, realmem.readUnsigned16(targetAddress));

    // Test that the rest is padded and marked with the end bit
    assertEquals(0x14a5, realmem.readUnsigned16(targetAddress + 2));
    assertEquals(0x94a5, realmem.readUnsigned16(targetAddress + 4));
  });

  test('EncodeStringAlphabet1SpanWordBound', () {
    encoderV4.encodeString("abc", realmem, targetAddress);

    // 'abc'
    assertEquals(0x18e8, realmem.readUnsigned16(targetAddress));

    // pad
    assertEquals(0x14a5, realmem.readUnsigned16(targetAddress + 2));

    // Test that the rest is padded and marked with the end bit
    assertEquals(0x94a5, realmem.readUnsigned16(targetAddress + 4));
  });

  test('EncodeStringAlphabet2SpanWordBound', () {
    encoderV4.encodeString("ab3", realmem, targetAddress);

    // 'ab' + Shift 5
    assertEquals(0x18e5, realmem.readUnsigned16(targetAddress));

    // '3'
    assertEquals(0x2ca5, realmem.readUnsigned16(targetAddress + 2));

    // Test that the rest is padded and marked with the end bit
    assertEquals(0x94a5, realmem.readUnsigned16(targetAddress + 4));
  });

  // Encoding of special characters in the unicode has to work.
  // We test this on our favorite character: '@'
  // Do not forget the testing across word boundaries
  test('EncodeStringEscapeA2', () {
    encoderV4.encodeString("@", realmem, targetAddress);

    // Tricky, tricky (and memory-inefficient)
    // Shift-5 + 6 + '@' (64), encoded in 10 bit, the upper half contains 2
    assertEquals(0x14c2, realmem.readUnsigned16(targetAddress));

    // the lower half contains 0 + 2 pads
    assertEquals(0x00a5, realmem.readUnsigned16(targetAddress + 2));

    // Test that the rest is padded and marked with the end bit
    assertEquals(0x94a5, realmem.readUnsigned16(targetAddress + 4));
  });

  // For triangulation, we use another character (126)
  test('EncodeStringEscapeA2Tilde', () {
    encoderV4.encodeString("~", realmem, targetAddress);

    // Tricky, tricky (and memory-inefficient)
    // Shift-5 + 6 + '~' (126), encoded in 10 bit, the upper half contains 3
    assertEquals(0x14c3, realmem.readUnsigned16(targetAddress));

    // the lower half contains 30 + 2 pads
    assertEquals(0x78a5, realmem.readUnsigned16(targetAddress + 2));

    // Test that the rest is padded and marked with the end bit
    assertEquals(0x94a5, realmem.readUnsigned16(targetAddress + 4));
  });

  test('EncodeStringEscapeA2TildeSpansWord', () {
    encoderV4.encodeString("a~", realmem, targetAddress);

    // Tricky, tricky (and memory-inefficient)
    // 'a' + Shift-5 + 6
    assertEquals(0x18a6, realmem.readUnsigned16(targetAddress));

    // both halfs of '~' + 1 pad
    assertEquals(0x0fc5, realmem.readUnsigned16(targetAddress + 2));

    // Test that the rest is padded and marked with the end bit
    assertEquals(0x94a5, realmem.readUnsigned16(targetAddress + 4));
  });

  // We test a situation where the 6 bytes are exceeded by the 9 source
  // characters. In practice, this happens, when there are characters
  // in the source buffer that need to be escaped, since they take the
  // space of 4 lower case characters, which means that one special character
  // can be combined with 5 lower case characters
  test('EncodeStringCharExceedsTargetBuffer', () {
    // Situation 1: there are lower case letters at the end, we need
    // to ensure that the dictionary is cropped and the characters
    // that exceed the buffer are ommitted
    encoderV4.encodeString("@abcdef", realmem, targetAddress);

    // Shift-5 + 6 + '@' (64), encoded in 10 bit, the upper half contains 2
    assertEquals(0x14c2, realmem.readUnsigned16(targetAddress));

    // the lower half contains 0, 'ab'
    assertEquals(0x00c7, realmem.readUnsigned16(targetAddress + 2));

    // 'cde' + end bit
    assertEquals(0xa12a, realmem.readUnsigned16(targetAddress + 4));
  });

  test('EncodeStringCharExceedsTargetBufferEscapeAtEnd', () {
    // Situation 2: in this case the escaped character is at the end,
    // so we need to ommit that escape sequence completely, padding
    // out the rest of the string
    encoderV4.encodeString("abcdef@", realmem, targetAddress);

    // 'abc'
    assertEquals(0x18e8, realmem.readUnsigned16(targetAddress));

    // 'def'
    assertEquals(0x254b, realmem.readUnsigned16(targetAddress + 2));

    // not long enough, pad it out
    assertEquals(0x94a5, realmem.readUnsigned16(targetAddress + 4));
  });
}
