import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';  // Import Firestore
import 'KuliDetailsPage.dart';

class KuliListPage extends StatefulWidget {
  final String station;
  final Map<String, dynamic> travelerData; // Traveler data
  final String destination; // Destination
  final String luggageQuantity; // Luggage quantity

  const KuliListPage({
    Key? key,
    required this.station,
    required this.travelerData,
    required this.destination,
    required this.luggageQuantity,
  }) : super(key: key);

  @override
  _KuliListPageState createState() => _KuliListPageState();
}

class _KuliListPageState extends State<KuliListPage> {
  List<Map<String, dynamic>> kulis = []; // Initialize empty list for Kulis
  bool isLoading = true;

  // Fetch Kulis matching the destination
  Future<void> _fetchKulis() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('kuli') // Assuming 'kuli' is your collection name
          .where('station', isEqualTo: widget.destination) // Filter by destination
          .get();

      setState(() {
        kulis = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
        isLoading = false; // Stop the loading indicator
      });
    } catch (error) {
      print('Error fetching Kulis: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchKulis(); // Fetch Kulis on page load
  }

  // Navigate to Kuli Details page
  void _navigateToKuliDetails(BuildContext context, Map<String, dynamic> kuli) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => KuliDetailsPage(
          kuli: kuli,
          travelerData: widget.travelerData,
          destination: widget.destination,
          luggageQuantity: widget.luggageQuantity,
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // Loading indicator
          : kulis.isEmpty
              ? const Center(child: Text('No Kulis available for this destination'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: kulis.length,
                  itemBuilder: (context, index) {
                    final kuli = kulis[index];

                    // Check for null values and provide default values if necessary
                    final String name = kuli['name'] ?? 'Unknown Kuli';
                    final String phone = kuli['phone'] ?? 'No phone number available';
                    final String experience = kuli['experience'] ?? 'Experience not specified';
                    final String rating = kuli['rating']?.toString() ?? 'No rating'; // Ensure rating is a string
                    final String profileImage = kuli['imageUrl'] ?? 'assets/default_avatar.png'; // Fallback image

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(profileImage),
                        ),
                        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Experience: $experience'),
                            Text('Rating: $rating'),  // Display rating
                            Text('Phone: $phone'),
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
