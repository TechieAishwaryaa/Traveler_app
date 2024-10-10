import 'package:flutter/material.dart';
import 'LoginPage.dart'; // Import the Traveler Info page
import 'package:firebase_core/firebase_core.dart'; // Import Firebase core
//import 'firebase_service.dart'; 

const firebaseConfig = {
  "apiKey": "AIzaSyAABLBBksiKmh72rBTBEzL0Qh1_RD3NUD8",
  "authDomain": "book-my-coolie-82e3c.firebaseapp.com",
  "projectId": "book-my-coolie-82e3c",
  "storageBucket": "book-my-coolie-82e3c.appspot.com",
  "messagingSenderId": "266668166073",
  "appId": "1:266668166073:web:84f260b6f4970f48e00468",
  "measurementId": "G-305ZHE7MN9",
};

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: firebaseConfig["apiKey"]!,
      authDomain: firebaseConfig["authDomain"]!,
      projectId: firebaseConfig["projectId"]!,
      storageBucket: firebaseConfig["storageBucket"]!,
      messagingSenderId: firebaseConfig["messagingSenderId"]!,
      appId: firebaseConfig["appId"]!,
      measurementId: firebaseConfig["measurementId"]!,
    ),
  ); // Ensure Firebase is initialized
  //await FirebaseService.setupFCM();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Book My Kuli',
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
        scaffoldBackgroundColor: Colors.deepOrange[50],
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepOrangeAccent,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      home: const WelcomePage(),
    );
  }
}

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Traveler Login',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.deepOrangeAccent[100],
        centerTitle: true,
        elevation: 8,
      ),
      body: Center( // Center the contents vertically and horizontally
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Circular logo image
              CircleAvatar(
                backgroundImage: const AssetImage('assets/logo.png'), // Ensure this path is correct
                radius: 80,
                backgroundColor: Colors.deepOrangeAccent[100],
              ),
              const SizedBox(height: 40),

              // Welcome text
              const Text(
                'Welcome to Book My Kuli!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrangeAccent,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),

              const Text(
                'Login to proceed with booking',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.deepOrangeAccent,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 60),

              // Login button
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginPage()),
                  );
                },
                child: const Text('Login to Traveler Page'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
