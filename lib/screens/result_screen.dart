import 'package:flutter/material.dart';
import '../NetScope/models/capture_assessment.dart';
import '../NetScope/services/pdf_report_generator.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments;
    final assessment = args is Map
        ? args['assessment'] as CaptureAssessment
        : args as CaptureAssessment;
    final fileName = args is Map
        ? (args['fileName'] as String? ?? 'capture.pcap')
        : 'capture.pcap';
    final analysis = assessment.trafficAnalysis;
    final alertCount = assessment.observations.length;

    final protocolCounts = {
      'TCP': analysis.tcpPackets,
      'UDP': analysis.udpPackets,
      'ICMP': analysis.icmpPackets,
      'ARP': analysis.arpPackets,
    };

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
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    "Analysis Results",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  IconButton(
                    icon: const Icon(Icons.share_outlined),
                    onPressed: () {}, // no real export/share logic yet
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // File card
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F0FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.folder_copy_outlined,
                      color: Colors.indigo,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        fileName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        "Completed",
                        style: TextStyle(color: Colors.white, fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Stat grid
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.inventory_2_outlined,
                      label: "Packets",
                      value: "${analysis.totalPackets}",
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.data_usage,
                      label: "Total Bytes",
                      value: "${analysis.totalBytes}",
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.hub_outlined,
                      label: "Protocols",
                      value:
                          "${protocolCounts.entries.where((e) => e.value > 0).length}",
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.warning_amber_rounded,
                      label: "Alert",
                      value: "$alertCount",
                      isAlert: alertCount > 0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Protocol breakdown with bars
              const Text(
                "Protocol Breakdown",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: protocolCounts.entries.map((e) {
                    final pct = analysis.totalPackets == 0
                        ? 0.0
                        : (e.value / analysis.totalPackets);
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                e.key,
                                style: const TextStyle(
                                  color: Colors.indigo,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                "${(pct * 100).round()}%",
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: pct,
                              minHeight: 6,
                              backgroundColor: Colors.grey.shade200,
                              valueColor: const AlwaysStoppedAnimation(
                                Colors.indigo,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),

              // Source / Destination IP
              Row(
                children: [
                  Expanded(
                    child: _IpCard(
                      label: "SOURCE IP",
                      ip: _topEntry(analysis.sourceIpCount),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _IpCard(
                      label: "DESTINATION IP",
                      ip: _topEntry(analysis.destinationIpCount),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Export / Share row
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        try {
                          await PdfReportGenerator().generateAndShare(
                            assessment: assessment,
                            fileName: fileName,
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Export failed: $e')),
                          );
                        }
                      }, // no PDF generation logic yet
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.indigo),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Export PDF",
                        style: TextStyle(color: Colors.indigo),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {}, // no DOCS export logic yet
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.indigo),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Export DOCS",
                        style: TextStyle(color: Colors.indigo),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {}, // no share logic yet
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo.shade900,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Share",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Observations
              const Text(
                "Observations",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              for (final o in assessment.observations)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F7FA),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          o.title,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          o.description,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

String _topEntry(Map<String, int> counts) {
  if (counts.isEmpty) return "N/A";
  final entries = counts.entries.where((e) => e.key.isNotEmpty).toList();
  if (entries.isEmpty) return "N/A";
  entries.sort((a, b) => b.value.compareTo(a.value));
  return entries.first.key;
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final bool isAlert;
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    this.isAlert = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isAlert ? const Color(0xFFFFEBEE) : const Color(0xFFF3F0FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: isAlert ? Colors.red : Colors.indigo, size: 20),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: isAlert ? Colors.red : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class _IpCard extends StatelessWidget {
  final String label, ip;
  const _IpCard({required this.label, required this.ip});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
          const SizedBox(height: 4),
          Text(
            ip,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
