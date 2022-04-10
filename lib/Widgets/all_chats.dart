
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../Controller/main_screen_controller.dart';
import '../Models/app_model.dart';
import '../Models/chatmembers.dart';
import '../Models/chats.dart';
import 'UIWidgets/convList.dart';

class AllChat extends StatelessWidget {
  final _controller = Get.find<MainScreenController>();
  List<Chats> allChat = [];
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _controller.getAllusers(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        List<Chats> tempList =
            snapshot.data!.docs.map((e) => Chats.fromDoc(e)).toList();

        allChat = tempList
            .where((element) => !element.chatDeleteFor.contains(app.userId))
            .toList();
        print(allChat);
        return ListView.separated(
          itemCount: allChat.length,
          physics: BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            return StreamBuilder<DocumentSnapshot>(
              stream: _controller.getAppMemberInfo(allChat[index].chatId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return SizedBox();
                }
                if (snapshot.data!.exists) {
                  ChatMembers members = ChatMembers.fromDoc(snapshot.data!);
                  if (!members.isArchive) {
                    return ConvList(
                      chats: allChat[index],
                      members: members,
                    );
                  }
                }
                return SizedBox();
              },
            );
          },
          separatorBuilder: (BuildContext context, int index) {
            return Divider();
          },
        );
      },
    );
  }
}
