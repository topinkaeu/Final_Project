import '../models/recommendation.dart';
import '../models/traffic_analysis.dart';

class RecommendationEngine {
  List<Recommendation> generate(TrafficAnalysis analysis) {
    final recommendations = <Recommendation>[];

    if (analysis.tcpPackets > 0) {
      recommendations.add(Recommendation(message: "TCP traffic detected."));
    }

    if (analysis.udpPackets > analysis.tcpPackets) {
      recommendations.add(Recommendation(message: "UDP traffic is dominant."));
    }

    if (analysis.icmpPackets > 50) {
      recommendations.add(
        Recommendation(message: "High ICMP traffic detected."),
      );
    }

    if (analysis.arpPackets > 20) {
      recommendations.add(
        Recommendation(message: "Large number of ARP packets detected."),
      );
    }

    return recommendations;
  }
}
