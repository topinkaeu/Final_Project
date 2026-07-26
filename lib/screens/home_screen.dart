import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
// import '../services/pcap_reader.dart';
// import '../services/packet_parser.dart';
// import '../services/traffic_analyzer.dart';
// import '../services/assessment_engine.dart';

import '../NetScope/services/pcap_reader.dart';
import '../NetScope/services/packet_parser.dart';
import '../NetScope/services/traffic_analyzer.dart';
import '../NetScope/services/assessment_engine.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _loading = false;
  String? _error;

  Future<void> _pickAndAnalyze() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final picked = await PcapReader().pickPcapFile();
      if (picked == null) {
        setState(() => _loading = false);
        return;
      }

      final packets = PacketParser().parse(picked.bytes);
      final analysis = TrafficAnalyzer().analyze(packets);
      final assessment = AssessmentEngine().assess(analysis);

      if (!mounted) return;
      setState(() => _loading = false);

      Navigator.pushNamed(
        context,
        '/results',
        arguments: {'assessment': assessment, 'fileName': picked.name},
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = "Couldn't analyze this file: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(Icons.menu),
                  Row(
                    children: [
                      const Icon(Icons.notifications_none),
                      const SizedBox(width: 12),
                      const CircleAvatar(radius: 18),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Guest info — hardcoded, no auth yet
              const Text(
                "Welcome, Guest",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Text(
                "guest@gmail.com",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),

              // Drop / choose file card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF0FF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Icon(Icons.create_new_folder_outlined,
                        size: 48, color: Colors.indigo.shade700),
                    const SizedBox(height: 12),
                    const Text(
                      "Drop Wireshark File Here",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      "(.pcap / .pcapng)",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _pickAndAnalyze,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo.shade900,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: _loading
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text("Choose File",
                                style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _error!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Last Analyzed — static placeholders, no history backend yet
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Last Analyzed",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text("View All",
                      style: TextStyle(color: Colors.indigo.shade700, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: const [
                  Expanded(child: _StaticHistoryCard(
                    name: "mobile.pcap", size: "33.00 MB",
                    packets: "1,678", status: "Completed", isWarning: false,
                  )),
                  SizedBox(width: 12),
                  Expanded(child: _StaticHistoryCard(
                    name: "mobile.pcap", size: "123.00 MB",
                    packets: "1,678", status: "Warning", isWarning: true,
                  )),
                ],
              ),
              const SizedBox(height: 20),

              // Static nav rows — no functionality yet
              const _StaticActionRow(icon: Icons.storage, title: "Open Your Storage", subtitle: "Browse and view your storage"),
              const _StaticActionRow(icon: Icons.help_outline, title: "Help & Guide", subtitle: "Learn how to use the app"),
              const _StaticActionRow(icon: Icons.language, title: "Report Issue", subtitle: "Found a bug? Let us know"),
            ],
          ),
        ),
      ),
    );
  }
}

class _StaticHistoryCard extends StatelessWidget {
  final String name, size, packets, status;
  final bool isWarning;
  const _StaticHistoryCard({
    required this.name, required this.size,
    required this.packets, required this.status, required this.isWarning,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF0FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(size, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                const Icon(Icons.inventory_2_outlined, size: 14),
                const SizedBox(width: 4),
                Text(packets, style: const TextStyle(fontSize: 12)),
              ]),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isWarning ? Colors.red : Colors.green,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(status,
                    style: const TextStyle(color: Colors.white, fontSize: 10)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StaticActionRow extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  const _StaticActionRow({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.indigo.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
}