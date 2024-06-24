// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'ar_model.dart';
// import 'chart.dart';
// import 'login.dart';
// import 'Firestore_test.dart';
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter AR',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//         useMaterial3: true,
//       ),
//       debugShowCheckedModeBanner: false,
//       home: HomeScreen(),
//     );
//   }
// }
//
// class HomeScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('AR Gram'),
//         backgroundColor: Colors.pink,
//         centerTitle: true,
//         actions: [
//           IconButton(
//             icon: Icon(Icons.login),
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => LoginScreen()),
//               );
//             },
//           ),
//         ],
//       ),
//       drawer: Drawer(
//         child: ListView(
//           padding: EdgeInsets.zero,
//           children: <Widget>[
//             DrawerHeader(
//               decoration: BoxDecoration(
//                 color: Colors.pink,
//               ),
//               child: Text(
//                 'AR Gram Menu',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 24,
//                 ),
//               ),
//             ),
//             ListTile(
//               leading: Icon(Icons.add_box),
//               title: Text('Place a Cube'),
//               onTap: () {
//                 Navigator.pop(context); // Close the drawer
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => ArCube()),
//                 );
//               },
//             ),
//             ListTile(
//               leading: Icon(Icons.near_me),
//               title: Text('See Cubes Nearby'),
//               onTap: () {
//                 Navigator.pop(context); // Close the drawer
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => FirestoreTest()),
//                 );
//               },
//             ),
//             ListTile(
//               leading: Icon(Icons.show_chart),
//               title: Text('View Engagement Graph'),
//               onTap: () {
//                 Navigator.pop(context); // Close the drawer
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => ChartPage()),
//                 );
//               },
//             ),
//           ],
//         ),
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
//           ],
//         ),
//       ),
//     );
//   }
// }









