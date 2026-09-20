class Booking {
  final String id;
  final String userId; // FIXED: Changed from userID to userId (consistent naming)
  final String serviceId; // FIXED: Changed from serviceID to serviceId
  final String serviceName;
  final double price;
  final double hourlyRate;
  final int duration; // in minutes
  final int hours; // Added hours field
  final DateTime bookingDate;
  final DateTime bookingTime;
  final String status;
  final String address;
  final String? notes;
  final DateTime createdAt;

  Booking({
    required this.id,
    required this.userId,
    required this.serviceId,
    required this.serviceName,
    required this.price,
    required this.hourlyRate,
    required this.duration,
    required this.hours, // Added required
    required this.bookingDate,
    required this.bookingTime,
    required this.status,
    required this.address,
    this.notes,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId, // FIXED: Consistent naming
      'serviceId': serviceId, // FIXED: Consistent naming
      'serviceName': serviceName,
      'price': price,
      'hourlyRate': hourlyRate,
      'duration': duration,
      'hours': hours, // Added hours field
      'bookingDate': bookingDate.toIso8601String(),
      'bookingTime': bookingTime.toIso8601String(),
      'status': status,
      'address': address,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Booking.fromMap(Map<String, dynamic> map, String id) {
    return Booking(
      id: id,
      userId: map['userId'] ?? '', // FIXED: Changed from userID to userId
      serviceId: map['serviceId'] ?? '', // FIXED: Changed from serviceID to serviceId
      serviceName: map['serviceName'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      hourlyRate: (map['hourlyRate'] ?? 250.0).toDouble(),
      duration: map['duration'] ?? 60,
      hours: map['hours'] ?? 1, // Added hours field with default
      bookingDate: DateTime.parse(map['bookingDate']),
      bookingTime: DateTime.parse(map['bookingTime']),
      status: map['status'] ?? 'pending',
      address: map['address'] ?? '',
      notes: map['notes'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}