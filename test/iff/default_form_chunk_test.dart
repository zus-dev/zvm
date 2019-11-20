import "dart:io";
import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:zvm/zvm.dart';

import '../helpers.dart';

void main() {
  Memory formChunkData;
  FormChunk formChunk;

  setUp(() {
     final s = Platform.pathSeparator;
     final testSaveFile = File('testfiles${s}leathersave.ifzs');
     final data = ByteArray(testSaveFile.readAsBytesSync());
     formChunkData = DefaultMemory(data);
     formChunk = DefaultFormChunk(formChunkData);
  });
}
