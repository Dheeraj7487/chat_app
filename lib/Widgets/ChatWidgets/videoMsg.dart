
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../Models/messages.dart';
import '../editmsg.dart';
import 'fullVideo.dart';

// ignore: must_be_immutable
class VideoMsg extends StatelessWidget {
  Messages messages;

  VideoMsg({required this.messages});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Image.asset('assets/images/video.png'),
      onTap: () {
        Get.toNamed(FullVideo.routeName,
            arguments: messages.msg);
      },
      onLongPress: () {
        showModalBottomSheet(
            context: context,
            builder: (context) {
              return EditMsg(message: messages);
            });
      },
    );
  }
}
