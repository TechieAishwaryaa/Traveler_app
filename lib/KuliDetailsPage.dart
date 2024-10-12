import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';


class KuliDetailsPage extends StatefulWidget {
  final Map<String, dynamic> kuli;
  final Map<String, dynamic> travelerData;
  final String destination;
  final String luggageQuantity;

  const KuliDetailsPage({
    Key? key,
    required this.kuli,
    required this.travelerData,
    required this.destination,
    required this.luggageQuantity,
  }) : super(key: key);

  @override
  _KuliDetailsPageState createState() => _KuliDetailsPageState();
}

class _KuliDetailsPageState extends State<KuliDetailsPage> {
  bool _isSendingSms = false; // State to manage SMS sending

  Future<void> _confirmBooking(BuildContext context) async {
    final firestore = FirebaseFirestore.instance;

    final bookingData = {
      'createdAt': Timestamp.now(),
      'kuli': {
        'kuliId': widget.kuli['id'],
        'name': widget.kuli['name'],
        'phone': widget.kuli['phone'],
        'profileImage': widget.kuli['imageUrl'],
        'station': widget.kuli['station'],
      },
      'traveler': {
        'current_location': widget.travelerData['currentLocation'],
        'destination': widget.destination,
        'name': widget.travelerData['travelerName'],
        'phone_number': widget.travelerData['phone'],
        'photo_url': widget.travelerData['photoUrl'],
        'travelerId': widget.travelerData['travelerId'],
      },
      'luggage': widget.luggageQuantity,
      'status': 'pending',
    };

    try {
      

      // Send SMS
      

      // If SMS is sent successfully, then store booking data
      await firestore.collection('bookings').add(bookingData);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking confirmed for ${widget.kuli['name']}')),
      );
      Navigator.pop(context); // Navigate back if booking is successful
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to confirm booking: $e')),
      );
    } 
  }

  
  @override
  Widget build(BuildContext context) {
    final String profileImageUrl = widget.kuli['profileImage'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.kuli['name']),
        backgroundColor: Colors.deepOrangeAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                backgroundColor: Colors.grey.shade300,
                radius: 70,
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: profileImageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const CircularProgressIndicator(), // Loading indicator
                    errorWidget: (context, url, error) => Image.asset(
                      'assets/logo.png', // Fallback asset image
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Name: ${widget.kuli['name']}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Experience: ${widget.kuli['experience']} years'),
            const SizedBox(height: 8),
            Text('Rating: ${widget.kuli['rating'] ?? 'No rating'}'),
            const SizedBox(height: 8),
            Text('Phone: ${widget.kuli['phone']}'),
            const SizedBox(height: 8),
            Text('Station: ${widget.kuli['station']}'),
            const SizedBox(height: 8),
            Text('Availability: ${widget.kuli['availability'] ?? 'Not specified'}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isSendingSms ? null : () => _confirmBooking(context),
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
              child: _isSendingSms
                  ? const CircularProgressIndicator() // Show loading indicator when sending SMS
                  : const Text('Confirm Booking'),
            ),
          ],
        ),
      ),
    );
  }
}
