class Unit {
  final String id;
  final String name;
  final String title;
  final double progress;

  Unit({
    required this.id,
    required this.name,
    required this.title,
    this.progress = 0.0,
  });

  // Factory method to create from JSON/Map if needed later
  factory Unit.fromJson(Map<String, dynamic> json) {
    return Unit(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      title: json['title'] ?? '',
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

// Mock Data
final List<Unit> mockUnits = [
  Unit(id: '1', name: "Unit 1", title: "Family Life", progress: 0.8),
  Unit(id: '2', name: "Unit 2", title: "Humans and the Environment", progress: 0.45),
  Unit(id: '3', name: "Unit 3", title: "Music", progress: 0.1),
  Unit(id: '4', name: "Unit 4", title: "For a Better Community", progress: 0.0),
  Unit(id: '5', name: "Unit 5", title: "Inventions", progress: 0.0),
  Unit(id: '6', name: "Unit 6", title: "Gender Equality", progress: 0.0),
  Unit(id: '7', name: "Unit 7", title: "Vietnam and International Organisations", progress: 0.0),
  Unit(id: '8', name: "Unit 8", title: "New Ways to Learn", progress: 0.0),
  Unit(id: '9', name: "Unit 9", title: "Protecting the Environment", progress: 0.0),
  Unit(id: '10', name: "Unit 10", title: "Ecotourism", progress: 0.0),
];
