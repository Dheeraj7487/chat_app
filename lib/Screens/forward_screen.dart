
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../Controller/main_screen_controller.dart';
import '../Models/app_model.dart';
import '../Models/chatgroups.dart';
import '../Models/chatmembers.dart';
import '../Models/chats.dart';
import '../Models/chatusers.dart';
import '../Models/messages.dart';
import '../Themes/mythemes.dart';

class ForwardScreen extends StatefulWidget {
  static const routeName = '/forward-screen';

  @override
  State<ForwardScreen> createState() => _ForwardScreenState();
}

class _ForwardScreenState extends State<ForwardScreen> {
  final _controller = Get.find<MainScreenController>();
  Messages messages = Get.arguments;
  List<String> forwardList = [];
  List<Chats> chatList = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          elevation: 0.0,
          child: Icon(
            Icons.done,
            color: Colors.white,
          ),
          backgroundColor: MyTheme.lightTheme.primaryColor,
          onPressed: () {
            _controller.forwardMsg(forwardList, messages);
            Get.back();
          }),
      appBar: AppBar(
        backgroundColor: MyTheme.lightTheme.primaryColor,
        toolbarHeight: 100,
        centerTitle: false,
        title: Row(
          children: [
            Expanded(
              child: Text(
                'Forward to....',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
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
          List<Chats> tempList =
              snapshot.data!.docs.map((e) => Chats.fromDoc(e)).toList();
          chatList = tempList
              .where((element) => !element.chatDeleteFor.contains(app.userId))
              .toList();
          return ListView.builder(
            itemCount: chatList.length,
            physics: BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              return StreamBuilder<DocumentSnapshot>(
                stream: _controller.getAppMemberInfo(chatList[index].chatId),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return SizedBox();
                  }
                  ChatMembers members = ChatMembers.fromDoc(snapshot.data!);
                  if (!members.isArchive) {
                    return FutureBuilder<DocumentSnapshot>(
                      future: _controller.getConvDoc(chatList[index]),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          ChatGroups chatGroup = ChatGroups();
                          ChatUser model = ChatUser();
                          if (chatList[index].isGroup) {
                            chatGroup = ChatGroups.fromDoc(snapshot.data!);
                          } else {
                            model = ChatUser.fromDoc(snapshot.data!);
                          }

                          return InkWell(
                            onTap: () {
                              if (!(forwardList
                                  .contains(chatList[index].chatId)))
                                setState(() {
                                  forwardList.add(chatList[index].chatId);
                                });
                              else
                                setState(() {
                                  forwardList.removeWhere((element) =>
                                      element == chatList[index].chatId);
                                });
                              print(forwardList);
                            },
                            child: ListTile(
                              leading: CircleAvatar(
                                  radius: 30,
                                  backgroundColor: Colors.white,
                                  child: chatList[index].isGroup
                                      ? _controller.profileImage(chatGroup.photo)
                                      : _controller
                                          .profileImage(model.imageUrl)),
                              title: Text(
                                chatList[index].isGroup
                                    ? chatGroup.name
                                    : model.name,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                chatList[index].lastmsg,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              trailing: forwardList
                                      .contains(chatList[index].chatId)
                                  ? Icon(
                                      Icons.check_circle,
                                      color: MyTheme.lightTheme.primaryColor,
                                    )
                                  : Icon(
                                      Icons.check_circle,
                                      color: Colors.white,
                                    ),
                            ),
                          );
                        } else {
                          return Center(
                            child: ListTile(),
                          );
                        }
                      },
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
