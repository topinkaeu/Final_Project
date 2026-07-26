import '../models/capture_assessment.dart';
import '../models/observation.dart';
import '../models/traffic_analysis.dart';
import 'recommendation_engine.dart';

class AssessmentEngine {
  final RecommendationEngine recommendationEngine = RecommendationEngine();

  CaptureAssessment assess(TrafficAnalysis analysis) {
    final observations = <Observation>[
      Observation(
        title: "Total Packets",
        description: analysis.totalPackets.toString(),
      ),
      Observation(
        title: "TCP Packets",
        description: analysis.tcpPackets.toString(),
      ),
      Observation(
        title: "UDP Packets",
        description: analysis.udpPackets.toString(),
      ),
      Observation(
        title: "ICMP Packets",
        description: analysis.icmpPackets.toString(),
      ),
      Observation(
        title: "ARP Packets",
        description: analysis.arpPackets.toString(),
      ),
      Observation(
        title: "Total Bytes",
        description: analysis.totalBytes.toString(),
      ),
    ];

    return CaptureAssessment(
      trafficAnalysis: analysis,
      observations: observations,
      recommendations: recommendationEngine.generate(analysis), recommendation: [],
    );
  }
}
