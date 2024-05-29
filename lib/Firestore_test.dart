// import 'dart:async';
// import 'dart:math';
// import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:http/http.dart' as http;
// import 'package:vector_math/vector_math_64.dart' as vector_math;
//
// import 'cube_video.dart'; // Assuming you have a widget for displaying cube videos
//
// class FirestoreTest extends StatefulWidget {
//   @override
//   _FirestoreTestState createState() => _FirestoreTestState();
// }
//
// class _FirestoreTestState extends State<FirestoreTest> {
//   ArCoreController? coreController;
//   double currentLatitude = 0.0;
//   double currentLongitude = 0.0;
//   late Timer _timer;
//   late Timer _nodeTapTimer;
//   int count = 0;
//
//   @override
//   void initState() {
//     super.initState();
//     _deleteAllCubeLocations();
//     _getLocation();
//     _timer = Timer.periodic(Duration(seconds: 1), (timer) {
//       _getLocation();
//     });
//     _nodeTapTimer = Timer.periodic(Duration(seconds: 3), (timer) {
//       count = 0;
//     });
//   }
//
//   @override
//   void dispose() {
//     _timer.cancel();
//     coreController?.dispose();
//     _nodeTapTimer.cancel();
//     super.dispose();
//   }
//
//   Future<void> _getLocation() async {
//     try {
//       Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.best,
//       );
//       setState(() {
//         currentLatitude = position.latitude;
//         currentLongitude = position.longitude;
//       });
//       await _cubePlace(DateTime.now());
//     } catch (e) {
//       print("Error: $e");
//     }
//   }
//   void cubeCreate(ArCoreController controller) {
//     coreController = controller;
//     coreController!.onPlaneDetected = null;
//   }
//   Future<void> _deleteAllCubeLocations() async {
//     FirebaseFirestore firestore = FirebaseFirestore.instance;
//     CollectionReference collectionRef = firestore.collection('cube_locations_placed');
//     QuerySnapshot querySnapshot = await collectionRef.get();
//     for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
//       await documentSnapshot.reference.delete();
//     }
//     Fluttertoast.showToast(
//       msg: 'All cube locations deleted',
//       toastLength: Toast.LENGTH_SHORT,
//       gravity: ToastGravity.BOTTOM,
//       backgroundColor: Colors.green,
//       textColor: Colors.white,
//     );
//   }
//   Future<void> _cubePlace(DateTime selectedDate) async {
//     if (coreController == null) {
//       Fluttertoast.showToast(
//         msg: 'ARCore controller is not initialized yet.',
//         toastLength: Toast.LENGTH_SHORT,
//         gravity: ToastGravity.BOTTOM,
//         backgroundColor: Colors.red,
//         textColor: Colors.white,
//       );
//       return;
//     }
//     FirebaseFirestore firestore = FirebaseFirestore.instance;
//     try {
//       // Convert selectedDate to the start and end of the day
//       DateTime startOfDay = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
//       DateTime endOfDay = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 23, 59, 59);
//       // Convert DateTime to Timestamp
//       Timestamp startTimestamp = Timestamp.fromDate(startOfDay);
//       Timestamp endTimestamp = Timestamp.fromDate(endOfDay);
//       QuerySnapshot querySnapshot = await firestore
//           .collection('cubes')
//           .where('timestamp', isGreaterThanOrEqualTo: startTimestamp)
//           .where('timestamp', isLessThanOrEqualTo: endTimestamp)
//           .get();
//       if (querySnapshot.docs.isEmpty) {
//         Fluttertoast.showToast(
//           msg: 'No cubes found for the selected date: ${selectedDate.toLocal().toIso8601String()}',
//           toastLength: Toast.LENGTH_SHORT,
//           gravity: ToastGravity.BOTTOM,
//           backgroundColor: Colors.yellow,
//           textColor: Colors.white,
//         );
//         return;
//       }
//       for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
//         var data = documentSnapshot.data() as Map<String, dynamic>?;
//         if (data == null) {
//           Fluttertoast.showToast(
//             msg: 'Invalid data for document: ${documentSnapshot.id}',
//             toastLength: Toast.LENGTH_SHORT,
//             gravity: ToastGravity.BOTTOM,
//             backgroundColor: Colors.red,
//             textColor: Colors.white,
//           );
//           continue;
//         }
//
//         double cubeLat = data['CubeLatitude'];
//         double cubeLon = data['CubeLongitude'];
//         double y = data['CubeVectorPosition']['y']?.toDouble() ?? 0.0;
//         String cubeID = documentSnapshot.id;
//         String thumb = data['thumbImage'];
//
//         // Display a toast message with the cubeID
//         Fluttertoast.showToast(
//           msg: 'Retrieved cube with ID: $cubeID',
//           toastLength: Toast.LENGTH_SHORT,
//           gravity: ToastGravity.BOTTOM,
//           backgroundColor: Colors.blue,
//           textColor: Colors.white,
//         );
//
//         // Check if the cube is already placed
//         DocumentSnapshot placedCubeSnapshot = await firestore.collection('cube_locations_placed').doc(cubeID).get();
//         if (placedCubeSnapshot.exists) {
//           continue;
//         }
//
//         // Convert lat/lon to AR coordinates (x, z) relative to the current device location
//         double x = (cubeLat - currentLatitude) * 111139; // in meters
//         double z = (cubeLon - currentLongitude) * 111139 * cos(currentLatitude * (pi / 180)); // in meters
//
//         final response = await http.get(Uri.parse(thumb));
//         if (response.statusCode == 200) {
//           final bytes = response.bodyBytes;
//           final materials = ArCoreMaterial(color: Colors.red, metallic: 0.5, textureBytes: bytes);
//
//           final cube = ArCoreCube(
//             size: vector_math.Vector3(0.35, 0.9, 0.5),
//             materials: [materials],
//           );
//
//           final node = ArCoreRotatingNode(
//             shape: cube,
//             degreesPerSecond: 30,
//             position: vector_math.Vector3(x, y + 0.25, z),
//             name: cubeID,
//           );
//
//           coreController!.addArCoreNode(node);
//
//           Fluttertoast.showToast(
//             msg: 'Cube Placed',
//             toastLength: Toast.LENGTH_SHORT,
//             gravity: ToastGravity.BOTTOM,
//             backgroundColor: Colors.yellow,
//             textColor: Colors.white,
//           );
//
//           coreController!.onNodeTap = _onArCoreNodeTap;
//           await _saveCubePosition(x, y, z, currentLatitude, currentLongitude, cubeID);
//
//           // Retrieve cubeId URL from Firestore based on cubeID
//           DocumentSnapshot cubeDocument = await firestore.collection('cubes').doc(cubeID).get();
//           if (cubeDocument.exists) {
//             String cubeIdUrl = cubeDocument['cubeIdUrl'];
//             Fluttertoast.showToast(
//               msg: 'CubeID URL for $cubeID: $cubeIdUrl',
//               toastLength: Toast.LENGTH_LONG,
//               gravity: ToastGravity.BOTTOM,
//               backgroundColor: Colors.green,
//               textColor: Colors.white,
//             );
//           } else {
//             Fluttertoast.showToast(
//               msg: 'CubeID URL not found for $cubeID',
//               toastLength: Toast.LENGTH_SHORT,
//               gravity: ToastGravity.BOTTOM,
//               backgroundColor: Colors.yellow,
//               textColor: Colors.white,
//             );
//           }
//         } else {
//           Fluttertoast.showToast(
//             msg: 'Failed to load image from URL: ${response.statusCode}',
//             toastLength: Toast.LENGTH_SHORT,
//             gravity: ToastGravity.BOTTOM,
//             backgroundColor: Colors.red,
//             textColor: Colors.white,
//           );
//         }
//       }
//     } catch (error) {
//       Fluttertoast.showToast(
//         msg: 'Failed to place cube: $error',
//         toastLength: Toast.LENGTH_SHORT,
//         gravity: ToastGravity.BOTTOM,
//         backgroundColor: Colors.red,
//         textColor: Colors.white,
//       );
//     }
//   }

