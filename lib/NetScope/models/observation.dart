
enum Severity { info, warning, critical }

class Observation {
  final String title;
  final String description;
  final Severity severity;
  Observation({
    required this.title,
    required this.description,
    required this.severity,
  });
}



