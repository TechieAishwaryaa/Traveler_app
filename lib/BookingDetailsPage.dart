import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart'; // Import url_launcher for payment URL
import 'FeedbackPage.dart';
class BookingDetailsPage extends StatefulWidget {
  final Map<String, dynamic> booking;

  const BookingDetailsPage({
    Key? key,
    required this.booking,
  }) : super(key: key);

  @override
  _BookingDetailsPageState createState() => _BookingDetailsPageState();
}

class _BookingDetailsPageState extends State<BookingDetailsPage> {
  String _price = 'Fetching...'; // State for price

  @override
  void initState() {
    super.initState();
    print('Booking data in initState: ${widget.booking}');
    _fetchPriceByTravelerId(); // Fetch the price by travelerId when the page loads
  }

  // Method to fetch the price from Firestore using travelerId
  Future<void> _fetchPriceByTravelerId() async {
  try {
    // Get all documents from the 'bookingPrice' collection
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('bookingPrice')
        .get();

    print('Total documents fetched: ${querySnapshot.docs.length}'); // Debug log

    // Traverse through each document
    for (var doc in querySnapshot.docs) {
      var bookingData = doc.data() as Map<String, dynamic>;

      // Check if the 'travelerId' in the document matches the one we are looking for
      if (bookingData['travelerId'] == widget.booking['traveler']['travelerId']) {
        print('Matching travelerId found: ${bookingData['travelerId']}'); // Debug log
        setState(() {
          _price = bookingData['price'].toString(); // Convert price to string
        });
        return; // Exit once the matching travelerId is found and price is fetched
      }
    }

    // If no matching travelerId is found, set an error message
    print('No matching travelerId found');
    setState(() {
      _price = 'Price not found';
    });
  } catch (e) {
    print('Error fetching price: $e');
    setState(() {
      _price = 'Error fetching price';
    });
  }
}


  // Method to open UPI payment app (e.g., PhonePe or Google Pay)
  Future<void> _launchPayment() async {
    // Ensure the amount is formatted correctly
    String formattedAmount = _price != 'Fetching...' && _price != 'Error fetching price' 
        ? _price 
        : '0.00'; // Default to '0.00' if price is not valid
    
    // Fetch the Kuli's phone number for the payment
    String kuliPhoneNumber = widget.booking['kuli']['phone'] ?? ''; // Use Kuli's phone number

    if (kuliPhoneNumber.isEmpty) {
      print('Kuli phone number is missing');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kuli phone number is missing')),
      );
      return;
    }

    final Uri paymentUri = Uri(
      scheme: 'upi',
      host: 'pay',
      queryParameters: {
        'pa': '$kuliPhoneNumber@upi', // Use Kuli's phone number as UPI ID
        'pn': 'Kuli Service',
        'tn': 'Kuli Booking Payment',
        'am': formattedAmount, // Correctly passing the fetched price
        'cu': 'INR', // Currency code
      },
    );

    print('UPI Payment URI: $paymentUri'); // Print the final UPI URI for debugging

    if (await canLaunchUrl(paymentUri)) {
      await launchUrl(paymentUri).then((_) {
      // Navigate to FeedbackPage after successful payment
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FeedbackPage(
            travelerId: widget.booking['traveler']['travelerId'],
            travelerName: widget.booking['traveler']['name'],
            kuliId: widget.booking['kuli']['kuliId'],
            kuliName: widget.booking['kuli']['name'],
          ),
        ),
      );
    });
    } else {
      print('Cannot launch UPI payment app');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open payment app')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String profileImageUrl = widget.booking['kuli']['profileImage'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Details'),
        backgroundColor: Colors.deepOrangeAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Square image of the Kuli
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: profileImageUrl.isNotEmpty
                      ? Image.network(profileImageUrl, fit: BoxFit.cover)
                      : const Icon(Icons.person, size: 50, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Traveler: ${widget.booking['traveler']['travelerName']}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Kuli: ${widget.booking['kuli']['name'] ?? 'N/A'}',
              style: const TextStyle(fontSize: 20),
            ),
            Text(
              'Kuli Phone: ${widget.booking['kuli']['phone'] ?? 'N/A'}',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 10),
            Text(
              'Destination: ${widget.booking['traveler']['destination'] ?? 'N/A'}',
              style: const TextStyle(fontSize: 20),
            ),
            Text(
              'Luggage Quantity: ${widget.booking['luggage'] ?? 'N/A'}',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 10),
            Text(
              'Status: ${widget.booking['status'] ?? 'N/A'}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.deepOrangeAccent,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Price: ₹$_price',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _launchPayment, // Launch payment with fetched price
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
              child: const Text('Book and Pay Now'),
            ),
          ],
        ),
      ),
    );
  }
}