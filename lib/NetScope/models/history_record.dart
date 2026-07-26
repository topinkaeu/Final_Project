class HistoryRecord {
  final int? id;
  final String fileName;
  final DateTime analyzedAt;

  final int totalPackets;
  final int tcpPackets;
  final int udpPackets;
  final int icmpPackets;
  final int arpPackets;

  final int totalBytes;

  HistoryRecord({
    this.id,
    required this.fileName,
    required this.analyzedAt,
    required this.totalPackets,
    required this.tcpPackets,
    required this.udpPackets,
    required this.icmpPackets,
    required this.arpPackets,
    required this.totalBytes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fileName': fileName,
      'analyzedAt': analyzedAt.toIso8601String(),
      'totalPackets': totalPackets,
      'tcpPackets': tcpPackets,
      'udpPackets': udpPackets,
      'icmpPackets': icmpPackets,
      'arpPackets': arpPackets,
      'totalBytes': totalBytes,
    };
  }

  factory HistoryRecord.fromMap(Map<String, dynamic> map) {
    return HistoryRecord(
      id: map['id'],
      fileName: map['fileName'],
      analyzedAt: DateTime.parse(map['analyzedAt']),
      totalPackets: map['totalPackets'],
      tcpPackets: map['tcpPackets'],
      udpPackets: map['udpPackets'],
      icmpPackets: map['icmpPackets'],
      arpPackets: map['arpPackets'],
      totalBytes: map['totalBytes'],
    );
  }
}
