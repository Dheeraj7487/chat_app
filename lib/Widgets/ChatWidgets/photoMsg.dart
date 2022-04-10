// ignore_for_file: unused_import, must_be_immutable

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../Models/messages.dart';
import '../editmsg.dart';
import 'imgpreview.dart';

class PhotoMsg extends StatelessWidget {
  Messages messages;

  PhotoMsg({required this.messages});
  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
          Get.to(ImagePreview(imgUrl: messages.msg));
        },
        onLongPress: () {
          showModalBottomSheet(
              context: context,
              builder: (context) {
                return EditMsg(message: messages);
              });
        },
        child: Image.network(
          messages.msg,
          height: 100,
          width: 100,
          fit: BoxFit.cover,
        ));
  }
}
