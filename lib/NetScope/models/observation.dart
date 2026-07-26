<<<<<<< HEAD
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

class observation {
=======
class Observation {
>>>>>>> cc894f5ac964c748dd334a89edd31d67585d317c
  final String title;
  final String description;

  Observation({required this.title, required this.description});
}
