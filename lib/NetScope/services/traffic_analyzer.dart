import '../models/packet.dart';
import '../models/traffic_analysis.dart';

class TrafficAnalyzer {
  TrafficAnalysis analyze(List<Packet> packets) {

    int tcp = 0;
    int udp = 0;
    int icmp = 0;
    int arp = 0;

    int totalBytes = 0;

    final sourceIpCount = <String, int>{};

    final destinationIpCount = <String, int>{};

    for (final packet in packets) {
      totalBytes += packet.length;

      switch (packet.protocol) {
        case "TCP":
          tcp++;
          break;

        case "UDP":
          udp++;
          break;

        case "ICMP":
          icmp++;
          break;

        case "ARP":
          arp++;
          break;
      }
      sourceIpCount.update(
        packet.sourceIp,
        (value) => value + 1,
        ifAbsent: () => 1,
      );

      destinationIpCount.update(
        packet.destinationIp,
        (value) => value + 1,
        ifAbsent: () => 1,
      );
    }

    return TrafficAnalysis(
      totalPackets: packets.length,
      tcpPackets: tcp,
      udpPackets: udp,
      icmpPackets: icmp,
      arpPackets: arp,
      totalBytes: totalBytes,
      sourceIpCount: sourceIpCount,
      destinationIpCount: destinationIpCount,
    );
  }
  
}