//
//
//
//
//
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'ar_model.dart';
// import 'chart.dart';
// import 'login.dart';
// import 'Firestore_test.dart';
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter AR',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//         useMaterial3: true,
//       ),
//       debugShowCheckedModeBanner: false,
//       home: AuthWrapper(),
//     );
//   }
// }
//
// class AuthWrapper extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<User?>(
//       stream: FirebaseAuth.instance.authStateChanges(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return Center(child: CircularProgressIndicator());
//         } else if (snapshot.hasData) {
//           return HomeScreen(userEmail: snapshot.data!.email);
//         } else {
//           return LoginScreen();
//         }
//       },
//     );
//   }
// }
//
// class HomeScreen extends StatelessWidget {
//   final String? userEmail;
//
//   HomeScreen({this.userEmail});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('AR Gram'),
//         backgroundColor: Colors.pink,
//         centerTitle: true,
//         actions: [
//           if (userEmail != null) ...[
//             IconButton(
//               icon: const Icon(Icons.account_circle),
//               onPressed: () {},
//             ),
//             Padding(
//               padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
//               child: Text(userEmail!),
//             ),
//             IconButton(
//               icon: const Icon(Icons.logout),
//               onPressed: () async {
//                 await FirebaseAuth.instance.signOut();
//               },
//             ),
//           ] else ...[
//             IconButton(
//               icon: const Icon(Icons.login),
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => LoginScreen()),
//                 );
//               },
//             ),
//           ],
//         ],
//       ),
//       drawer: Drawer(
//         child: ListView(
//           padding: EdgeInsets.zero,
//           children: <Widget>[
//             const DrawerHeader(
//               decoration: BoxDecoration(
//                 color: Colors.pink,
//               ),
//               child: Text(
//                 'AR Gram Menu',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 24,
//                 ),
//               ),
//             ),
//             ListTile(
//               leading: const Icon(Icons.add_box),
//               title: const Text('Place a Cube'),
//               onTap: () {
//                 Navigator.pop(context); // Close the drawer
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => ArCube()),
//                 );
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.near_me),
//               title: const Text('See Cubes Nearby'),
//               onTap: () {
//                 Navigator.pop(context); // Close the drawer
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => FirestoreTest()),
//                 );
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.show_chart),
//               title: const Text('View Engagement Graph'),
//               onTap: () {
//                 Navigator.pop(context); // Close the drawer
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => ChartPage()),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             // Introduction Section
//             Container(
//               padding: const EdgeInsets.all(16.0),
//               decoration: BoxDecoration(
//                 color: Colors.pink[50],
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               margin: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: const [
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
//               margin: const EdgeInsets.all(16.0),
//               height: 230,
//               width: 300,
//               child: Image.asset(
//                 'assets/giphy.gif', // Replace with your image asset path
//                 fit: BoxFit.cover,
//               ),
//             ),
//             // Feature Descriptions
//             Container(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: const [
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
//           ],
//         ),
//       ),
//     );
//   }
// }

















//
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'ar_model.dart';
// import 'chart.dart';
// import 'login.dart';
// import 'Firestore_test.dart';
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter AR',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//         useMaterial3: true,
//       ),
//       debugShowCheckedModeBanner: false,
//       home: AuthWrapper(),
//     );
//   }
// }
//
// class AuthWrapper extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<User?>(
//       stream: FirebaseAuth.instance.authStateChanges(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return Center(child: CircularProgressIndicator());
//         } else if (snapshot.hasData) {
//           return HomeScreen(userEmail: snapshot.data!.email);
//         } else {
//           return LoginScreen();
//         }
//       },
//     );
//   }
// }
//
// class HomeScreen extends StatelessWidget {
//   final String? userEmail;
//
//   HomeScreen({this.userEmail});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('AR Gram'),
//         backgroundColor: Colors.pink,
//         centerTitle: true,
//         actions: [
//           if (userEmail != null) ...[
//             IconButton(
//               icon: const Icon(Icons.account_circle),
//               onPressed: () {
//                 // Do something when the user icon is clicked
//               },
//             ),
//           ] else ...[
//             IconButton(
//               icon: const Icon(Icons.login),
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => LoginScreen()),
//                 );
//               },
//             ),
//           ],
//         ],
//       ),
//       drawer: Drawer(
//         child: ListView(
//           padding: EdgeInsets.zero,
//           children: <Widget>[
//             const DrawerHeader(
//               decoration: BoxDecoration(
//                 color: Colors.pink,
//               ),
//               child: Text(
//                 'AR Gram Menu',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 24,
//                 ),
//               ),
//             ),
//             ListTile(
//               leading: const Icon(Icons.add_box),
//               title: const Text('Place a Cube'),
//               onTap: () {
//                 Navigator.pop(context); // Close the drawer
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => ArCube()),
//                 );
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.near_me),
//               title: const Text('See Cubes Nearby'),
//               onTap: () {
//                 Navigator.pop(context); // Close the drawer
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => FirestoreTest()),
//                 );
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.show_chart),
//               title: const Text('View Engagement Graph'),
//               onTap: () {
//                 Navigator.pop(context); // Close the drawer
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => ChartPage()),
//                 );
//               },
//             ),
//             if (userEmail != null) ...[
//               ListTile(
//                 leading: const Icon(Icons.logout),
//                 title: const Text('Logout'),
//                 onTap: () async {
//                   await FirebaseAuth.instance.signOut();
//                 },
//               ),
//             ],
//           ],
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             // Introduction Section
//             Container(
//               padding: const EdgeInsets.all(16.0),
//               decoration: BoxDecoration(
//                 color: Colors.pink[50],
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               margin: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: const [
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
//               margin: const EdgeInsets.all(16.0),
//               height: 230,
//               width: 300,
//               child: Image.asset(
//                 'assets/giphy.gif', // Replace with your image asset path
//                 fit: BoxFit.cover,
//               ),
//             ),
//             // Feature Descriptions
//             Container(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: const [
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
//           ],
//         ),
//       ),
//     );
//   }
// }















import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'ar_model.dart';
import 'chart.dart';
import 'login.dart';
import 'Firestore_test.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter AR',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          return HomeScreen(userEmail: snapshot.data!.email);
        } else {
          return LoginScreen();
        }
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  final String? userEmail;

  HomeScreen({this.userEmail});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AR Gram'),
        backgroundColor: Colors.pink,
        centerTitle: true,
        actions: [
          if (userEmail != null) ...[
            IconButton(
              icon: const Icon(Icons.account_circle),
              onPressed: () {
                // Show a dialog with the user's email when the icon is clicked
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('User Email'),
                      content: Text(userEmail!),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Close'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ] else ...[
            IconButton(
              icon: const Icon(Icons.login),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
            ),
          ],
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
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
              leading: const Icon(Icons.add_box),
              title: const Text('Place a Cube'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ArCube()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.near_me),
              title: const Text('See Cubes Nearby'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FirestoreTest()),
                );
              },
            ),ListTile(
              leading: const Icon(Icons.add_box),
              title: const Text('cube details'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ArCube()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.show_chart),
              title: const Text('View Engagement Graph'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChartPage()),
                );
              },
            ),
            if (userEmail != null) ...[
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                },
              ),
            ],
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Introduction Section
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.pink[50],
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
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
              margin: const EdgeInsets.all(16.0),
              height: 230,
              width: 300,
              child: Image.asset(
                'assets/giphy.gif', // Replace with your image asset path
                fit: BoxFit.cover,
              ),
            ),
            // Feature Descriptions
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
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
