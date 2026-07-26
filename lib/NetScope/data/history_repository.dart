import '../models/capture_assessment.dart';
import '../models/history_record.dart';
import 'database_helper.dart';

class HistoryRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Future<void> save({
    required String fileName,
    required CaptureAssessment assessment,
  }) async {
    final db = await _databaseHelper.database;

    final record = HistoryRecord(
      fileName: fileName,
      analyzedAt: DateTime.now(),
      totalPackets: assessment.trafficAnalysis.totalPackets,
      tcpPackets: assessment.trafficAnalysis.tcpPackets,
      udpPackets: assessment.trafficAnalysis.udpPackets,
      icmpPackets: assessment.trafficAnalysis.icmpPackets,
      arpPackets: assessment.trafficAnalysis.arpPackets,
      totalBytes: assessment.trafficAnalysis.totalBytes,
    );

    await db.insert('history', record.toMap());
  }

  Future<List<HistoryRecord>> getAll() async {
    final db = await _databaseHelper.database;

    final result = await db.query('history', orderBy: 'id DESC');

    return result.map((e) => HistoryRecord.fromMap(e)).toList();
  }

  Future<void> delete(int id) async {
    final db = await _databaseHelper.database;

    await db.delete('history', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clear() async {
    final db = await _databaseHelper.database;

    await db.delete('history');
  }
}
