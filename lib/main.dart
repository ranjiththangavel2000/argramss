import 'package:firebase_core/firebase_core.dart' show Firebase;
import 'package:flutter/material.dart';

import 'Firestore_test.dart';
import 'ar_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter AR',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Set the background color to transparent so the image shows through
      appBar: AppBar(
        title: Text('AR Gram'),
        backgroundColor: Colors.pink,
        centerTitle: true,
      ),
      body: Container(

        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ArCube()),
                    );
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color>((_) => Colors.pink),
                    shape: MaterialStateProperty.resolveWith<RoundedRectangleBorder>(
                            (_) => RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  ),
                  child: Text('Place a Cube', style: TextStyle(color: Colors.white)),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => FirestoreTest()),
                    );
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color>((_) => Colors.pink),
                    shape: MaterialStateProperty.resolveWith<RoundedRectangleBorder>(
                            (_) => RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  ),
                  child: Text('See Cubes Nearby', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
