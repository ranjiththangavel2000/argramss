// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:video_player/video_player.dart';
//
// void main() => runApp(MyApp());
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Video Player Demo',
//       theme: ThemeData.dark(), // Dark theme for better contrast
//       home: VideoPlayerScreen(videoUrl: 'https://example.com/video.mp4'), // Replace with your actual video URL
//     );
//   }
// }
//
// class VideoPlayerScreen extends StatefulWidget {
//   final String videoUrl;
//
//   VideoPlayerScreen({required this.videoUrl});
//
//   @override
//   _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
// }
//
// class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
//   late VideoPlayerController _controller;
//   bool _isPlaying = false;
//   bool _isFullScreen = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeVideoPlayer();
//   }
//
//   Future<void> _initializeVideoPlayer() async {
//     _controller = VideoPlayerController.network(
//       widget.videoUrl,
//     )..initialize().then((_) {
//       // Ensure the first frame is shown after the video is initialized.
//       setState(() {});
//     });
//   }
//
//   @override
//   void dispose() {
//     super.dispose();
//     _controller.dispose();
//   }
//
//   void _playPauseVideo() {
//     setState(() {
//       if (_controller.value.isPlaying) {
//         _controller.pause();
//         _isPlaying = false;
//       } else {
//         _controller.play();
//         _isPlaying = true;
//       }
//     });
//   }
//
//   void _toggleFullScreen() {
//     if (_isFullScreen) {
//       SystemChrome.setPreferredOrientations([
//         DeviceOrientation.portraitUp,
//         DeviceOrientation.portraitDown,
//       ]);
//     } else {
//       SystemChrome.setPreferredOrientations([
//         DeviceOrientation.landscapeLeft,
//         DeviceOrientation.landscapeRight,
//       ]);
//     }
//     setState(() {
//       _isFullScreen =!_isFullScreen;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black, // Dark background for better contrast
//       appBar: AppBar(
//         title: Text("Watch Video", style: TextStyle(color: Colors.white)),
//         backgroundColor: Colors.deepPurple, // Custom AppBar color
//         elevation: 5, // Shadow under the AppBar
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//         actions: <Widget>[
//           IconButton(
//             icon: Icon(
//               _isPlaying? Icons.pause : Icons.play_arrow,
//               color: Colors.white,
//             ),
//             onPressed: _playPauseVideo,
//           ),
//           IconButton(
//             icon: Icon(Icons.fullscreen),
//             onPressed: _toggleFullScreen,
//           ),
//         ],
//       ),
//       body: GestureDetector(
//         onTap: _playPauseVideo,
//         child: _controller.value.isInitialized
//             ? AspectRatio(
//           aspectRatio: _controller.value.aspectRatio,
//           child: Stack(
//             fit: StackFit.expand,
//             children: <Widget>[
//               VideoPlayer(_controller),
//               Align(
//                 alignment: Alignment.bottomCenter,
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: <Widget>[
//                     IconButton(
//                       icon: Icon(Icons.fast_forward),
//                       onPressed: () {
//                         _controller.seekTo(_controller.value.position + Duration(seconds: 10));
//                       },
//                     ),
//
//                     IconButton(
//                       icon: Icon(Icons.replay),
//                       onPressed: () {
//                         _controller.seekTo(_controller.value.position - Duration(seconds: 10));
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         )
//             : Center(child: CircularProgressIndicator()),
//       ),
//     );
//   }
// }








import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Player Demo',
      theme: ThemeData.dark(), // Dark theme for better contrast
      home: VideoPlayerScreen(videoUrl: 'https://example.com/video.mp4'), // Replace with your actual video URL
    );
  }
}

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;

  VideoPlayerScreen({required this.videoUrl});

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;
  bool _isFullScreen = false;
  int _likeCount = 0; // Variable to store like count

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  Future<void> _initializeVideoPlayer() async {
    _controller = VideoPlayerController.network(
      widget.videoUrl,
    )..initialize().then((_) {
      // Ensure the first frame is shown after the video is initialized.
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  void _playPauseVideo() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        _isPlaying = false;
      } else {
        _controller.play();
        _isPlaying = true;
      }
    });
  }

  void _toggleFullScreen() {
    if (_isFullScreen) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
    setState(() {
      _isFullScreen = !_isFullScreen;
    });
  }

  void _incrementLike() {
    setState(() {
      _likeCount += 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark background for better contrast
      appBar: AppBar(
        title: Text("Watch Video", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple, // Custom AppBar color
        elevation: 5, // Shadow under the AppBar
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              _isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
            ),
            onPressed: _playPauseVideo,
          ),
          IconButton(
            icon: Icon(Icons.fullscreen),
            onPressed: _toggleFullScreen,
          ),
          IconButton(
            icon: Icon(Icons.thumb_up, color: Colors.white),
            onPressed: _incrementLike,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Center(
              child: Text(
                '$_likeCount',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.comment, color: Colors.white),
            onPressed: () {
              // Handle comment button press
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Add a comment'),
                    content: TextField(
                      decoration: InputDecoration(hintText: 'Type your comment here'),
                      onSubmitted: (value) {
                        Navigator.of(context).pop();
                        // Handle the comment submission
                        print('Comment: $value');
                      },
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: GestureDetector(
        onTap: _playPauseVideo,
        child: _controller.value.isInitialized
            ? AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              VideoPlayer(_controller),
              Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.fast_forward),
                      onPressed: () {
                        _controller.seekTo(_controller.value.position + Duration(seconds: 10));
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.replay),
                      onPressed: () {
                        _controller.seekTo(_controller.value.position - Duration(seconds: 10));
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
            : Center(child: CircularProgressIndicator()),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.deepPurple, // Custom BottomAppBar color
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.thumb_up, color: Colors.white),
              onPressed: _incrementLike,
            ),
            Text(
              '$_likeCount',
              style: TextStyle(color: Colors.white),
            ),
            IconButton(
              icon: Icon(Icons.comment, color: Colors.white),
              onPressed: () {
                // Handle comment button press
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Add a comment'),
                      content: TextField(
                        decoration: InputDecoration(hintText: 'Type your comment here'),
                        onSubmitted: (value) {
                          Navigator.of(context).pop();
                          // Handle the comment submission
                          print('Comment: $value');
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

