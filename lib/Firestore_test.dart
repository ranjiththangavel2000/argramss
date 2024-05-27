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
  double currentLatitude = 0.0;
  double currentLongitude = 0.0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _deleteAllCubeLocations();
    _getLocation();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _getLocation();
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
      // Place cubes automatically when location is updated
      await _cubePlace();
    } catch (e) {
      print("Error: $e");
    }
  }

  void cubeCreate(ArCoreController controller) {
    coreController = controller;
    coreController!.onPlaneDetected = null;
  }

  Future<void> _deleteAllCubeLocations() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference collectionRef = firestore.collection('cube_locations_placed');

    QuerySnapshot querySnapshot = await collectionRef.get();
    for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
      await documentSnapshot.reference.delete();
    }

    Fluttertoast.showToast(
      msg: 'All cube locations deleted',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );
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
        DocumentSnapshot placedCubeSnapshot = await firestore.collection('cube_locations_placed').doc(cubeID).get();
        if (placedCubeSnapshot.exists) {
          continue;
        }

        // Convert lat/lon to AR coordinates (x, z) relative to the current device location
        double x = (cubeLat - currentLatitude) * 111139; // in meters
        double z = (cubeLon - currentLongitude) * 111139 * cos(currentLatitude * (pi / 180)); // in meters

        final response = await http.get(Uri.parse(thumb));
        if (response.statusCode == 200) {
          final bytes = response.bodyBytes;
          final materials = ArCoreMaterial(color: Colors.red, metallic: 0.5, textureBytes: bytes);

          final cube = ArCoreCube(
            size: vector64.Vector3(0.35, 0.9, 0.5),
            materials: [materials],
          );

          final node = ArCoreRotatingNode(
            shape: cube,
            degreesPerSecond: 30,
            position: vector64.Vector3(x, y + 0.25, z),
            name: cubeID,
          );

          coreController!.addArCoreNode(node);

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

  Future<void> _saveCubePosition(double x, double y, double z, double phoneLat, double phoneLon, String cubeID) async {
    await FirebaseFirestore.instance.collection('cube_locations_placed').doc(cubeID).set({
      'x': x,
      'y': y,
      'z': z,
      'phoneLat': phoneLat,
      'phoneLon': phoneLon,
      'cubeID': cubeID,
    });

    Fluttertoast.showToast(
      msg: 'Cube position saved to Firestore with ID: $cubeID',
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
        msg: 'Error: $error',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cube Placement"),
        backgroundColor: Colors.pink,
        centerTitle: true,
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
        ],
      ),
    );
  }
}
































