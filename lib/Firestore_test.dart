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
  double? distanceCal;
  double cubeDirLat = 0.0;
  double cubeDirLon = 0.0;
  double phoneLat = 0.0;
  double phoneLon = 0.0;
  double cubeDirLatitude = 0.0;
  double cubeDirLongitude = 0.0;
  bool hi = false;
  bool imgId = true;
  late Timer _timer;
  late Timer _nodeTapTimer;
  bool isCubesNearYouVisible = false;
  late Timer _distanceMeters;
  int count = 0;
  static const double earthRadius = 6378137.0;
  List<String> CubeImageURLs = [];
  List<String> CubeIdUrl = [];
  List<String> cubeDes = [];
  DateTime? mydate;


  @override
  void initState() {
    super.initState();
    _getLocation();
    _timer = Timer.periodic(Duration(milliseconds: 200), (timer) {
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
    _distanceMeters.cancel();
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

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double radiusOfEarthKm = 6371.0;
    // Convert degrees to radians
    double toRadians(double degree) {
      return degree * pi / 180;
    }
    double lat1Rad = toRadians(lat1);
    double lon1Rad = toRadians(lon1);
    double lat2Rad = toRadians(lat2);
    double lon2Rad = toRadians(lon2);
    // Haversine formula
    double deltaLat = lat2Rad - lat1Rad;
    double deltaLon = lon2Rad - lon1Rad;
    double a = sin(deltaLat / 2) * sin(deltaLat / 2) +
        cos(lat1Rad) * cos(lat2Rad) *
            sin(deltaLon / 2) * sin(deltaLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distanceKm = radiusOfEarthKm * c;
    double distanceMeters = distanceKm * 1000;
    return distanceMeters;
  }

  Future<void> _cubePlace(DateTime selectedDate) async {
    const double radius = 3.0; // 3 meters range
    const double cubeHeight = 0.25; // Adjust y position as needed

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

      // Convert selectedDate to the start and end of the day
      DateTime startOfDay = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
      DateTime endOfDay = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 23, 59, 59);
      // Convert DateTime to Timestamp
      Timestamp startTimestamp = Timestamp.fromDate(startOfDay);
      Timestamp endTimestamp = Timestamp.fromDate(endOfDay);

      QuerySnapshot querySnapshot = await firestore
          .collection('cubes')
          .where('timestamp', isGreaterThanOrEqualTo: startTimestamp)
          .where('timestamp', isLessThanOrEqualTo: endTimestamp)
          .get();

      if (querySnapshot.docs.isEmpty) {
        Fluttertoast.showToast(
          msg: 'No cubes found for the selected date: ${selectedDate.toLocal().toIso8601String()}',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.yellow,
          textColor: Colors.white,
        );
        return;
      }

      int cubeCount = 0;
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
        double y = cubeMap['y']?.toDouble() + cubeHeight ?? cubeHeight;

        var cubeRot = data['CubeVectorPosition'];
        double a = cubeRot['a']?.toDouble() ?? 0.0;
        double b = cubeRot['b']?.toDouble() ?? 0.0;
        double c = cubeRot['c']?.toDouble() ?? 0.0;
        double d = cubeRot['d']?.toDouble() ?? 0.0;
        print('a : $a b : $b c : $c d : $d ');

        double cubeLat = data['CubeLatitude'];
        double cubeLon = data['CubeLongitude'];
        double phoneLat = currentPosition.latitude;
        double phoneLon = currentPosition.longitude;
        String cubeID = documentSnapshot.id;
        String thumb = data['thumbImage'];
        double distance = _calculateDistance(phoneLat, phoneLon, cubeLat, cubeLon);

        if (distance <= radius) {
          // Calculate position in a circular manner
          double angle = (cubeCount * 2 * pi) / querySnapshot.docs.length;
          double x = radius * cos(angle);
          double z = radius * sin(angle);
          cubeCount++;

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
              position: vector64.Vector3(x, y, z),
              rotation: vector64.Vector4(a, 1, c, 90),
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
            await _saveCubePosition(x, y, z, currentLatitude, currentLongitude, documentSnapshot.id);
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
  void _onArCoreNodeTap(String name) async{

    String nodeName = name;
    if(nodeName == name && count == 1)
    {
      print('IF part');
    } else {

      print('Else Part');

      try {
        count += 1;
        DocumentSnapshot documents = await FirebaseFirestore.instance.collection('cubes').doc(name).get();
        String nodeVideoUrl = documents['UploadedFilePath'];
        print('nodeVideo : $nodeVideoUrl');
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
  }

  void distanceMeters(double cubeDirsLat, double cubeDirsLon, double q) async{
    Position currentPositionDis = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );
    _distanceMeters =  Timer.periodic(Duration(milliseconds: 700), (Timer timer) {
      setState(() {
        double deltaLatitude = cubeDirsLat - currentPositionDis.latitude;
        double deltaLongitude = cubeDirsLon - currentPositionDis.longitude;
        double r = deltaLatitude * (3.14159 / 180) * earthRadius;
        double p = deltaLongitude * (3.14159 / 180) * earthRadius * cos(3.14159 * currentPositionDis.latitude / 180);
        vector64.Vector3 currentPose = vector64.Vector3(0, 0, 0);
        vector64.Vector3 cubePose = vector64.Vector3(p, q, r);
        distanceCal = currentPose.distanceTo(cubePose);
        print('lat  : ${currentPositionDis.latitude} lon : ${currentPositionDis.longitude}');
        print('p : $p f : $q r : $r');
        print('distanceCal : $distanceCal');
      });
    });
  }
  // void _back(){
  //   setState(() {
  //     imgId = true;
  //     hi = false;
  //   });
  // }
  Future<DateTime?> _showDatePicker(BuildContext context) async {
    return showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
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
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 30, 10, 10),
            child:Column(
              children: [
                Container(
                  width: 100,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      DateTime? pickedDate = await _showDatePicker(context);
                      if (pickedDate != null) {
                        await _cubePlace(pickedDate);
                        setState(() {
                          mydate=pickedDate;
                        });
                      }
                    },
                    child: Text("Get Cubes"),
                    style: ButtonStyle(
                      padding: WidgetStatePropertyAll(EdgeInsets.all(0)),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Text(
                    mydate!=null?'Picked Date: ${mydate.toString()}':'No Date Picked',
                    style: TextStyle(
                      fontWeight:FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
