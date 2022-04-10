import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../Controller/main_screen_controller.dart';
import '../Models/chatmembers.dart';
import '../Models/chats.dart';
import '../Themes/mythemes.dart';
import 'UIWidgets/convList.dart';

class AllArchive extends StatelessWidget {
  static const routeName = '/all-archive';
  final _controller = Get.find<MainScreenController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Archive List'),
        toolbarHeight: 100,
        backgroundColor: MyTheme.lightTheme.primaryColor,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _controller.getAllusers(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          _controller.archiveChatList =
              snapshot.data!.docs.map((e) => Chats.fromDoc(e)).toList();

          return ListView.builder(
            itemCount: _controller.archiveChatList.length,
            physics: BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              return StreamBuilder<DocumentSnapshot>(
                stream: _controller.getAppMemberInfo(
                    _controller.archiveChatList[index].chatId),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return SizedBox();
                  }
                  ChatMembers members = ChatMembers.fromDoc(snapshot.data!);
                  if (members.isArchive) {
                    return ConvList(
                      chats: _controller.archiveChatList[index],
                      members: members,
                    );
                  }
                  return SizedBox();
                },
              );
            },
          );
        },
      ),
    );
  }
}
