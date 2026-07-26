import 'dart:typed_data';

import '../models/packet.dart';
import 'packet_result.dart';

class PacketParser {
  List<Packet> parse(Uint8List bytes) {
    final packets = <Packet>[];

    int offset = 0;

    offset = _readGlobalHeader(bytes, offset);

    while (offset < bytes.length) {
      final result = _readPacket(bytes, offset);

      if (result == null) {
        break;
      }

      packets.add(result.packet);

      offset = result.nextOffset;
    }

    return packets;
  }

  //============================
  // Global Header
  //============================

  int _readGlobalHeader(Uint8List bytes, int offset) {
    final header = ByteData.sublistView(bytes, offset, offset + 24);

    final magic = header.getUint32(0, Endian.little);

    if (magic != 0xa1b2c3d4 && magic != 0xd4c3b2a1) {
      throw Exception("Invalid PCAP file");
    }

    final versionMajor = header.getUint16(4, Endian.little);
    final versionMinor = header.getUint16(6, Endian.little);

    final snapLength = header.getUint32(16, Endian.little);

    final linkType = header.getUint32(20, Endian.little);

    print("Version : $versionMajor.$versionMinor");
    print("SnapLen : $snapLength");
    print("LinkType: $linkType");

    return offset + 24;
  }

  //============================
  // Packet Header
  //============================

  PacketResult? _readPacket(Uint8List bytes, int offset) {
    if (offset + 16 > bytes.length) {
      return null;
    }

    final header = ByteData.sublistView(bytes, offset, offset + 16);

    final timestampSeconds = header.getUint32(0, Endian.little);
    final timestampMicroSeconds = header.getUint32(4, Endian.little);

    final capturedLength = header.getUint32(8, Endian.little);

    final originalLength = header.getUint32(12, Endian.little);

    // move after Packet header
    offset += 16;

    // make sure packet data exists
    if (offset + capturedLength > bytes.length) {
      return null;
    }

    // Extract one packet
    final packetBytes = bytes.sublist(offset, offset + capturedLength);

    // parser packet
    final packet = _parseEthernet(
      packetBytes,
      timestampSeconds,
      originalLength,
    );

    // Move to next packet

    offset += capturedLength;

    return PacketResult(packet: packet, nextOffset: offset);
  }

  //============================
  // Ethernet
  //============================

  Packet _parseEthernet(
    Uint8List packetBytes,
    int timestamp,
    int packetLength,
  ) {
    // Ethernet Header = 14 bytes
    final ethernet = ByteData.sublistView(packetBytes, 0, 14);

    final destinationMac = _readMac(packetBytes, 0);
    final sourceMac = _readMac(packetBytes, 6);
    var etherType = ethernet.getUint16(12, Endian.big);

     int ipStartOffset = 14; // normal Ethernet header size

    // Handle VLAN tag (802.1Q)
    if (etherType == 0x8100) {
      // skip the 4-byte VLAN tag, real EtherType is right after it
      etherType = ByteData.sublistView(
        packetBytes,
        16,
        18,
      ).getUint16(0, Endian.big);

      ipStartOffset = 18; // Ethernet header is now 18 bytes, not 14
    }
    switch (etherType) {
      case 0x0800:
        return _parseIPv4(
          packetBytes,
          timestamp,
          packetLength,
          sourceMac,
          destinationMac,
          ipStartOffset,
        );

     case 0x0806:
        return Packet(
          timestamp: DateTime.fromMillisecondsSinceEpoch(timestamp * 1000),
          length: packetLength,
          sourceMac: sourceMac,
          destinationMac: destinationMac,
          sourceIp: "",
          destinationIp: "",
          protocol: "ARP",
          sourcePort: null,
          destinationPort: null,
        );

       default:
        return Packet(
          timestamp: DateTime.fromMillisecondsSinceEpoch(timestamp * 1000),
          length: packetLength,
          sourceMac: sourceMac,
          destinationMac: destinationMac,
          sourceIp: "",
          destinationIp: "",
          protocol: "Unknown",
          sourcePort: null,
          destinationPort: null,
        );
    }
  }

  //============================
  // IPv4
  //============================