//   Future<void> _saveCubePosition(double x, double y, double z, double phoneLat, double phoneLon, String cubeID) async {
//     await FirebaseFirestore.instance.collection('cube_locations_placed').doc(cubeID).set({
//       'x': x,
//       'y': y,
//       'z': z,
//       'phoneLat': phoneLat,
//       'phoneLon': phoneLon,
//       'cubeID': cubeID,
//     });
//
//     Fluttertoast.showToast(
//       msg: 'Cube position saved to Firestore with ID: $cubeID',
//       toastLength: Toast.LENGTH_SHORT,
//       gravity: ToastGravity.BOTTOM,
//       backgroundColor: Colors.green,
//       textColor: Colors.white,
//     );
//   }
//
//   void _onArCoreNodeTap(String name) async {
//     String nodeName = name;
//     if (nodeName == name && count == 1) {
//       print('IF part');
//     } else {
//       print('Else Part');
//
//       try {
//         count += 1;
//         DocumentSnapshot documents = await FirebaseFirestore.instance.collection('cubes').doc(name).get();
//         String nodeVideoUrl = documents['UploadedFilePath'];
//         print('nodeVideo : $nodeVideoUrl');
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => VideoPlayerScreen(videoUrl: nodeVideoUrl),
//           ),
//         );
//       } catch (error) {
//         Fluttertoast.showToast(
//           msg: 'error : $error',
//           toastLength: Toast.LENGTH_SHORT,
//           gravity: ToastGravity.BOTTOM,
//           backgroundColor: Colors.green,
//           textColor: Colors.white,
//         );
//       }
//     }
//   }
//
//   Future<void> _showDatePicker(BuildContext context) async {
//     final DateTime? pickedDate = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(1900),
//       lastDate: DateTime(2100),
//     );
//
//     if (pickedDate != null) {
//       await _cubePlace(pickedDate);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Cube Placement"),
//         backgroundColor: Colors.pink,
//         centerTitle: true,
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Text(
//               "Current Location: Lat: $currentLatitude, Lon: $currentLongitude",
//               style: TextStyle(fontSize: 16),
//             ),
//           ),
//           ElevatedButton(
//             onPressed: () => _showDatePicker(context),
//             child: Text("Select Date"),
//           ),
//           Expanded(
//             child: ArCoreView(
//               onArCoreViewCreated: cubeCreate,
//               enablePlaneRenderer: true,
//               enableTapRecognizer: true,
//               enableUpdateListener: true,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
//



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
  int count = 0;
  List<String> CubeImageURLs = [];
  List<String> CubeIdUrl = [];
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
      await _cubePlace(DateTime.now());
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
        phoneLat = currentPosition.latitude;
        phoneLon = currentPosition.longitude;
        String cubeID = documentSnapshot.id;
        String thumb = data['thumbImage'];
        double distance = _calculateDistance(phoneLat, phoneLon, cubeLat, cubeLon);
        double radius = 7.66;
        // Display a toast message with the cubeID


        // Check if the cube is already placed
        if (distance <= radius) {
          // Convert lat/lon to AR coordinates (x, z) relative to the current device location
          double x = (cubeLat - currentLatitude) * 111139; // in meters
          double z = (cubeLon - currentLongitude) * 111139 *
              cos(currentLatitude * (pi / 180)); // in meters
          Fluttertoast.showToast(
            msg: 'Retrieved cube with ID: $cubeID',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.blue,
            textColor: Colors.white,
          );

        final response = await http.get(Uri.parse(thumb));
        if (response.statusCode == 200) {
          final bytes = response.bodyBytes;
          final materials = ArCoreMaterial(
              color: Colors.red, metallic: 0.5, textureBytes: bytes);

          final cube = ArCoreCube(
            size: vector64.Vector3(0.3, 0.5, 0.35),
            materials: [materials],
          );

          final node = ArCoreRotatingNode(
            shape: cube,
            degreesPerSecond: 30,
            position: vector64.Vector3(x, y + 0.25, z), name: cubeID,
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
          await _saveCubePosition(
              x, y, z, currentLatitude, currentLongitude, cubeID);

          // Retrieve cubeId URL from Firestore based on cubeID
        }else {
          Fluttertoast.showToast(
            msg: 'Failed to load image from URL: ${response.statusCode}',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
        }
        }
        else {
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
  void _onCubeImageTap(String cubeIds) async{
    imgId = false;
    hi = true;
    String cubeDocId = cubeIds;
    DocumentSnapshot documents = await FirebaseFirestore.instance.collection('cubes').doc(cubeDocId).get();
    var cubeMap = documents['CubeVectorPosition'];
    double b = cubeMap['y']?.toDouble() ?? 0.0;
    cubeDirLat = documents['CubeLatitude'];
    cubeDirLon = documents['CubeLongitude'];
    double a = (cubeDirLat - phoneLat) / 0.00001;
    double c = (cubeDirLon - phoneLon) / 0.00001;
    print('x : $a y : $b z : $c');
    cubeDirLatitude = phoneLat + a * 0.00001;
    cubeDirLongitude = phoneLon + b * 0.00001;
    print('cubeDirLatitude : $cubeDirLatitude cubeDirLongitude : $cubeDirLongitude');
    distanceCal = calculateDistance(currentLatitude, currentLongitude, cubeDirLat, cubeDirLon);
    print('Discal : $distanceCal');
  }
  Future<void> _showDatePicker(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      await _cubePlace(pickedDate);
    }
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

          ElevatedButton(
            onPressed: () => _showDatePicker(context),
            child: Text("Select Date"),
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
                        if(imgId)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Cubes Near You",
                              style: TextStyle(color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        Container(
                          height: 180,
                          child: Column(
                            children: [
                              if(hi)
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
                              if(hi)
                                Text(
                                  distanceCal.toString(),
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
                                    if(imgId)
                                      return Padding(
                                        padding: const EdgeInsets.fromLTRB(5, 5, 5, 7),
                                        child: GestureDetector(
                                          onTap: () {
                                            _onCubeImageTap(CubeIdUrl[index]);
                                          },
                                          child: Container(
                                            width: 60 , // Adjust width as needed
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
                                    return null;
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
                await _cubePlace(DateTime.now());
              },
              child: Text('Get Cubes Near Me'),
            ),
          ),
        ],
      ),
    );
  }
}
