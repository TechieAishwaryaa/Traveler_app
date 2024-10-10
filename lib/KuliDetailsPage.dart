import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class KuliDetailsPage extends StatelessWidget {
  final Map<String, dynamic> kuli;
  final Map<String, dynamic> travelerData; // Accept traveler data
  final String destination; // Accept destination
  final String luggageQuantity; // Accept luggage quantity

  const KuliDetailsPage({
    Key? key,
    required this.kuli,
    required this.travelerData, // Accept traveler data
    required this.destination, // Accept destination
    required this.luggageQuantity, // Accept luggage quantity
  }) : super(key: key);

  // Method to confirm the booking and store the data in Firestore
  Future<void> _confirmBooking(BuildContext context) async {
    // Get the Firestore instance
    final firestore = FirebaseFirestore.instance;

    // Create the booking data
    final bookingData = {
      'createdAt': Timestamp.now(),
      'kuli': {
        'kuliId': kuli['id'], // Use the kuli's ID
        'name': kuli['name'],
        'phone': kuli['phone'],
        'profileImage': kuli['imageUrl'],
        'station': kuli['station'],
        'status': 'pending',
      },
      'traveler': {
        'current_location': travelerData['currentLocation'], // Current location from traveler data
        'destination': destination,
        'name': travelerData['travelerName'],
        'phone_number': travelerData['phone'],
        'photo_url': travelerData['photoUrl'], // Use traveler photo URL
        'travelerId': travelerData['travelerId'], // Use traveler ID
      },
      'luggage': luggageQuantity, // Store luggage details
    };

    // Add booking to Firestore
    try {
      await firestore.collection('bookings').add(bookingData);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking confirmed for ${kuli['name']}')),
      );
      Navigator.pop(context); // Optionally, navigate back to the previous page
    } catch (e) {
      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to confirm booking: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(kuli['name']),
        backgroundColor: Colors.deepOrangeAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                backgroundImage: NetworkImage(kuli['profileImage']),
                radius: 70, // Increased radius for a larger profile picture
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Name: ${kuli['name']}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Experience: ${kuli['experience']} years'),
            const SizedBox(height: 8),
            Text('Rating: ${kuli['rating'] ?? 'No rating'}'),
            const SizedBox(height: 8),
            Text('Phone: ${kuli['phone']}'),
            const SizedBox(height: 8),
            Text('Station: ${kuli['station']}'), // Example additional info
            const SizedBox(height: 8),
            Text('Availability: ${kuli['availability'] ?? 'Not specified'}'), // Example additional info
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _confirmBooking(context), // Confirm booking
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrangeAccent,
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: const Text('Confirm Booking'),
            ),
          ],
        ),
      ),
    );
  }
}