  Packet _parseIPv4(
    Uint8List bytes,
    int timestamp,
    int packetLength,
    String sourceMac,
    String destinationMac, int ipStartOffset,
  ) {
    // IPv4 starts after Ethernet(14 bytes)


    final ip = ByteData.sublistView(bytes, ipStartOffset);

    // Version + IHL
    final versionIhl = ip.getUint8(0);
    final ipHeaderLength = (versionIhl & 0x0F) * 4;

    // protocol
    final protocol = ip.getUint8(9);

    // Source IP

    final sourceIp = _readIp(bytes, ipStartOffset + 12);

    final destinationIp = _readIp(bytes, ipStartOffset + 16);
    print("----------------");
    print("IP Start : $ipStartOffset");
    print("Version/IHL : ${versionIhl.toRadixString(16)}");
    print("Protocol : $protocol");
    print("Source : $sourceIp");
    print("Destination : $destinationIp");

    switch (protocol) {
      case 6:
        return _parseTCP(
          bytes,
          timestamp,
          packetLength,
          sourceMac,
          destinationMac,
          sourceIp,
          destinationIp,
          ipHeaderLength,
          ipStartOffset,
        );

      case 17:
        return _parseUDP(
          bytes,
          timestamp,
          packetLength,
          sourceMac,
          destinationMac,
          sourceIp,
          destinationIp,
          ipHeaderLength,
          ipStartOffset,
        );

      case 1:
        return _parseICMP(
          bytes,
          timestamp,
          packetLength,
          sourceMac,
          destinationMac,
          sourceIp,
          destinationIp,
          ipHeaderLength,
          ipStartOffset,
        );

      default:
        throw UnsupportedError("Unsupported IP Protocol: $protocol");
    }
  }

  //============================
  // TCP
  //============================

  Packet _parseTCP(
    Uint8List bytes,
    int timestamp,
    int packetLength,
    String sourceMac,
    String destinationMac,
    String sourceIp,
    String destinationIp,
    int ipHeaderLength,
    int ipStartOffset,
  ) {
    // TCP starts after Ethernet + IPv4
    final tcpOffset = ipStartOffset + ipHeaderLength;

    final tcp = ByteData.sublistView(bytes, tcpOffset);

    final sourcePort = tcp.getUint16(0, Endian.big);

    final destinationPort = tcp.getUint16(2, Endian.big);
    return Packet(
      timestamp: DateTime.fromMillisecondsSinceEpoch(timestamp * 1000),
      length: packetLength,
      sourceMac: sourceMac,
      destinationMac: destinationMac,
      sourceIp: sourceIp,
      destinationIp: destinationIp,
      protocol: "TCP",
      sourcePort: sourcePort,
      destinationPort: destinationPort,

    );
  }
  //============================
  // UDP
  //============================

  Packet _parseUDP(
    Uint8List bytes,
    int timestamp,
    int packetLength,
    String sourceMac,
    String destinationMac,
    String sourceIp,
    String destinationIp,
    int ipHeaderLength,
    int ipStartOffset,
  ) {
    final udpOffset = ipStartOffset + ipHeaderLength;
    final udp = ByteData.sublistView(bytes, udpOffset);
    final sourcePort = udp.getUint16(0, Endian.big);
    final destinationPort = udp.getUint16(2, Endian.big);

    return Packet(
      timestamp: DateTime.fromMillisecondsSinceEpoch(timestamp * 1000),
      length: packetLength,
      sourceMac: sourceMac,
      destinationMac: destinationMac,
      sourceIp: sourceIp,
      destinationIp: destinationIp,
      protocol: "UDP",
      sourcePort: sourcePort,
      destinationPort: destinationPort,
    );
  }

  //============================
  // ICMP
  //============================

  Packet _parseICMP(
    Uint8List bytes,
    int timestamp,
    int packetLength,
    String sourceMac,
    String destinationMac,
    String sourceIp,
    String destinationIp,
    int ipHeaderLength,
    int ipStartOffset,
    // int? sourcePort,
    // int? destinationPort,
  ) {
    final icmpOffset = ipStartOffset + ipHeaderLength;

    final icmp = ByteData.sublistView(bytes, icmpOffset);

    final type = icmp.getUint8(0);
    final code = icmp.getUint8(1);

    return Packet(
      timestamp: DateTime.fromMillisecondsSinceEpoch(timestamp * 1000),
      length: packetLength,
      sourceMac: sourceMac,
      destinationMac: destinationMac,
      sourceIp: sourceIp,
      destinationIp: destinationIp,
      protocol: "ICMP",
      sourcePort: null,
      destinationPort: null,
    );


  }

  //============================
  // Helpers
  //============================

  String _readMac(Uint8List bytes, int offset) {
    String result = "";

    for (int i = 0; i < 6; i++) {
      int byteValue = bytes[offset + i];
      String hex = byteValue.toRadixString(16);

      if (hex.length == 1) {
        hex = "0" + hex;
      }

      result = result + hex;

      if (i < 5) {
        result = result + ":";
      }
    }
    return result;
  }

  String _readIp(Uint8List bytes, int offset) {
    String result = "";

    for (int i = 0; i < 4; i++) {
      int byteValue = bytes[offset + i];
      result = result + byteValue.toString();

      if (i < 3) {
        result = result + ".";
      }
    }
    return result;
  }
}
