import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vector64;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:math';

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
  String? currentPhoneLat;
  //double currentPhoneLon = 0.0;
  bool hi = false;
  bool imgId = true;
  late Timer _timer;
  late Timer _nodeTapTimer;

  int count = 0;
  List<String> CubeImageURLs = [];
  List<String> CubeIdUrl = [];

  @override
  void initState() {
    super.initState();
    _getLocation();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _getLocation();
    });
    _nodeTapTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      count = 0;
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _nodeTapTimer.cancel();
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

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371e3;
    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) * cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
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
        //String cubeDes = data['Description'];

        double distance = _calculateDistance(phoneLat, phoneLon, cubeLat, cubeLon);
        double radius = 7.66;

        if (distance <= radius) {
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

            Fluttertoast.showToast(
              msg: 'Cube Placed',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.yellow,
              textColor: Colors.white,
            );

            coreController!.onNodeTap = _onArCoreNodeTap;
            CubeImageURLs.add(thumb);
            CubeIdUrl.add(cubeID);
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
            msg: 'Cube not within radius',
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

  void _onArCoreNodeTap(String name) async {
    String nodeName = name;
    if (nodeName == name && count == 1) {
      print('IF part');
    } else {
      print('Else Part');
      try {
        count += 1;
        DocumentSnapshot documents = await FirebaseFirestore.instance.collection('cubes').doc(name).get();
        String nodeVideoUrl = documents['videoURL'];
        print('nodeVideo : $nodeVideoUrl');
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
  }

  void _onCubeImageTap(String cubeIds){
    imgId = false;
    hi = true;
    currentPhoneLat = cubeIds;
    print('cubeIds : $cubeIds');
  }

  void _back(){
    imgId = true;
    hi = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cube Placement"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Current Location: Lat: $currentLatitude, Lon: $currentLongitude",
              style: TextStyle(fontSize: 16),
            ),
          ),
          // ARCore view
          Expanded(
            child: Stack(
              children: [
                ArCoreView(
                  onArCoreViewCreated: cubeCreate,
                  enablePlaneRenderer: true,
                  enableTapRecognizer: true,
                  enableUpdateListener: true,
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (imgId)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Cubes Near You",
                              style: TextStyle(color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        Container(
                          height: 175,
                          child: Column(
                            children: [
                              if (hi)
                                Padding(
                                  padding: const EdgeInsets.only(left: 270.0, top: 8.0, bottom: 8.0, right: 0),
                                  child: FloatingActionButton(
                                    onPressed: _back,
                                    child: Icon(Icons.arrow_back),
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.black,
                                    elevation: 4,
                                    mini: true,
                                  ),
                                ),
                              if (hi)
                                Text(
                                  currentPhoneLat.toString(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              Expanded(
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: CubeImageURLs.length,
                                  itemBuilder: (context, index) {
                                    if (imgId)
                                      return Padding(
                                        padding: const EdgeInsets.fromLTRB(5, 5, 5, 7),
                                        child: GestureDetector(
                                          onTap: () {
                                            _onCubeImageTap(CubeIdUrl[index]);
                                          },
                                          child: Container(
                                            width: 50, // Adjust width as needed
                                            height: 50, // Adjust height as needed
                                            child: Column(
                                              children: [
                                                ClipRRect(
                                                  borderRadius: BorderRadius.circular(8),
                                                  child: Image.network(
                                                    CubeImageURLs[index],
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                                SizedBox(height: 5),
                                                Text(
                                                  CubeIdUrl[index],
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
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

