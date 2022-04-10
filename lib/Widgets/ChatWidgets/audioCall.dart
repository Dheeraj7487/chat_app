import 'dart:async';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import '../Agora/agora.dart';

class AudioCall extends StatefulWidget {

  final String? channelName;
  final ClientRole? role;
  const AudioCall({Key? key,this.channelName, this.role}) : super(key: key);

  @override
  _AudioCallState createState() => _AudioCallState();
}

class _AudioCallState extends State<AudioCall> {
  final _users = <int>[];
  final _infoStrings = <String>[];
  late RtcEngine _engine;
  bool _showStats = false;
  bool muted = false;
  late int _remoteUid;
  RtcStats stats = RtcStats(1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1);

  late Timer? _timer;
  int _startSecond = 0;
  int _startMinutes = 0;
  int _startHour = 0;

  @override
  void dispose() {
    _users.clear();
    _engine.leaveChannel();
    _engine.destroy();
    super.dispose();
  }

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec, (Timer timer) {
      if(stats.userCount == 2){
        if(_startSecond == 59){
          _startSecond = 0;
        }
        else{
          _startSecond++;
        }
      }
      else{
        _startSecond = 0;
        _startMinutes = 0;
        _startHour = 0;
      }

    },
    );
    const oneMinutes = const Duration(minutes: 1);
    _timer = new Timer.periodic(
      oneMinutes, (Timer timer) {

      if(_startMinutes == 59){
        _startMinutes = 0;
      }
      else{
        _startMinutes++;
      }
    },
    );
    const oneHour = const Duration(hours: 1);
    _timer = new Timer.periodic(
      oneHour, (Timer timer) {
      if(_startHour == 59){
        _startHour = 0;
      }
      else{
        _startHour++;
      }
    },
    );
  }

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    if (APP_ID.isEmpty) {
      setState(() {
        _infoStrings.add(
          'APP_ID missing, please provide your APP_ID in settings.dart',
        );
        _infoStrings.add('Agora Engine is not starting');
      });
      return;
    }

    await _initAgoraRtcEngine();
    _addAgoraEventHandlers();
    await _engine.enableWebSdkInteroperability(true);
    VideoEncoderConfiguration configuration = VideoEncoderConfiguration();
    configuration.dimensions = VideoDimensions(width: 1920, height: 1080);
    await _engine.setVideoEncoderConfiguration(configuration);
    await _engine.joinChannel(Token, widget.channelName!, null, 0);
  }

  Future<void> _initAgoraRtcEngine() async {
    _engine = await RtcEngine.create(APP_ID);
    await _engine.enableAudio();
    await _engine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    await _engine.setClientRole(widget.role!);
  }

  void _addAgoraEventHandlers() {
    _engine.setEventHandler(RtcEngineEventHandler(error: (code) {
      setState(() {
        final info = 'onError: $code';
        _infoStrings.add(info);
      });
    }, joinChannelSuccess: (channel, uid, elapsed) {

      setState(() {
        _showStats = true;
      });
      setState(() {
        final info = 'onJoinChannel: $channel, uid: $uid';
        _infoStrings.add(info);
      });
    }, leaveChannel: (stats) {

      setState(() {
        _infoStrings.add('onLeaveChannel');
        _users.clear();
      }
      );
    }, userJoined: (uid, elapsed) {
      setState(() {
        final info = 'userJoined: $uid';
        _infoStrings.add(info);
        _users.add(uid);
        startTimer();
      });
    }, userOffline: (uid, elapsed) {
      setState(() {
        final info = 'userOffline: $uid';
        _infoStrings.add(info);
        _users.remove(uid);
      });
    }, firstRemoteVideoFrame: (uid, width, height, elapsed) {
      setState(() {
        final info = 'firstRemoteVideo: $uid ${width} x $height';
        _infoStrings.add(info);
      });
    },
    ));
  }

  List<Widget> _getRenderViews() {
    final List<StatefulWidget> list = [];
    if (widget.role == ClientRole.Broadcaster) {
      list.add(RtcLocalView.SurfaceView());
    }

    _users.forEach((int uid) => list.add(RtcRemoteView.SurfaceView(uid: uid,channelId: "audiovideo",)));
    return list;
  }

  void _onToggleMute() {
    setState(() {
      muted = !muted;
    });
    _engine.muteLocalAudioStream(muted);
  }



  Widget _toolbar() {
    if (widget.role == ClientRole.Audience) return Container();
    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RawMaterialButton(
            onPressed: _onToggleMute,
            child: Icon(
              muted ? Icons.mic_off : Icons.mic,
              color: muted ? Colors.white : Colors.blueAccent,
              size: 20.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: muted ? Colors.blueAccent : Colors.white,
            padding: const EdgeInsets.all(12.0),
          ),
          RawMaterialButton(
            onPressed: () => _onCallEnd(context),
            child: Icon(
              Icons.call_end,
              color: Colors.white,
              size: 35.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.redAccent,
            padding: const EdgeInsets.all(15.0),
          ),
        ],
      ),
    );
  }


  Widget _panel() {
    return Expanded(
      flex: 1,
        child: Image.network('https://i.stack.imgur.com/OV9dL.png',fit: BoxFit.cover,height: double.infinity,
          width: double.infinity,),
    );
  }

  Widget _statsView() {
    return stats.cpuAppUsage == null
        ? CircularProgressIndicator() :
    Visibility(visible: stats.userCount==2,
        child: Container(padding: EdgeInsets.only(left: 10,top: 10), child: Text("${_startHour}  : ${_startMinutes} : ${_startSecond}",style: TextStyle(color: Colors.white,fontSize: 20),)));
  }

  void _onCallEnd(BuildContext context) {
    Navigator.pop(context);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Stack(
          children: <Widget>[
            _panel(),
            _toolbar(),
            _statsView(),
          ],
        ),
      ),
    );
  }
}
