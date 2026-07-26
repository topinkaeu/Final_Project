class TrafficAnalysis {
  final int totalPackets;
  final int tcpPackets;
  final int udpPackets;
  final int icmpPackets;
  final int arpPackets;

  final int totalBytes;

  final Map<String, int> sourceIpCount;
  final Map<String, int> destinationIpCount;

  TrafficAnalysis({
    required this.totalPackets,
    required this.tcpPackets,
    required this.udpPackets,
    required this.icmpPackets,
    required this.arpPackets,
    required this.totalBytes,
    required this.sourceIpCount,
    required this.destinationIpCount,
  });
}
