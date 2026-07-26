class Packet {
  final DateTime timestamp;

  final int length;

  final String sourceMac;
  final String destinationMac;

  final String sourceIp;
  final String destinationIp;

  final String protocol;

  final int? sourcePort;
  final int? destinationPort;

  Packet({
    required this.timestamp,
    required this.length,
    required this.sourceMac,
    required this.destinationMac,
    required this.sourceIp,
    required this.destinationIp,
    required this.protocol,
    this.sourcePort,
    this.destinationPort,
  });
}
