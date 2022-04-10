import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:chat_app_project_demo/Widgets/ChatWidgets/audioCall.dart';
import 'package:chat_app_project_demo/Widgets/ChatWidgets/videoCall.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
class JoinChannel {

  Future<void> onJoinVideo(context) async {
    await _handleCameraAndMic(Permission.camera);
    await _handleCameraAndMic(Permission.microphone);
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoCall(
          channelName: "audiovideo", role: ClientRole.Broadcaster,
        ),
      ),
    );
  }

  Future<void> onJoinAudio(context) async {
    await _handleCameraAndMic(Permission.camera);
    await _handleCameraAndMic(Permission.microphone);
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AudioCall(
          channelName: "audiovideo", role: ClientRole.Broadcaster,
        ),
      ),
    );
  }

  Future<void> _handleCameraAndMic(Permission permission) async {
    final status = await permission.request();
    print(status);
  }

}
