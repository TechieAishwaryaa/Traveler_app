import 'package:flutter/material.dart';
import 'KuliDetailsPage.dart';

class KuliListPage extends StatelessWidget {
  final String station;
  final List<Map<String, dynamic>> kulis;
  final Map<String, dynamic> travelerData; // New parameter for traveler data
  final String destination; // New parameter for destination
  final String luggageQuantity; // New parameter for luggage quantity

  const KuliListPage({
    Key? key,
    required this.station,
    required this.kulis,
    required this.travelerData, // Add traveler data to the constructor
    required this.destination, // Add destination to the constructor
    required this.luggageQuantity, // Add luggage quantity to the constructor
  }) : super(key: key);

  // Navigate to the Kuli Details page
  void _navigateToKuliDetails(BuildContext context, Map<String, dynamic> kuli) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => KuliDetailsPage(
          kuli: kuli,
          travelerData: travelerData, // Pass traveler data
          destination: destination, // Pass destination
          luggageQuantity: luggageQuantity, // Pass luggage quantity
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Kulis'),
        backgroundColor: Colors.deepOrangeAccent,
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: kulis.length,
        itemBuilder: (context, index) {
          final kuli = kulis[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(kuli['profileImage']),
              ),
              title: Text(kuli['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Experience: ${kuli['experience']}'),
                  Text('Rating: ${kuli['rating'] ?? 'No rating'}'),  // Display rating
                  Text('Phone: ${kuli['phone']}'),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.select_all, color: Colors.deepOrange),
                onPressed: () => _navigateToKuliDetails(context, kuli), // Navigate to details page
              ),
            ),
          );
        },
      ),
    );
  }
}
