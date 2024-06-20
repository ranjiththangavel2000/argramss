// import 'package:firebase_core/firebase_core.dart' show Firebase;
// import 'package:flutter/material.dart';
// import 'Firestore_test.dart';
// import 'ar_model.dart';
// import 'chart.dart';
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter AR',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//         useMaterial3: true,
//       ),
//       home: HomeScreen(),
//     );
//   }
// }
//
// class HomeScreen extends StatelessWidget {
//     @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//
//         title: Text('AR Gram'),
//
//         backgroundColor: Colors.pink,
//
//         centerTitle: true,
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             // Introduction Section
//             Container(
//               padding: EdgeInsets.all(16.0),
//               decoration: BoxDecoration(
//                 color: Colors.pink[50],
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               margin: EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Welcome to AR Gram',
//                     style: TextStyle(
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.pink,
//                     ),
//                   ),
//                   SizedBox(height: 10),
//                   Text(
//                     'Explore Augmented Reality in real life. Place virtual objects in your surroundings and interact with them in real-time.',
//                     style: TextStyle(fontSize: 16),
//                   ),
//                 ],
//               ),
//             ),
//             // Image Section
//             Container(
//               margin: EdgeInsets.all(16.0),
//               height: 230,
//               width: 300,
//               child: Image.asset(
//                 'assets/giphy.gif', // Replace with your image asset path
//                 fit: BoxFit.cover,
//               ),
//             ),
//             // Feature Descriptions
//             Container(
//               padding: EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Features:',
//                     style: TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.pink,
//                     ),
//                   ),
//                   SizedBox(height: 10),
//                   Text(
//                     '1. Place virtual cubes in your surroundings.',
//                     style: TextStyle(fontSize: 16),
//                   ),
//                   Text(
//                     '2. Explore and interact with AR objects nearby.',
//                     style: TextStyle(fontSize: 16),
//                   ),
//                   Text(
//                     '3. Watch videos and learn more about the placed objects.',
//                     style: TextStyle(fontSize: 16),
//                   ),
//                 ],
//               ),
//             ),
//             // Buttons
//             Container(
//               padding: EdgeInsets.symmetric(horizontal: 16.0),
//               child: Column(
//                 children: [
//                   Padding(
//                     padding: EdgeInsets.all(8.0),
//                     child: ElevatedButton(
//                       onPressed: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(builder: (context) => ArCube()),
//                         );
//                       },
//                       style: ButtonStyle(
//                         backgroundColor: MaterialStateProperty.resolveWith<Color>((_) => Colors.pink),
//                         shape: MaterialStateProperty.resolveWith<RoundedRectangleBorder>(
//                                 (_) => RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
//                       ),
//                       child: Text('Place a Cube', style: TextStyle(color: Colors.white)),
//                     ),
//                   ),
//                   Padding(
//                     padding: EdgeInsets.all(8.0),
//                     child: ElevatedButton(
//                       onPressed: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(builder: (context) => FirestoreTest()),
//                         );
//                       },
//                       style: ButtonStyle(
//                         backgroundColor: MaterialStateProperty.resolveWith<Color>((_) => Colors.pink),
//                         shape: MaterialStateProperty.resolveWith<RoundedRectangleBorder>(
//                                 (_) => RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
//                       ),
//                       child: Text('See Cubes Nearby', style: TextStyle(color: Colors.white)),
//                     ),
//                   ),
//                   Padding(
//                     padding: EdgeInsets.all(8.0),
//                     child: ElevatedButton(
//                       onPressed: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(builder: (context) => ChartPage()),
//                         );
//                       },
//                       style: ButtonStyle(
//                         backgroundColor: MaterialStateProperty.resolveWith<Color>((_) => Colors.pink),
//                         shape: MaterialStateProperty.resolveWith<RoundedRectangleBorder>(
//                               (_) => RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                         ),
//                       ),
//                       child: Text('View Engagement Graph', style: TextStyle(color: Colors.white)),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//     }
// }








import 'package:firebase_core/firebase_core.dart' show Firebase;
import 'package:flutter/material.dart';
import 'Firestore_test.dart';
import 'ar_model.dart';
import 'chart.dart';
import 'login.dart';

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
      appBar: AppBar(
        title: Text('AR Gram'),
        backgroundColor: Colors.pink,
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.pink,
              ),
              child: Text(
                'AR Gram Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.login_outlined),
              title: Text('Login'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginRegistrationScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.add_box),
              title: Text('Place a Cube'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ArCube()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.near_me),
              title: Text('See Cubes Nearby'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FirestoreTest()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.show_chart),
              title: Text('View Engagement Graph'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChartPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Introduction Section
            Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.pink[50],
                borderRadius: BorderRadius.circular(10),
              ),
              margin: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome to AR Gram',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.pink,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Explore Augmented Reality in real life. Place virtual objects in your surroundings and interact with them in real-time.',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            // Image Section
            Container(
              margin: EdgeInsets.all(16.0),
              height: 230,
              width: 300,
              child: Image.asset(
                'assets/giphy.gif', // Replace with your image asset path
                fit: BoxFit.cover,
              ),
            ),
            // Feature Descriptions
            Container(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Features:',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.pink,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '1. Place virtual cubes in your surroundings.',
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    '2. Explore and interact with AR objects nearby.',
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    '3. Watch videos and learn more about the placed objects.',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
