import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';  // Import url_launcher for SMS

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
  bool _isProcessing = false; // State to manage button state

  // Method to send SMS to the intended kuli
  Future<void> _sendSmsAndConfirmBooking(BuildContext context) async {
    setState(() {
      _isProcessing = true;  // Show loading state
    });

    final String phoneNumber = widget.kuli['phone'] ?? '';
    final String smsBody = "Hello ${widget.kuli['name']}, "
        "I would like to book your services as a kuli. "
        "Please contact me for further details.";

    // SMS URL scheme for sending an SMS
    final Uri smsUri = Uri(
      scheme: 'sms',
      path: phoneNumber,
      queryParameters: <String, String>{'body': smsBody},
    );

    // Launch the SMS app using canLaunchUrl and launchUrl
    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri);

      // Proceed with confirming the booking in Firestore
      await _confirmBooking(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not send SMS')),
      );
      setState(() {
        _isProcessing = false; // Stop loading state
      });
    }
  }

  // Confirm booking and store booking details in Firestore
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
      // Store booking data in Firestore
      await firestore.collection('bookings').add(bookingData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking confirmed for ${widget.kuli['name']}')),
      );

      // Navigate back to the previous screen after booking is successful
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to confirm booking: $e')),
      );
    } finally {
      setState(() {
        _isProcessing = false; // Stop loading state
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get profile image URL or use a placeholder
    final String profileImageUrl = widget.kuli['imageUrl'] ?? '';

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
                  child: Image.network(profileImageUrl),
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
              onPressed: _isProcessing
                  ? null
                  : () => _sendSmsAndConfirmBooking(context),  // Call combined function
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
              child: _isProcessing
                  ? const CircularProgressIndicator() // Show loading indicator when processing
                  : const Text('Confirm Booking & Send SMS'),
            ),
          ],
        ),
      ),
    );
  }
}
