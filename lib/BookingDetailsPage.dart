import 'package:flutter/material.dart';

class BookingDetailsPage extends StatelessWidget {
  final Map<String, dynamic> booking;

  const BookingDetailsPage({Key? key, required this.booking}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Details'),
        backgroundColor: Colors.deepOrangeAccent, // Consistent color with KuliDetailsPage
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Traveler: ${booking['traveler']['name']}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Kuli: ${booking['kuli']['name'] ?? 'N/A'}',
              style: const TextStyle(fontSize: 20),
            ),
            Text(
              'Kuli Phone: ${booking['kuli']['phone'] ?? 'N/A'}',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 10),
            Text(
              'Destination: ${booking['traveler']['destination'] ?? 'N/A'}',
              style: const TextStyle(fontSize: 20),
            ),
            Text(
              'Luggage Quantity: ${booking['luggage'] ?? 'N/A'}',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 10),
            Text(
              'Status: ${booking['status'] ?? 'N/A'}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.deepOrangeAccent, // Change color to match KuliDetailsPage
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Booking Details:',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(booking['details'] ?? 'No additional details available'),
          ],
        ),
      ),
    );
  }
}
