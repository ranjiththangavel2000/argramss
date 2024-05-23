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

  @override
  void initState() {
    super.initState();
    _getLocation();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _getLocation();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
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
      Position currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

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

        var cubeMap = data['CubeVectorPosition'];
        double y = cubeMap['y']?.toDouble() ?? 0.0;

        double cubeLat = data['CubeLatitude'];
        double cubeLon = data['CubeLongitude'];
        double phoneLon = currentPosition.longitude;
        double phoneLat = currentPosition.latitude;
        String cubeID = documentSnapshot.id;
        String thumb = data['thumbImage'];

        if (phoneLat < cubeLat + 0.0000300 && phoneLat > cubeLat - 0.0000300) {
          if (phoneLon < cubeLon + 0.0000300 && phoneLon > cubeLon - 0.0000300) {
            double x = (cubeLat - phoneLat) / 0.00001;
            double z = (cubeLon - phoneLon) / 0.00001;

            Fluttertoast.showToast(
              msg: 'x : $x y : $y z : $z',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.red,
              textColor: Colors.white,
            );

            final response = await http.get(Uri.parse(thumb));
            if (response.statusCode == 200) {

              final bytes = response.bodyBytes;
              final materials = ArCoreMaterial(color : Colors.red, metallic: 0.5, textureBytes: bytes);

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

              Fluttertoast.showToast(
                msg: 'Cube Placed',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                backgroundColor: Colors.yellow,
                textColor: Colors.white,
              );
              coreController!.onNodeTap=_onArCoreNodeTap;
              await _saveCubePosition(x, y, z, phoneLat, phoneLon, cubeID);

            } else {
              Fluttertoast.showToast(
                msg: 'Failed to load image from URL: ${response.statusCode}',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                backgroundColor: Colors.red,
                textColor: Colors.white,
              );
            }
          } else {
            Fluttertoast.showToast(
              msg: 'Latitude not in range',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.yellow,
              textColor: Colors.white,
            );
          }
        } else {
          Fluttertoast.showToast(
            msg: 'Longitude not in range',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.yellow,
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

  void _onArCoreNodeTap(String name) async{
    //print('name : $name');
    try {
      DocumentSnapshot documents = await FirebaseFirestore.instance.collection('cubes').doc(name).get();
      String nodeVideoUrl = documents['UploadedFilePath'];
      //print('nodeVideo : $nodeVideoUrl');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoPlayerScreen(videoUrl: nodeVideoUrl),
        ),
      );
    }
    catch(error){
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
              child: Text('Get Cubes Near Me'),
            ),
          ),
        ],
      ),
    );
  }
}
