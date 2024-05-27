import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vector_math/vector_math_64.dart' as vector64;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'cube_video.dart';
class ArCube extends StatefulWidget {
  const ArCube({Key? key}) : super(key: key);

  @override
  State<ArCube> createState() => _ArCubeState();
}
class _ArCubeState extends State<ArCube> {
  ArCoreController? coreController;
  String planeCoordinates = '';
  bool uploadCompleted = false;
  bool thumbnailAdded = false;
  String? uploadedFilePath;
  String? uploadedFileUrl;
  String? textImageURL;
  Uint8List? thumbnailImageData;
  String? thumbnailText;
  ArCoreHitTestResult? lastHitResult;
  String? documentId;
  final Uuid uuid = Uuid();

  @override
  void dispose() {
    coreController?.dispose();
    super.dispose();
  }

  void arViewCreate(ArCoreController controller) {
    coreController = controller;
    coreController!.onPlaneTap = _onPlaneTap;
    coreController!.onPlaneDetected = _onPlaneDetected;
  }

  void _onPlaneTap(List<ArCoreHitTestResult> hitTestResults) {
    if (hitTestResults.isNotEmpty) {
      lastHitResult = hitTestResults.first;
      _showUploadDialog();
    }
  }

  void _showUploadDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              title: const Text(
                "Upload and Add Thumbnail",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.blueAccent,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        _uploadFile(setState);
                      },
                      icon: const FaIcon(FontAwesomeIcons.upload, color: Colors.white),
                      label: const Text(
                        "Upload Video",
                        style: TextStyle(fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 5,
                        shadowColor: Colors.black45,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: () {
                        _recordVideo(setState);
                      },
                      icon: const FaIcon(FontAwesomeIcons.video, color: Colors.white),
                      label: const Text(
                        "Record Video",
                        style: TextStyle(fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orangeAccent,
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 5,
                        shadowColor: Colors.black45,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: uploadCompleted
                          ? () {
                        _showThumbnailDialog(setState);
                      }
                          : null,
                      icon: const FaIcon(FontAwesomeIcons.comment, color: Colors.white),
                      label: const Text(
                        "Add Description",
                        style: TextStyle(fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: uploadCompleted ? Colors.green : Colors.grey,
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: uploadCompleted ? 5 : 0,
                        shadowColor: uploadCompleted ? Colors.black45 : Colors.transparent,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: uploadCompleted && thumbnailAdded
                          ? () {
                        Navigator.of(context).pop();
                        _placeCube(lastHitResult!);
                      }
                          : null,
                      icon: const FaIcon(FontAwesomeIcons.cube, color: Colors.white),
                      label: const Text(
                        "Place Cube",
                        style: TextStyle(fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: uploadCompleted && thumbnailAdded ? Colors.purpleAccent : Colors.grey,
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: uploadCompleted && thumbnailAdded ? 5 : 0,
                        shadowColor: uploadCompleted && thumbnailAdded ? Colors.black45 : Colors.transparent,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }



  Future<void> _recordVideo(StateSetter parentSetState) async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickVideo(
      source: ImageSource.camera,
    );

    if (pickedFile != null) {
      _previewRecordedVideo(pickedFile, parentSetState);
    } else {
      Fluttertoast.showToast(
        msg: 'Video recording canceled.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  void _previewRecordedVideo(XFile pickedFile, StateSetter parentSetState) {
    final VideoPlayerController videoPlayerController = VideoPlayerController.file(File(pickedFile.path));

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              title: const Text(
                "Preview Video",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.blueAccent,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FutureBuilder(
                    future: videoPlayerController.initialize(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return AspectRatio(
                          aspectRatio: videoPlayerController.value.aspectRatio,
                          child: VideoPlayer(videoPlayerController),
                        );
                      } else {
                        return const CircularProgressIndicator();
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          videoPlayerController.play();
                        },
                        icon: const Icon(Icons.play_arrow, color: Colors.white),
                        label: const Text("Play"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        onPressed: () {
                          videoPlayerController.pause();
                        },
                        icon: const Icon(Icons.pause, color: Colors.white),
                        label: const Text("Pause"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    videoPlayerController.dispose();
                    _recordVideo(parentSetState);
                  },
                  child: const Text(
                    "Retake",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.redAccent,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    videoPlayerController.dispose();
                    _showUploadVideoDialog(pickedFile, parentSetState);
                  },
                  child: const Text(
                    "Upload",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blueAccent,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showUploadVideoDialog(XFile pickedFile, StateSetter parentSetState) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Upload Video"),
          content: const Text("Do you want to upload the recorded video?"),
          actions: [
            TextButton(

              onPressed: () {
                Navigator.of(context).pop();
                Fluttertoast.showToast(
                  msg: 'Video not uploaded.',
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                );
              },
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _uploadRecordedVideo(pickedFile, parentSetState);
              },
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _uploadRecordedVideo(XFile pickedFile, StateSetter parentSetState) async {
    File file = File(pickedFile.path);
    String fileName = uuid.v4();

    try {
      UploadTask uploadTask = FirebaseStorage.instance.ref('uploads/$fileName').putFile(file);
      TaskSnapshot taskSnapshot = await uploadTask;

      String downloadUrl = await taskSnapshot.ref.getDownloadURL();

      parentSetState(() {
        uploadedFilePath = pickedFile.path;
        uploadedFileUrl = downloadUrl;
        uploadCompleted = true;
      });

      // Extract high-quality frame from video
      final Directory tempDir = await getTemporaryDirectory();
      final String thumbnailPath = '${tempDir.path}/thumb.jpg';
      final Uint8List? thumbnailBytes = await VideoThumbnail.thumbnailData(
        video: pickedFile.path,
        imageFormat: ImageFormat.JPEG,
        maxHeight: 1000, // Set high resolution
        quality: 100,    // Set high quality
      );

      if (thumbnailBytes != null) {
        final File thumbnailFile = File(thumbnailPath)..writeAsBytesSync(thumbnailBytes);

        // Upload thumbnail to Firebase Storage
        String thumbnailFileName = uuid.v4();
        UploadTask thumbnailUploadTask = FirebaseStorage.instance.ref('thumbnails/$thumbnailFileName').putFile(thumbnailFile);
        TaskSnapshot thumbnailTaskSnapshot = await thumbnailUploadTask;
        String thumbnailDownloadUrl = await thumbnailTaskSnapshot.ref.getDownloadURL();

        parentSetState(() {
          textImageURL = thumbnailDownloadUrl;
          thumbnailAdded = true;
        });

        Fluttertoast.showToast(
          msg: 'Video uploaded successfully!',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
      } else {
        throw Exception('Failed to generate thumbnail.');
      }
    } catch (error) {
      parentSetState(() {
        uploadCompleted = false;
      });

      Fluttertoast.showToast(
        msg: 'Failed to upload video: $error',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  Future<void> _uploadFile(StateSetter setState) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.video);

    if (result != null && result.files.single.path != null) {
      File file = File(result.files.single.path!);
      String fileName = uuid.v4();

      try {
        UploadTask uploadTask = FirebaseStorage.instance.ref('uploads/$fileName').putFile(file);
        TaskSnapshot taskSnapshot = await uploadTask;

        String downloadUrl = await taskSnapshot.ref.getDownloadURL();

        setState(() {
          uploadedFilePath = result.files.single.path;
          uploadedFileUrl = downloadUrl;
          uploadCompleted = true;
        });

        // Extract high-quality frame from video
        final Directory tempDir = await getTemporaryDirectory();
        final String thumbnailPath = '${tempDir.path}/thumb.jpg';
        final Uint8List? thumbnailBytes = await VideoThumbnail.thumbnailData(
          video: result.files.single.path!,
          imageFormat: ImageFormat.JPEG,
          maxHeight: 1000, // Set high resolution
          quality: 100,    // Set high quality
        );

        if (thumbnailBytes != null) {
          final File thumbnailFile = File(thumbnailPath)..writeAsBytesSync(thumbnailBytes);
          // Upload thumbnail to Firebase Storage
          String thumbnailFileName = uuid.v4();
          UploadTask thumbnailUploadTask = FirebaseStorage.instance.ref('thumbnails/$thumbnailFileName').putFile(thumbnailFile);
          TaskSnapshot thumbnailTaskSnapshot = await thumbnailUploadTask;
          String thumbnailDownloadUrl = await thumbnailTaskSnapshot.ref.getDownloadURL();

          setState(() {
            textImageURL = thumbnailDownloadUrl;
            thumbnailAdded = true;
          });

          Fluttertoast.showToast(
            msg: 'Video uploaded successfully!',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.green,
            textColor: Colors.white,
          );
        } else {
          throw Exception('Failed to generate thumbnail.');
        }
      } catch (error) {
        setState(() {
          uploadCompleted = false;
        });

        Fluttertoast.showToast(
          msg: 'Failed to upload file: $error',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } else {
      Fluttertoast.showToast(
        msg: 'File upload canceled.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }
  void _showThumbnailDialog(StateSetter parentSetState) {
    final TextEditingController thumbnailController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Add Thumbnail"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: thumbnailController,
                decoration: const InputDecoration(hintText: "Enter thumbnail text"),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (thumbnailController.text.isNotEmpty) {
                    parentSetState(() {
                      thumbnailText = thumbnailController.text;
                      thumbnailAdded = true;
                    });

                    Navigator.of(context).pop();
                    Fluttertoast.showToast(
                      msg: 'Thumbnail added successfully!',
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      backgroundColor: Colors.green,
                      textColor: Colors.white,
                    );
                  } else {
                    Fluttertoast.showToast(
                      msg: 'Please enter thumbnail text.',
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                    );
                  }
                },
                child: const Text("Add"),
              ),
            ],
          ),
        );
      },
    );
  }

  void _placeCube(ArCoreHitTestResult hit) async {
    final hitTransform = hit.pose.translation;
    final cubePosition = vector64.Vector3(
      hitTransform.x,
      hitTransform.y + 0.25,
      hitTransform.z,
    );

    final response = await http.get(Uri.parse(textImageURL!));
    final bytes = response.bodyBytes;

    final materials = ArCoreMaterial(
      color: Colors.lime,
      textureBytes: bytes,
    );

    final cube = ArCoreCube(
      size: vector64.Vector3(0.5, 0.5, 0.5),
      materials: [materials],
    );

    final node = ArCoreRotatingNode(
      shape: cube,
      degreesPerSecond: 30,
      position: cubePosition,
      name: uuid.v4(),
    );

    coreController!.onNodeTap = _onArCoreNodeTap;
    coreController!.addArCoreNode(node);
    await _saveCubePosition(cubePosition);

    Fluttertoast.showToast(
      msg: 'Cube placed Successfully',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );
  }

  void _onPlaneDetected(ArCorePlane plane) {
    final planeTransform = plane.centerPose?.translation;
    if (planeTransform != null) {
      setState(() {
        planeCoordinates =
        'Plane Coordinates: (${planeTransform.x.toStringAsFixed(2)}, ${planeTransform.y.toStringAsFixed(2)}, ${planeTransform.z.toStringAsFixed(2)})';
      });
    }
  }

  void _onArCoreNodeTap(String name) {
    // Navigate to CubeVideoScreen when cube tapped
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPlayerScreen(videoUrl: uploadedFileUrl!),
      ),
    );
  }

  Future<void> _saveCubePosition(vector64.Vector3 position) async {
    final currentPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );

    final cubePositionMap = {
      'x': position.x,
      'y': position.y,
      'z': position.z,
    };

    final latitude = currentPosition.latitude;
    final longitude = currentPosition.longitude;
    const latScale = 0.00001;
    const lonScale = 0.00001;
    final cubeLatitude = latitude + position.x * latScale;
    final cubeLongitude = longitude + position.z * lonScale;

    final roundedCubeLatitude = _roundToDecimalPlaces(cubeLatitude, 7);
    final roundedCubeLongitude = _roundToDecimalPlaces(cubeLongitude, 7);

    final uniqueId = uuid.v4();

    try {
      await FirebaseFirestore.instance.collection('cubes').doc(uniqueId).set({
        'CubeLatitude': roundedCubeLatitude,
        'CubeLongitude': roundedCubeLongitude,
        'PhoneLatitude': latitude,
        'PhoneLongitude': longitude,
        'CubeVectorPosition': cubePositionMap,
        'UploadedFilePath': uploadedFileUrl,
        'ThumbnailText': thumbnailText,
        'UniqueId': uniqueId,
        'thumbImage': textImageURL,
      });

      documentId = uniqueId;

      Fluttertoast.showToast(
        msg: 'Position saved successfully with ID: $documentId',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    } catch (error) {
      Fluttertoast.showToast(
        msg: 'Failed to save position: $error',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  double _roundToDecimalPlaces(double value, int decimalPlaces) {
    final mod = math.pow(10.0, decimalPlaces).toDouble();
    return ((value * mod).round().toDouble() / mod);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AR Cube"),
        backgroundColor: Colors.pink,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ArCoreView(
              onArCoreViewCreated: arViewCreate,
              enableTapRecognizer: true,
            ),
          ),
          if (planeCoordinates.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                planeCoordinates,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }
}
