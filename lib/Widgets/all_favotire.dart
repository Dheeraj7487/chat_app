
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Controller/main_screen_controller.dart';
import '../Models/chatmembers.dart';
import '../Models/chats.dart';
import 'UIWidgets/convList.dart';

class AllFavorite extends StatelessWidget {
  final _controller = Get.find<MainScreenController>();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _controller.getAllusers(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SizedBox();
        }
        _controller.favChatList =
            snapshot.data!.docs.map((e) => Chats.fromDoc(e)).toList();

        return ListView.builder(
          itemCount: _controller.favChatList.length,
          physics: BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            return StreamBuilder<DocumentSnapshot>(
              stream: _controller.getAppMemberInfo(_controller.favChatList[index].chatId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return SizedBox();
                }
                ChatMembers members = ChatMembers.fromDoc(snapshot.data!);
                if (members.isFavorite) {
                  return ConvList(
                    chats: _controller.favChatList[index],
                    members: members,
                  );
                }
                return SizedBox();
              },
            );
          },
        );
      },
    );
  }
}
