import '../models/capture_assessment.dart';
import '../models/observation.dart';
import '../models/traffic_analysis.dart';
import 'recommendation_engine.dart';

class AssessmentEngine {
  final RecommendationEngine recommendationEngine = RecommendationEngine();

  CaptureAssessment assess(TrafficAnalysis analysis) {
    final observations = <Observation>[];

    // General summary — always shown, informational only
    observations.add(
      Observation(
        title: "Capture Summary",
        description:
            "${analysis.totalPackets} packets captured, totaling ${analysis.totalBytes} bytes.",
        severity: Severity.info,
      ),
    );

    // High ICMP activity — possible scanning/diagnostics
    if (analysis.icmpPackets > 50) {
      observations.add(
        Observation(
          title: "High ICMP Activity",
          description:
              "${analysis.icmpPackets} ICMP packets detected — could indicate network scanning or diagnostics.",
          severity: Severity.warning,
        ),
      );
    }

    // High ARP activity — could indicate ARP spoofing/scanning on the LAN
    if (analysis.arpPackets > 100) {
      observations.add(
        Observation(
          title: "High ARP Activity",
          description:
              "${analysis.arpPackets} ARP packets detected — unusually high volume may indicate network scanning.",
          severity: Severity.warning,
        ),
      );
    }

    // No TCP or UDP traffic at all — unusual for most captures
    if (analysis.tcpPackets == 0 && analysis.udpPackets == 0) {
      observations.add(
        Observation(
          title: "No Transport Layer Traffic",
          description: "No TCP or UDP packets were found in this capture.",
          severity: Severity.info,
        ),
      );
    }

    return CaptureAssessment(
      trafficAnalysis: analysis,
      observations: observations,
      recommendations: recommendationEngine.generate(analysis),
    );
  }
}
