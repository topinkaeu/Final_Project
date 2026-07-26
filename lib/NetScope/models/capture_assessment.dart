import 'package:final_project/NetScope/models/observation.dart';
import 'package:final_project/NetScope/models/recommendation.dart';
import 'package:final_project/NetScope/models/traffic_analysis.dart';

class CaptureAssessment {
  final TrafficAnalysis trafficAnalysis;
  final List<observation> observations;
  final List<Recommendation> recommendation;

  CaptureAssessment({required this.trafficAnalysis, required this.observations, required this.recommendation})
}
