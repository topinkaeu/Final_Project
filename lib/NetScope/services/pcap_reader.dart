import 'dart:io';
import 'dart:typed_data';

class PcapReader {
  Future<Uint8List> read(String path) async {
    final file = File(path);
    return await file.readAsBytes();
  }
}
