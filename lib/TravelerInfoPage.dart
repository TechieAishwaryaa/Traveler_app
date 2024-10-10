import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'KuliListPage.dart';

class TravelerInfoPage extends StatefulWidget {
  final Map<String, dynamic> travelerData;

  const TravelerInfoPage({Key? key, required this.travelerData}) : super(key: key);

  @override
  _TravelerInfoPageState createState() => _TravelerInfoPageState();
}

class _TravelerInfoPageState extends State<TravelerInfoPage> {
  final TextEditingController destinationController = TextEditingController();
  final TextEditingController luggageController = TextEditingController();
  int _selectedIndex = 0;
  List<Map<String, dynamic>> _bookings = [];

  @override
  void initState() {
    super.initState();
    _fetchBookings(); // Fetch bookings when the widget is initialized
  }

  @override
  void dispose() {
    destinationController.dispose();
    luggageController.dispose();
    super.dispose();
  }

  Future<void> _fetchBookings() async {
  try {
    final travelerId = widget.travelerData['travelerId']; // Get the current traveler ID
    final bookingsCollection = FirebaseFirestore.instance.collection('bookings');
    final snapshot = await bookingsCollection.get();
    final List<Map<String, dynamic>> fetchedBookings = [];

    for (var doc in snapshot.docs) {
      // Access the travelerId within the traveler map
      final travelerMap = doc.data()['traveler'] as Map<String, dynamic>;

      if (travelerMap['travelerId'] == travelerId) {
        fetchedBookings.add({
          ...doc.data() as Map<String, dynamic>,
          'id': doc.id, // Add document ID to the booking map
        });
      }
    }

    setState(() {
      _bookings = fetchedBookings;
    });

    print('Bookings fetched for travelerId $travelerId: $_bookings');
  } catch (e) {
    print('Error fetching bookings: $e');
  }
}

  // Fetch kulis based on the destination
  Future<List<Map<String, dynamic>>> _fetchKulis(String station) async {
    try {
      print('Fetching kulis for station: $station');

      final QuerySnapshot kulisSnapshot = await FirebaseFirestore.instance
          .collection('kuli')
          .where('station', isEqualTo: station)
          .get();

      if (kulisSnapshot.docs.isEmpty) {
        print('No kulis found for station: $station');
        return [];
      }

      return kulisSnapshot.docs.map((doc) {
        print('Kuli found: ${doc.data()}');
        return {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        };
      }).toList();
    } catch (e) {
      print('Error fetching kulis: $e');
      return [];
    }
  }

  // Submit the destination and luggage info
  void _submitTravelerInfo() async {
    final destination = destinationController.text;
    final luggageQuantity = luggageController.text;

    if (destination.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide a destination'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Fetch available kulis
    final kulis = await _fetchKulis(destination);

    // Navigate to KuliListPage with kulis data, traveler info, destination, and luggage quantity
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => KuliListPage(
          station: destination,
          kulis: kulis,
          travelerData: widget.travelerData,
          destination: destination,
          luggageQuantity: luggageQuantity,
        ),
      ),
    );
  }

  Widget _buildPageContent() {
  if (_selectedIndex == 0) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Provide Your Travel Details',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.deepOrange,
          ),
        ),
        const SizedBox(height: 30),
        TextField(
          controller: destinationController,
          decoration: InputDecoration(
            labelText: 'Destination',
            labelStyle: const TextStyle(color: Colors.deepOrangeAccent),
            filled: true,
            fillColor: Colors.deepOrange[50],
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: Colors.deepOrange),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: Colors.deepOrangeAccent),
            ),
            prefixIcon: const Icon(
              Icons.location_on_outlined,
              color: Colors.deepOrange,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: luggageController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Quantity of Luggage',
            labelStyle: const TextStyle(color: Colors.deepOrangeAccent),
            filled: true,
            fillColor: Colors.deepOrange[50],
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: Colors.deepOrange),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: Colors.deepOrangeAccent),
            ),
            prefixIcon: const Icon(
              Icons.work_outline,
              color: Colors.deepOrange,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          ),
        ),
        const SizedBox(height: 40),
        ElevatedButton(
          onPressed: _submitTravelerInfo,
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
          child: const Text('Submit Info'),
        ),
      ],
    );
  } else {
    return _bookings.isEmpty
        ? const Center(
            child: Text(
              'No bookings found.',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.deepOrange,
              ),
            ),
          )
        : SingleChildScrollView(
            child: Column(
              children: _bookings.map((booking) {
                // Check if the booking status is 'confirmed'
                if (booking['status'] == 'confirmed') {
                  // Show confirmation dialog
                  Future.delayed(Duration.zero, () {
                    _showConfirmationDialog();
                  });
                }

                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundImage: NetworkImage(booking['kuli']['profileImage']),
                              radius: 30,
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Kuli: ${booking['kuli']['name']}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Station: ${booking['kuli']['station']}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Traveler: ${booking['traveler']['name']}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Phone: ${booking['traveler']['phone_number']}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Status: ${booking['kuli']['status']}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.deepOrange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          );
  }
}

// Method to show confirmation dialog
void _showConfirmationDialog() {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Booking Confirmed'),
        content: const Text('Your booking has been confirmed by the Kuli.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Traveler Information',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.deepOrangeAccent[100],
        centerTitle: true,
        elevation: 8,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: _buildPageContent(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        backgroundColor: Colors.white,
        selectedItemColor: Colors.deepOrange,
        unselectedItemColor: Colors.deepOrangeAccent[100],
        selectedIconTheme: const IconThemeData(color: Colors.deepOrange, size: 28),
        unselectedIconTheme: const IconThemeData(color: Colors.deepOrangeAccent, size: 24),
        selectedLabelStyle: const TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(color: Colors.deepOrangeAccent),
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.add_location_alt_outlined),
            label: 'Choose Location',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.view_list),
            label: 'View Bookings',
          ),
        ],
      ),
    );
  }
}
