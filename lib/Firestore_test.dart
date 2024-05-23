import 'dart:math';
import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vector64;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'cube_video.dart';
class FirestoreTest extends StatefulWidget {
  @override
  _FirestoreTestState createState() => _FirestoreTestState();
}
class _FirestoreTestState extends State<FirestoreTest> {
  ArCoreController? coreController;
  String planeCoordinates = '';
  double currentLatitude = 0.0;
  double currentLongitude = 0.0;
  late Timer _timer;
  List<String> placedCubes = []; // List to keep track of placed cubes

  @override
  void initState() {
    super.initState();
    _getLocation();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _getLocation();
      _cubePlace();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    coreController?.dispose();
    super.dispose();
  }

  Future<void> _getLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
      setState(() {
        currentLatitude = position.latitude;
        currentLongitude = position.longitude;
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  void cubeCreate(ArCoreController controller) {
    coreController = controller;
    coreController!.onPlaneDetected = null;
  }

  Future<void> _cubePlace() async {
    if (coreController == null) {
      Fluttertoast.showToast(
        msg: 'ARCore controller is not initialized yet.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      QuerySnapshot querySnapshot = await firestore.collection('cubes').get();

      for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
        var data = documentSnapshot.data() as Map<String, dynamic>?;

        if (data == null) {
          Fluttertoast.showToast(
            msg: 'Invalid data for document: ${documentSnapshot.id}',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
          continue;
        }

        double cubeLat = data['CubeLatitude'];
        double cubeLon = data['CubeLongitude'];
        double y = data['CubeVectorPosition']['y']?.toDouble() ?? 0.0;
        String cubeID = documentSnapshot.id;
        String thumb = data['thumbImage'];

        // Check if the cube is already placed
        if (placedCubes.contains(cubeID)) {
          continue;
        }

        // Calculate the distance between the current position and the cube's position
        double distance = _calculateDistance(currentLatitude, currentLongitude, cubeLat, cubeLon);

        if (distance <= 5.0) {
          // Convert lat/lon to AR coordinates (x, z)
          double x = (cubeLat - currentLatitude) * 111139;
          double z = (cubeLon - currentLongitude) * 111139 * cos(currentLatitude * (pi / 180));

          final response = await http.get(Uri.parse(thumb));
          if (response.statusCode == 200) {
            final bytes = response.bodyBytes;
            final materials = ArCoreMaterial(color: Colors.red, metallic: 0.5, textureBytes: bytes);

            final cube = ArCoreCube(
              size: vector64.Vector3(0.3, 0.5, 0.35),
              materials: [materials],
            );

            final node = ArCoreRotatingNode(
              shape: cube,
              degreesPerSecond: 30,
              position: vector64.Vector3(x, y + 0.25, z),
              name: cubeID,
            );

            coreController!.addArCoreNode(node);

            placedCubes.add(cubeID); // Add cube ID to the list of placed cubes

            Fluttertoast.showToast(
              msg: 'Cube Placed',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.yellow,
              textColor: Colors.white,
            );

            coreController!.onNodeTap = _onArCoreNodeTap;
            await _saveCubePosition(x, y, z, currentLatitude, currentLongitude, cubeID);
          } else {
            Fluttertoast.showToast(
              msg: 'Failed to load image from URL: ${response.statusCode}',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.red,
              textColor: Colors.white,
            );
          }
        }
      }
    } catch (error) {
      Fluttertoast.showToast(
        msg: 'Failed to place cube: $error',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371000; // meters
    double dLat = (lat2 - lat1) * (pi / 180);
    double dLon = (lon2 - lon1) * (pi / 180);
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * (pi / 180)) * cos(lat2 * (pi / 180)) * sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  Future<void> _saveCubePosition(double x, double y, double z, double phoneLat, double phoneLon, String cubeID) async {
    DocumentReference ref = await FirebaseFirestore.instance.collection('cube_locations_placed').add({
      'x': x,
      'y': y,
      'z': z,
      'phoneLat': phoneLat,
      'phoneLon': phoneLon,
      'cubeID': cubeID,
    });

    Fluttertoast.showToast(
      msg: 'Cube position saved to Firestore with ID: ${ref.id}',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );
  }

  void _onArCoreNodeTap(String name) async {
    try {
      DocumentSnapshot documents = await FirebaseFirestore.instance.collection('cubes').doc(name).get();
      String nodeVideoUrl = documents['UploadedFilePath'];
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoPlayerScreen(videoUrl: nodeVideoUrl),
        ),
      );
    } catch (error) {
      Fluttertoast.showToast(
        msg: 'error : $error',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cube Placement"),
      ),
      body: Column(
        children: [
          // Display current latitude and longitude
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Current Location: Lat: $currentLatitude, Lon: $currentLongitude",
              style: TextStyle(fontSize: 16),
            ),
          ),
          // ARCore view
          Expanded(
            child: ArCoreView(
              onArCoreViewCreated: cubeCreate,
              enablePlaneRenderer: true,
              enableTapRecognizer: true,
              enableUpdateListener: true,
            ),
          ),
          // Button to place cubes
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () async {
                await _cubePlace();
              },
              child: Text('Get Cubes'),
            ),
          ),
        ],
      ),
    );
  }
}
