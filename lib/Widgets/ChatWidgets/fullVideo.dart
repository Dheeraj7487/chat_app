// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import '../../Themes/mythemes.dart';

@override
class FullVideo extends StatefulWidget {
  static const routeName = '/full-video';

  @override
  State<FullVideo> createState() => _FullVideoState();
}

class _FullVideoState extends State<FullVideo> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;
  String videoUrl = Get.arguments;
  bool startedPlaying = false;
  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(
      videoUrl,
    );
    _controller.setLooping(true);
  }

  @override
  void dispose() {
    // Ensure disposing of the VideoPlayerController to free up resources.
    _controller.dispose();
    super.dispose();
  }

  Future<bool> started() async {
    await _controller.initialize();
    await _controller.play();
    startedPlaying = true;
    return true;
  }

  Widget build(BuildContext context) {
    print("VIDEOURL = " + videoUrl);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Colors.black, //change your color here
        ),
      ),
      body: FutureBuilder(
        future: started(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(
                color: MyTheme.lightTheme.primaryColor,
              ),
            );
          }
        },
      ),
    );
  }
}
