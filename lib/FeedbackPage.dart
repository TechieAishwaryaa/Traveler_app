import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackPage extends StatefulWidget {
  final String travelerId;
  final String travelerName;
  final String kuliId;
  final String kuliName;

  const FeedbackPage({
    Key? key,
    required this.travelerId,
    required this.travelerName,
    required this.kuliId,
    required this.kuliName,
  }) : super(key: key);

  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  double _rating = 0.0; // State for rating
  String _feedbackText = ''; // State for feedback text

  // Method to submit feedback to Firestore
  Future<void> _submitFeedback() async {
    if (_rating == 0.0 || _feedbackText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a rating and feedback')),
      );
      return;
    }

    // Create a feedback map
    final feedbackData = {
      'rating': _rating.toString(),
      'feedbackText': _feedbackText,
      'kuliId': widget.kuliId,
      'kuliName': widget.kuliName,
      'serviceDate': Timestamp.now(), // Current timestamp
      'travelerId': widget.travelerId,
      'travelerName': widget.travelerName,
    };

    try {
      // Add feedback data to Firestore
      await FirebaseFirestore.instance.collection('feedback').add(feedbackData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Feedback submitted successfully')),
      );
      Navigator.pop(context); // Go back to the previous page
    } catch (e) {
      print('Error submitting feedback: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error submitting feedback')),
      );
    }
  }

  // Widget to build star rating system
  Widget _buildStarRating() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: List.generate(5, (index) {
        return IconButton(
          icon: Icon(
            index < _rating ? Icons.star : Icons.star_border,
            color: Colors.deepOrangeAccent,
          ),
          onPressed: () {
            setState(() {
              _rating = index + 1.0; // Update rating based on star tapped
            });
          },
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedback'),
        backgroundColor: Colors.deepOrangeAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Rate Your Experience:',
              style: TextStyle(fontSize: 20),
            ),
            _buildStarRating(), // Display the star rating widget
            const SizedBox(height: 20),
            const Text(
              'Your Feedback:',
              style: TextStyle(fontSize: 20),
            ),
            TextField(
              onChanged: (value) {
                setState(() {
                  _feedbackText = value;
                });
              },
              maxLines: 3,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Write your feedback here...',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitFeedback,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrangeAccent,
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text('Submit Feedback'),
            ),
          ],
        ),
      ),
    );
  }
}
