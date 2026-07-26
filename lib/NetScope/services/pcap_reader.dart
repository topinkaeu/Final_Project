import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';

class PcapReader {
   Future<Uint8List?> pickPcapFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pcap'],
    );

    if (result == null) {
      // user cancelled the picker
      return null;
    }

    final path = result.files.single.path;

    if (path == null) {
      return null;
    }

    final file = File(path);
    return await file.readAsBytes();
  }
}
