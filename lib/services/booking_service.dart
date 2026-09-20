import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/booking.dart';
import '../models/service.dart';

class BookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get all available services
  Stream<List<Service>> getServices() {
    return _firestore.collection('services').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Service.fromMap(data, doc.id);
      }).toList();
    });
  }

  // Get service by ID
  Future<Service?> getServiceById(String serviceId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> doc = await _firestore
          .collection('services')
          .doc(serviceId)
          .get();
          
      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          return Service.fromMap(data, doc.id);
        }
      }
      return null;
    } catch (e) {
      print('Error getting service: $e');
      return null;
    }
  }

  // Create a new booking with hourly rate calculation - FIXED
  Future<Map<String, dynamic>> createBooking({
    required String serviceId,
    required DateTime bookingDate,
    required DateTime bookingTime,
    required String address,
    required int hours,
    String? notes,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return {'success': false, 'message': 'User not logged in'};

      final service = await getServiceById(serviceId);
      if (service == null) return {'success': false, 'message': 'Service not found'};

      final totalPrice = service.hourlyRate * hours;
      final durationInMinutes = hours * 60;

      final booking = Booking(
        id: '',
        userId: user.uid, // FIXED: Changed from user.id to user.uid
        serviceId: serviceId,
        serviceName: service.name,
        price: totalPrice,
        hourlyRate: service.hourlyRate,
        duration: durationInMinutes,
        hours: hours, // Added hours field
        bookingDate: bookingDate,
        bookingTime: bookingTime,
        status: 'pending',
        address: address,
        notes: notes,
        createdAt: DateTime.now(),
      );

      final docRef = await _firestore.collection('bookings').add(booking.toMap());
      return {
        'success': true, 
        'message': 'Booking created successfully',
        'bookingId': docRef.id,
        'totalPrice': totalPrice,
        'hours': hours,
      };
    } catch (e) {
      print('Error creating booking: $e');
      return {'success': false, 'message': 'Error creating booking: $e'};
    }
  }

  // Get user's bookings
  Stream<List<Booking>> getUserBookings() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('bookings')
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) {
      final bookings = snapshot.docs.map((doc) {
        final data = doc.data();
        return Booking.fromMap(data, doc.id);
      }).toList();
      
      bookings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return bookings;
    });
  }

  // Cancel a booking
  Future<bool> cancelBooking(String bookingId) async {
    try {
      await _firestore.collection('bookings').doc(bookingId).update({
        'status': 'cancelled',
      });
      return true;
    } catch (e) {
      print('Error cancelling booking: $e');
      return false;
    }
  }

  // Add sample services with ₹250 per hour
  Future<void> addSampleServices() async {
    try {
      final services = [
        {
          'name': 'Home Cleaning',
          'description': 'Professional home cleaning service including dusting, mopping, and sanitization.',
          'price': 499.00,
          'hourlyRate': 250.00,
          'icon': '🧹',
          'category': 'Cleaning',
          'duration': 120,
        },
        {
          'name': 'Plumbing Service',
          'description': 'Fix leaks, unclog drains, and repair plumbing fixtures.',
          'price': 799.00,
          'hourlyRate': 250.00,
          'icon': '🔧',
          'category': 'Repair',
          'duration': 60,
        },
        {
          'name': 'Electrical Service',
          'description': 'Electrical repairs, installations, and maintenance.',
          'price': 899.00,
          'hourlyRate': 250.00,
          'icon': '⚡',
          'category': 'Repair',
          'duration': 60,
        },
        {
          'name': 'AC Service',
          'description': 'AC repair, maintenance, and gas refilling.',
          'price': 999.00,
          'hourlyRate': 250.00,
          'icon': '❄️',
          'category': 'Maintenance',
          'duration': 90,
        },
        {
          'name': 'Pest Control',
          'description': 'Complete pest control service for home and office.',
          'price': 1299.00,
          'hourlyRate': 250.00,
          'icon': '🐜',
          'category': 'Cleaning',
          'duration': 90,
        },
        {
          'name': 'Carpentry',
          'description': 'Furniture repair, installation, and custom woodwork.',
          'price': 699.00,
          'hourlyRate': 250.00,
          'icon': '🪵',
          'category': 'Repair',
          'duration': 120,
        },
      ];

      for (var serviceData in services) {
        await _firestore.collection('services').add(serviceData);
      }
      print('Sample services added successfully with ₹250/hour rate');
    } catch (e) {
      print('Error adding sample services: $e');
    }
  }
}