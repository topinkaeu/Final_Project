import 'dart:io';
import 'package:final_project/NetScope/services/packet_parser.dart';

void main() {
  final file = File('test_pcap_file.pcap');
  final bytes = file.readAsBytesSync();

  final parser = PacketParser();
  final packets = parser.parse(bytes);

  print('Total packets parsed: ${packets.length}');

  for (var i = 0; i < packets.length && i < 5; i++) {
    final p = packets[i];
    print(
      '[$i] ${p.protocol} | ${p.sourceIp}:${p.sourcePort} -> '
      '${p.destinationIp}:${p.destinationPort} | ${p.length} bytes | ${p.timestamp}',
    );
  }
}

