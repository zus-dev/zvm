import 'dart:io';

import 'package:zvm/zvm.dart';

/// This class saves save games as a memory object.
class FileSaveGameDataStore implements SaveGameDataStore {
  String saveFile = "data.sav";

  @override
  bool saveFormChunk(WritableFormChunk formchunk) {
    try {
      final raf = File(saveFile);
      ByteArray data = formchunk.getBytes();
      raf.writeAsBytesSync(data);
      return true;
    } on FileSystemException catch (ex) {
      // ex.printStackTrace();
      print("ERROR: ${ex}");
    } finally {
      // if (raf != null) try { raf.close(); } catch(ex) {
      // ex.printStackTrace();
      // }
    }
    return false;
  }

  @override
  FormChunk retrieveFormChunk() {
    try {
      final raf = File(saveFile);
      ByteArray data = ByteArray(raf.readAsBytesSync());
      return DefaultFormChunk(DefaultMemory(data));
    } on FileSystemException catch (ex) {
      // ex.printStackTrace();
      print("ERROR: ${ex}");
    } finally {
      // if (raf != null) try { raf.close(); } catch (Exception ex) {
      //   ex.printStackTrace();
      // }
    }
    return null;
  }
}
