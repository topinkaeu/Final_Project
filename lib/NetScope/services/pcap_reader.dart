import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';

class PcapReader {
Future<({Uint8List bytes, String name})?> pickPcapFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pcap', 'pcapng'],
      withData: true,
    );
    if (result == null) return null;

    final fileResult = result.files.single;
    final bytes = fileResult.bytes;
    if (bytes != null) return (bytes: bytes, name: fileResult.name);

    final path = fileResult.path;
    if (path == null) return null;
    final readBytes = await File(path).readAsBytes();
    return (bytes: readBytes, name: fileResult.name);
  }

  Future<Object?> read(String path) async {}
}
