class Plan {
  final String id;
  final String name;
  final String imageUrl;

  Plan({required this.id, required this.name, required this.imageUrl});
}

class SnagPoint {
  final String id;
  final double x; // Position relative en pourcentage (0.0 à 1.0)
  final double y; // Position relative en pourcentage (0.0 à 1.0)
  final int number;
  String description;
  String status; // 'open', 'fixed'

  SnagPoint({
    required this.id,
    required this.x,
    required this.y,
    required this.number,
    required this.description,
    this.status = 'open',
  });
}

// Données de démonstration
final List<Plan> demoPlans = [
  Plan(
    id: '1',
    name: 'Rez-de-chaussée - Zone A',
    imageUrl: 'https://placehold.co/1000x800/E0E0E0/333333.png?text=Plan+RDC+Zone+A',
  ),
  Plan(
    id: '2',
    name: '1er Étage - Électricité',
    imageUrl: 'https://placehold.co/1000x800/E0E0E0/333333.png?text=Plan+Elec+Etage+1',
  ),
  Plan(
    id: '3',
    name: 'Toiture et Combles',
    imageUrl: 'https://placehold.co/800x600/E0E0E0/333333.png?text=Plan+Toiture',
  ),
];
