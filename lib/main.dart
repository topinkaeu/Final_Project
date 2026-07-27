// import 'dart:io';
// import 'package:final_project/NetScope/services/packet_parser.dart';

// import 'NetScope/services/packet_parser.dart';
// import 'package:final_project/NetScope/services/assessment_engine.dart';
// import 'package:final_project/NetScope/services/packet_parser.dart';
// import 'package:final_project/NetScope/services/traffic_analyzer.dart';


// void main() {
//   final file = File('test_pcap_file.pcap');
//   final bytes = file.readAsBytesSync();

//   final parser = PacketParser();
//   final packets = parser.parse(bytes);
//   final analyzer = TrafficAnalyzer();
//   final analysis = analyzer.analyze(packets);

//   final engine = AssessmentEngine();
//   final assessment = engine.assess(analysis);

//   print(assessment);



//   print('Total packets parsed: ${packets.length}');

//   for (var i = 0; i < packets.length && i < 5; i++) {
//     final p = packets[i];
//     print(
//       '[$i] ${p.protocol} | ${p.sourceIp}:${p.sourcePort} -> '
//       '${p.destinationIp}:${p.destinationPort} | ${p.length} bytes | ${p.timestamp}',
//     );
//   }
// }


// import 'package:final_project/screens/result_screen.dart';
// import 'package:flutter/material.dart';
// import 'screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'screens/main_shell.dart';
import 'package:final_project/screens/result_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NetScope',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
      ),
      home: const MainShell(),
      routes: {'/results': (context) => const ResultsScreen()},
    );
  }
}

