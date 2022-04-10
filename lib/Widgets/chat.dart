import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../Controller/chatroom_controller.dart';
import '../Models/app_model.dart';
import '../Models/messages.dart';
import '../Themes/mythemes.dart';
import 'ChatWidgets/deletedMsg.dart';
import 'ChatWidgets/photoMsg.dart';
import 'ChatWidgets/textMsg.dart';
import 'ChatWidgets/videoMsg.dart';

class Chat extends StatelessWidget {
  Messages message;
  Chat({required this.message});
  final ChatRoomController _controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(top: 8),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: message.isSendbyMy
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              children: [
                !message.msgDeleteFor.contains(app.userId)
                    ? Container(
                        padding: EdgeInsets.all(10),
                        child: message.msg.isEmpty
                            ? Text("Media Sending....",
                                style: TextStyle(
                                    color: message.isSendbyMy
                                        ? Colors.white
                                        : Colors.white))
                            : senderName(message),
                        decoration: BoxDecoration(
                          color: message.isSendbyMy
                              ? MyTheme.lightTheme.primaryColor
                              // ignore: deprecated_member_use
                              : MyTheme.lightTheme.accentColor,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                            bottomLeft:
                                Radius.circular(message.isSendbyMy ? 12 : 0),
                            bottomRight:
                                Radius.circular(message.isSendbyMy ? 0 : 12),
                          ),
                        ),
                        constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.6),
                      )
                    : DeletedMsg(messages: message)
              ],
            ),
            if (!message.msgDeleteFor.contains(app.userId))
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  mainAxisAlignment: message.sender == app.userId
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
                  children: [
                    if (message.isSendbyMy) msgSeenType(message),
                    SizedBox(
                      width: 8,
                    ),
                    Text(
                      DateFormat.jm().format(message.createdAt.toDate()),
                      style: TextStyle(color: Colors.grey[400]),
                    )
                  ],
                ),
              )
          ],
        ));
  }

  Widget senderName(Messages message) {
    if (_controller.chats.isGroup && !message.isSendbyMy) {
      return Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _controller.inGroupUser
                  .firstWhere((element) => element.uid == message.sender)
                  .name,
              style: TextStyle(
                fontSize: 10,
                  color: Colors.red),
            ),
            msgContenType(message),
          ],
        ),
      );
    } else {
      return msgContenType(message);
    }
  }

  msgContenType(Messages message) {
    switch (message.msgViewType) {
      case Type.photo:
        return PhotoMsg(
          messages: message,
        );
      case Type.video:
        return VideoMsg(
          messages: message,
        );
      default:
        return TextMsg(messages: message);
    }
  }

  msgSeenType(Messages messages) {
    Map<String, dynamic> messageStatus = messages.status;
    List<int> status = [];
    status = List.from(messageStatus.values.map((e) => e));
    if (status.contains(0)) {
      return Icon(Icons.done);
    } else {
      if (status.contains(1)) {
        return Icon(Icons.done_all);
      } else {
        return Icon(
          Icons.done_all,
          color: Colors.blue,
        );
      }
    }
  }
}
