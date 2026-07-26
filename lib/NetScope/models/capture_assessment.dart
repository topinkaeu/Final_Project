import 'package:final_project/NetScope/models/observation.dart';
import 'package:final_project/NetScope/models/recommendation.dart';
import 'package:final_project/NetScope/models/traffic_analysis.dart';

class CaptureAssessment {
  final TrafficAnalysis trafficAnalysis;
  final List<Observation> observations;
  final List<Recommendation> recommendations;

  CaptureAssessment({
    required this.trafficAnalysis,
    required this.observations,
    required this.recommendations,
  });
}
