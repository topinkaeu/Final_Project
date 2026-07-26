// import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/capture_assessment.dart';

class PdfReportGenerator {
  Future<void> generateAndShare({
    required CaptureAssessment assessment,
    required String fileName,
  }) async {
    final analysis = assessment.trafficAnalysis;
    final protocolCounts = {
      'UDP': analysis.udpPackets,
      'TCP': analysis.tcpPackets,
      'ICMP': analysis.icmpPackets,
      'ARP': analysis.arpPackets,
    };
    final total = analysis.totalPackets == 0 ? 1 : analysis.totalPackets;
    final topSource = _topEntry(analysis.sourceIpCount);
    final topDest = _topEntry(analysis.destinationIpCount);
    final dateStr =
        "${DateTime.now().month}/${DateTime.now().day}/${DateTime.now().year}";

    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Header banner
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(16),
              decoration: const pw.BoxDecoration(
                color: PdfColor.fromInt(0xFF1A1F3B),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        "NetScope Analyzer",
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        "Automated PCAP Forensic Analysis Report",
                        style: const pw.TextStyle(
                          color: PdfColors.grey300,
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.green,
                      borderRadius: pw.BorderRadius.circular(20),
                    ),
                    child: pw.Text(
                      "COMPLETED",
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 16),

            // File & metadata
            _sectionBox(
              title: "FILE & METADATA OVERVIEW",
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        _kv("File Name:", fileName),
                        _kv("Source IP:", topSource),
                        _kv("Analyzed By:", "guest@gmail.com"),
                      ],
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        _kv("Analysis Date:", dateStr),
                        _kv("Destination IP:", topDest),
                        _kv("Scan Engine:", "NetScope Core v1.0"),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 12),

            // Traffic summary
            _sectionBox(
              title: "TRAFFIC SUMMARY METRICS",
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  _metric("TOTAL PACKETS", "${analysis.totalPackets}"),
                  _metric("TOTAL BYTES", "${analysis.totalBytes}"),
                  _metric(
                    "PROTOCOLS",
                    "${protocolCounts.entries.where((e) => e.value > 0).length}",
                  ),
                  _metric(
                    "ALERTS FOUND",
                    "${assessment.observations.length}",
                    isAlert: true,
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 12),

            // Protocol distribution table
            _sectionBox(
              title: "PROTOCOL DISTRIBUTION",
              child: pw.Column(
                children: [
                  pw.Row(
                    children: [
                      pw.Expanded(
                        flex: 2,
                        child: pw.Text("PROTOCOL", style: _th()),
                      ),
                      pw.Expanded(
                        flex: 2,
                        child: pw.Text("DISTRIBUTION", style: _th()),
                      ),
                      pw.Expanded(
                        flex: 4,
                        child: pw.Text("VISUAL PROPORTION", style: _th()),
                      ),
                    ],
                  ),
                  pw.Divider(),
                  ...protocolCounts.entries.map((e) {
                    final pct = e.value / total;
                    return pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(vertical: 4),
                      child: pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          pw.Expanded(flex: 2, child: pw.Text(e.key)),
                          pw.Expanded(
                            flex: 2,
                            child: pw.Text("${(pct * 100).round()}%"),
                          ),
                          pw.Expanded(
                            flex: 4,
                            child: pw.Container(
                              height: 6,
                              decoration: pw.BoxDecoration(
                                color: PdfColors.grey300,
                                borderRadius: pw.BorderRadius.circular(3),
                              ),
                              child: pw.Row(
                                children: [
                                  pw.Expanded(
                                    flex: (pct.clamp(0.0, 1.0) * 100).round(),
                                    child: pw.Container(
                                      height: 6,
                                      decoration: pw.BoxDecoration(
                                        color: PdfColors.indigo,
                                        borderRadius: pw.BorderRadius.circular(
                                          3,
                                        ),
                                      ),
                                    ),
                                  ),
                                  pw.Expanded(
                                    flex:
                                        100 -
                                        (pct.clamp(0.0, 1.0) * 100).round(),
                                    child: pw.Container(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            pw.SizedBox(height: 12),

            // Observations
            _sectionBox(
              title: "OBSERVATIONS & SECURITY FINDINGS",
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: assessment.observations.map((o) {
                  return pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 6),
                    child: pw.Bullet(text: "${o.title}: ${o.description}"),
                  );
                }).toList(),
              ),
            ),
            pw.SizedBox(height: 12),

            // Recommendations
            if (assessment.recommendations.isNotEmpty)
              _sectionBox(
                title: "RECOMMENDATIONS",
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: assessment.recommendations
                      .map((r) => pw.Bullet(text: r.message))
                      .toList(),
                ),
              ),

            pw.SizedBox(height: 20),
            pw.Center(
              child: pw.Text(
                "Generated automatically by NetScope App — Confidential Technical Analysis Report",
                style: const pw.TextStyle(
                  fontSize: 8,
                  color: PdfColors.grey500,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    await Printing.sharePdf(
      bytes: await doc.save(),
      filename:
          '${fileName.replaceAll('.pcap', '').replaceAll('.pcapng', '')}_report.pdf',
    );
  }

  pw.Widget _sectionBox({required String title, required pw.Widget child}) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey600,
            ),
          ),
          pw.SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  pw.Widget _kv(String k, String v) => pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 4),
    child: pw.RichText(
      text: pw.TextSpan(
        children: [
          pw.TextSpan(
            text: "$k ",
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
          ),
          pw.TextSpan(
            text: v,
            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    ),
  );

  pw.Widget _metric(String label, String value, {bool isAlert = false}) =>
      pw.Column(
        children: [
          pw.Text(
            label,
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: isAlert ? PdfColors.red : PdfColors.black,
            ),
          ),
        ],
      );

  pw.TextStyle _th() => pw.TextStyle(
    fontSize: 8,
    fontWeight: pw.FontWeight.bold,
    color: PdfColors.grey600,
  );

  String _topEntry(Map<String, int> counts) {
    final entries = counts.entries.where((e) => e.key.isNotEmpty).toList();
    if (entries.isEmpty) return "N/A";
    entries.sort((a, b) => b.value.compareTo(a.value));
    return entries.first.key;
  }
}
