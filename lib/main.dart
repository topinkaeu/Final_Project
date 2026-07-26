import 'dart:io';
import 'package:final_project/NetScope/services/packet_parser.dart';

import 'NetScope/services/packet_parser.dart';
import 'package:final_project/NetScope/services/assessment_engine.dart';
import 'package:final_project/NetScope/services/packet_parser.dart';
import 'package:final_project/NetScope/services/traffic_analyzer.dart';


void main() {
  final file = File('test_pcap_file.pcap');
  final bytes = file.readAsBytesSync();

  final parser = PacketParser();
  final packets = parser.parse(bytes);
  final analyzer = TrafficAnalyzer();
  final analysis = analyzer.analyze(packets);

  final engine = AssessmentEngine();
  final assessment = engine.assess(analysis);

  print(assessment);



  print('Total packets parsed: ${packets.length}');

  for (var i = 0; i < packets.length && i < 5; i++) {
    final p = packets[i];
    print(
      '[$i] ${p.protocol} | ${p.sourceIp}:${p.sourcePort} -> '
      '${p.destinationIp}:${p.destinationPort} | ${p.length} bytes | ${p.timestamp}',
    );
  }
}


