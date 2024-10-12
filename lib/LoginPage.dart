import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'RegistrationPage.dart';
import 'TravelerInfoPage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose(); // Dispose the controller when not needed
    super.dispose();
  }

  Future<void> login(BuildContext context) async {
    final email = emailController.text.trim();

    // Check if the email exists in the travelers collection
    final travelerSnapshot = await FirebaseFirestore.instance
        .collection('travelers')
        .where('email', isEqualTo: email)
        .get();

    if (travelerSnapshot.docs.isNotEmpty) {
      // If email exists, get the traveler's data
      final travelerData = travelerSnapshot.docs.first.data();

      // Debugging output to check what data we fetched
      print('Traveler Data: $travelerData');

      // Extract necessary data with the modified structure
      final travelerInfo = {
        'email': travelerData['email'] ?? '',
        'password': travelerData['password'] ?? '', // Ensure 'password' is included if needed
        'phone': travelerData['phone'] ?? '',
        'photoUrl': travelerData['photoUrl'] ?? '',
        'travelerId': travelerData['travelerId'] ?? '',
        'travelerName': travelerData['travelerName'] ?? 'Unknown',
      };

      // Check if travelerName was fetched correctly
      if (travelerInfo['travelerName'] != 'Unknown') {
        // Navigate to TravelerInfoPage with traveler data
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TravelerInfoPage(
              travelerData: travelerInfo, // Pass all required data to the next page
            ),
          ),
        );
      } else {
        // Handle case where travelerName is not fetched correctly
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Traveler name not found. Please check your data.'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else {
      // Show an error if email is not found
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Email not found. Please register first.'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Traveler Login',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.deepOrangeAccent[100],
        centerTitle: true,
        elevation: 8,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Welcome Back!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Please login with your registered email.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 40),
              // Email Input Field
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
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
                    Icons.email_outlined,
                    color: Colors.deepOrange,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                ),
              ),
              const SizedBox(height: 30),
              // Login Button
              ElevatedButton(
                onPressed: () => login(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrangeAccent,
                  padding: const EdgeInsets.symmetric(
                      vertical: 15, horizontal: 30),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text('Login'),
              ),
              const SizedBox(height: 20),
              // Register Button
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegistrationPage(),
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      vertical: 12, horizontal: 30),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text(
                  'Don\'t have an account? Register',
                  style: TextStyle(color: Colors.deepOrangeAccent),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
