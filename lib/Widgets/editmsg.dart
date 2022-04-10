
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../Controller/chatroom_controller.dart';
import '../Models/messages.dart';
import '../Screens/forward_screen.dart';
import 'chat.dart';

class EditMsg extends StatelessWidget {
  Messages message;
  EditMsg({required this.message});
  final ChatRoomController _controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 10,),
        Padding(
          padding: const EdgeInsets.only(top: 10,right: 20,left: 20,bottom: 10),
          child: Chat(message: message),
        ),
        Divider(),
        if (message.msgViewType == Type.text)
          // ignore: deprecated_member_use
          FlatButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: message.msg));
              Navigator.pop(context);
            },
            child: Text(
              'Copy',
              style: TextStyle(fontSize: 15.0),
            ),
          ),
        // ignore: deprecated_member_use
        FlatButton(
          onPressed: () {
            Navigator.pop(context);
            Get.toNamed(ForwardScreen.routeName, arguments: message);
          },
          child: Text(
            'Forward',
            style: TextStyle(fontSize: 15.0),
          ),
        ),
        // ignore: deprecated_member_use
        FlatButton(
          onPressed: () {
            Navigator.pop(context);
            showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('Delete Message'),
                    actions: [
                      // ignore: deprecated_member_use
                      FlatButton(
                        onPressed: () {
                          _controller.deleteAll(message.msgId);
                          Get.back();
                        },
                        child: Text(
                          'Delete All',
                          style: TextStyle(fontSize: 15.0, color: Colors.red),
                        ),
                      ),
                      // ignore: deprecated_member_use
                      FlatButton(
                        onPressed: () {
                          _controller.deleteMsg(message.msgId);
                          Get.back();
                        },
                        child: Text(
                          'Delete for me',
                          style: TextStyle(fontSize: 15.0, color: Colors.red),
                        ),
                      ),
                    ],
                  );
                });
          },
          child: Text(
            'Delete',
            style: TextStyle(fontSize: 15.0),
          ),
        ),
      ],
    );
  }

  msgContenType(Messages message) {
    switch (message.msgViewType) {
      case Type.photo:
        return Image.network(
          message.msg,
          height: 100,
          width: 100,
          fit: BoxFit.cover,
        );
      case Type.video:
        return Image.asset('assets/images/video.png');
      default:
        return Text(
          message.msg,
          style: TextStyle(
              color: message.isSendbyMy ? Colors.white : Colors.black),
        );
    }
  }
}
