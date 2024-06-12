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
  String distanceCal = '';
  double phoneLat = 0.0;
  double phoneLon = 0.0;
  DateTime? selectedDate;
  bool hi = false;
  bool imgId = true;
  late Timer _timer;
  late Timer _nodeTapTimer;
  int count = 0;
  bool isCubesNearYouVisible = false;
  List<String> CubeImageURLs = [];
  List<String> CubeIdUrl = [];
  List<String> cubeDes = [];
  List<ArCoreNode> _addedNodes = [];
  DateTime? mydate;
  int currentCubePage = 0;
  bool isNextButtonVisible = false;


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
    } catch (e) {
      print("Error: $e");
    }
  }

  void cubeCreate(ArCoreController controller) {
    coreController = controller;
    coreController!.onPlaneDetected = null;
  }

  double _calculateDistance(double lat1, double lon1, double lat2,
      double lon2) {
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

  Future<void> _cubePlace(DateTime selectedDate) async {
    const double cubeHeight = 0.25;
    const double radius = 20.0;
    const double distanceInFront = 2.0;
    const int cubesPerPage = 4;

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

      DateTime startOfDay = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
      DateTime endOfDay = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 23, 59, 59);
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
      _removeAllCubes();
      int cubeCount = 0;
      for (int i = currentCubePage * cubesPerPage; i < querySnapshot.docs.length && i < (currentCubePage + 1) * cubesPerPage; i++) {
        QueryDocumentSnapshot documentSnapshot = querySnapshot.docs[i];
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

        double cubeLat = data['PhoneLatitude'];
        double cubeLon = data['PhoneLongitude'];
        double phoneLat = currentPosition.latitude;
        double phoneLon = currentPosition.longitude;
        String cubeID = documentSnapshot.id;
        String thumb = data['thumbImage'];
        double distance = _calculateDistance(phoneLat, phoneLon, cubeLat, cubeLon);

        const double distanceBetweenCubes = 2.5;

        if (distance <= radius) {
          double x = 0.0;
          double z = -(cubeCount * distanceBetweenCubes + distanceInFront);
          cubeCount++;

          final response = await http.get(Uri.parse(thumb));
          if (response.statusCode == 200) {
            final bytes = response.bodyBytes;
            final materials = ArCoreMaterial(
                color: Colors.red, metallic: 0.5, textureBytes: bytes);
            final cube = ArCoreCube(
              size: vector64.Vector3(0.3, 0.6, 0.35),
              materials: [materials],
            );
            final node = ArCoreRotatingNode(
              shape: cube,
              degreesPerSecond: 30,
              position: vector64.Vector3(x, y, z),
              name: cubeID,
            );
            coreController!.addArCoreNode(node);
            _addedNodes.add(node);

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
      setState(() {
        isNextButtonVisible = querySnapshot.docs.length > (currentCubePage + 1) * cubesPerPage;
      });
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

  void _onNextPage() {
    setState(() {
      currentCubePage++;
      _removeAllCubes(); // Clear previous nodes before placing new ones
      CubeImageURLs.clear(); // Clear the images list
      CubeIdUrl.clear(); // Clear the IDs list
      _cubePlace(selectedDate!);
    });
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
        DocumentSnapshot documents = await FirebaseFirestore.instance
            .collection('cubes').doc(name).get();
        String nodeVideoUrl = documents['UploadedFilePath'];
        print('nodeVideo : $nodeVideoUrl');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoPlayerScreen(videoUrl: nodeVideoUrl),
          ),
        );
      }
      catch (error) {
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

  void _onCubeImageTap(String cubeIds) async {
    imgId = false;
    hi = true;
    String cubeDocId = cubeIds;
    DocumentSnapshot documents = await FirebaseFirestore.instance.collection('cubes').doc(cubeDocId).get();
    if (documents['description'] == null) {
      distanceCal = 'Hi welcome to AR gram';
    } else {
      distanceCal = documents['description'];
    }
  }

  Future<DateTime?> _showDatePicker(BuildContext context) async {
    return showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(0001),
      lastDate: DateTime(9999),
    );
  }

  void _removeAllCubes() {
    if (coreController != null) {
      for (ArCoreNode node in _addedNodes) {
        coreController!.removeNode(nodeName: node.name);
      }
      _addedNodes.clear();
    }
  }

  void _onGetCubesNearMe() async {
    if (selectedDate != null) {
      setState(() {
        // Clear previous cubes from the list and AR scene
        CubeImageURLs.clear();
        CubeIdUrl.clear();
        _removeAllCubes();
      });
      await _cubePlace(selectedDate!);
    }
  }

  void _back() {
    setState(() {
      imgId = true;
      hi = false;
    });
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
                if (CubeImageURLs.isNotEmpty)
                // Only display the container if there are cubes retrieved
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
                            height: 155,
                            child: Column(
                              children: [
                                if (hi)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 270.0, top: 8.0, bottom: 8.0),
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
                                      if (imgId && index < 10)
                                        return Padding(
                                          padding:
                                          const EdgeInsets.fromLTRB(5, 5, 5, 7),
                                          child: GestureDetector(
                                            onTap: () {
                                              _onCubeImageTap(CubeIdUrl[index]);
                                            },
                                            child: Container(
                                              width: 60,
                                              height: 50,
                                              child: Column(
                                                children: [
                                                  ClipRRect(
                                                    borderRadius:
                                                    BorderRadius.circular(8),
                                                    child: Image.network(
                                                      CubeImageURLs[index],
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                  SizedBox(height: 5),
                                                  Text(
                                                    'RandomWalk AI',
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
                                if (CubeImageURLs.length > 10 && imgId)
                                  ElevatedButton(
                                    onPressed: _onNextPage,
                                    child: Text("Next"),
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
            padding: const EdgeInsets.fromLTRB(10, 5, 10, 10),
            child: Container(
              width: 300,
              height: 100,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          DateTime? pickedDate = await _showDatePicker(context);
                          if (pickedDate != null) {
                            setState(() {
                              selectedDate = pickedDate;
                            });
                          }
                        },
                        child: Text("Select Date"),
                      ),
                      if (selectedDate != null)
                      // Display the selected date
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Text(
                            ' ${selectedDate!.toLocal()
                                .toIso8601String()
                                .substring(0, 10)}',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          if (selectedDate == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Please select a date first'),
                              ),
                            );
                          } else {
                            _onGetCubesNearMe();
                          }
                        },
                        child: Text('GET CUBES NEAR ME'),
                      ),
                      SizedBox(width: 10),
                      if (isNextButtonVisible)
                        ElevatedButton(
                          onPressed: _onNextPage,
                          child: Text('NEXT'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}










