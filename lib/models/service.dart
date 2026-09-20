class Service {
  final String id;
  final String name;
  final String description;
  final double price;
  final double hourlyRate; // ₹250 per hour
  final String icon;
  final String category;
  final int duration; // in minutes

  Service({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.hourlyRate,
    required this.icon,
    required this.category,
    required this.duration,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'hourlyRate': hourlyRate,
      'icon': icon,
      'category': category,
      'duration': duration,
    };
  }

  factory Service.fromMap(Map<String, dynamic> map, String id) {
    return Service(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      hourlyRate: (map['hourlyRate'] ?? 250.0).toDouble(),
      icon: map['icon'] ?? '',
      category: map['category'] ?? '',
      duration: map['duration'] ?? 60,
    );
  }
  
  double calculateTotalPrice(int hours) {
    return hourlyRate * hours;
  }
  
  double get durationInHours => duration / 60.0;
}