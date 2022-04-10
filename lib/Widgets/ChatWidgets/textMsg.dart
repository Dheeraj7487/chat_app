import 'package:flutter/material.dart';

import '../../Models/app_model.dart';
import '../../Models/messages.dart';
import '../editmsg.dart';

// ignore: must_be_immutable
class TextMsg extends StatelessWidget {
  Messages messages;

  TextMsg({required this.messages});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: () {
        if (!messages.msgDeleteFor.contains(app.userId)) {
          showModalBottomSheet(
              context: context,
              builder: (context) {
                return EditMsg(message: messages);
              });
        }
      },
      child: Text(
        messages.msg,
        style:
            TextStyle(color: messages.isSendbyMy ? Colors.white : Colors.black),
      ),
    );
  }
}
