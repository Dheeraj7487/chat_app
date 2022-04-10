import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:chat_app_project_demo/Widgets/ChatWidgets/videoCall.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../Controller/chatroom_controller.dart';
import '../../Models/app_model.dart';
import '../../Models/chatusers.dart';
import '../../Themes/mythemes.dart';
import '../../Widgets/ChatWidgets/audioCall.dart';
import '../../Widgets/ChatWidgets/index.dart';
import '../add_new_members.dart';
import '../main_screen.dart';

class GroupProfile extends StatelessWidget {
  static const routeName = '/group-profile';
  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChatRoomController>(
      builder: (_controller) {
        return Scaffold(
          backgroundColor: MyTheme.lightTheme.primaryColor,
          appBar: AppBar(
            backgroundColor: MyTheme.lightTheme.primaryColor,
            elevation: 0,
          ),
          body: Stack(
            children: [
              Positioned(
                height: MediaQuery.of(context).size.height * 0.25,
                width: MediaQuery.of(context).size.width,
                child: Container(
                  color: MyTheme.lightTheme.primaryColor,
                  child: Column(
                    children: [
                      _controller.chatGroup.photo.isEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: Image.asset(
                                'assets/images/default_pic.png',
                                height: 70,
                                width: 70,
                              ),
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: Image.network(
                                _controller.chatGroup.photo,
                                width: 70,
                                height: 70,
                                fit: BoxFit.cover,
                              ),
                            ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        _controller.chatGroup.name,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                      Text(
                        'Group - ' +
                            _controller.chats.displayUsers.length.toString() +
                            ' Participants',
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              IconButton(onPressed: (){
                                JoinChannel().onJoinAudio(context);
                              }, icon: Icon(
                                Icons.call,
                                size: 30,
                                color: Colors.white,
                              ),)
                            ],
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Column(
                            children: [
                              IconButton(onPressed: (){
                                JoinChannel().onJoinVideo(context);
                              }, icon: Icon(
                                Icons.video_call,
                                size: 30,
                                color: Colors.white,
                              ),)
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                height: MediaQuery.of(context).size.height * 0.63,
                width: MediaQuery.of(context).size.width,
                bottom: 0.0,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return addDesc();
                              });
                        },
                        child: Card(
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: 70,
                            child: Padding(
                              padding: EdgeInsets.only(top: 10),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(_controller.chatGroup.desc.isEmpty
                                      ? 'Add group description'
                                      : _controller.chatGroup.desc),
                                  StreamBuilder<DocumentSnapshot>(
                                      stream: _controller.getInfo(
                                          _controller.chatGroup.createdBy),
                                      builder: (context, snapshot) {
                                        if (!snapshot.hasData) {
                                          return Text('');
                                        }
                                        ChatUser model =
                                            ChatUser.fromDoc(snapshot.data!);
                                        DateTime tsdate = _controller
                                            .chatGroup.created_at
                                            .toDate();
                                        return Text("created by " +
                                            model.name +
                                            ", " +
                                            DateFormat('dd-MMM-yyy')
                                                .format(tsdate));
                                      }),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Divider(
                        color: MyTheme.lightTheme.primaryColor,
                      ),
                      InkWell(
                        onTap: () {
                          Get.toNamed(AddNewMembers.routeName);
                        },
                        child: Card(
                          child: Container(
                            height: 30,
                            padding: EdgeInsets.only(left: 10, right: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Add participants'),
                                Icon(Icons.add),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                              _controller.chats.displayUsers.length.toString() +
                                  " participants"),
                        ],
                      ),
                      Container(
                        height: 250,
                        child: ListView.separated(
                          itemCount: _controller.chats.displayUsers.length,
                          separatorBuilder: (_, __) => Divider(
                            height: 0.5,
                          ),
                          itemBuilder: (context, index) {
                            return StreamBuilder<DocumentSnapshot>(
                              stream: _controller.getInfo(
                                  _controller.chats.displayUsers[index]),
                              builder: (contxt, snapshot) {
                                if (snapshot.hasData) {
                                  ChatUser model =
                                      ChatUser.fromDoc(snapshot.data!);
                                  return ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: model.imageUrl.isEmpty
                                        ? ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                            child: Image.asset(
                                              'assets/images/default_pic.png',
                                              height: 50,
                                              width: 50,
                                            ),
                                          )
                                        : ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                            child: Image.network(
                                              model.imageUrl,
                                              width: 40,
                                              height: 40,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                    title: Text(model.name),
                                    subtitle: Text(model.pStatus),
                                    trailing: _controller.chatGroup.createdBy ==
                                            app.userId
                                        ? PopupMenuButton<int>(
                                            itemBuilder: (context) {
                                              return <PopupMenuEntry<int>>[
                                                PopupMenuItem(
                                                    child: Text(
                                                        'Remove ' + model.name),
                                                    onTap: () {
                                                      _controller.exitGroup(model.uid);
                                                    }),
                                              ];
                                            },
                                          )
                                        : null,
                                  );
                                } else if (snapshot.hasError) {
                                  return Text(snapshot.error.toString());
                                } else {
                                  return ListTile(
                                    leading: ClipRRect(
                                      borderRadius: BorderRadius.circular(30),
                                      child: Image.asset(
                                        'assets/images/default_pic.png',
                                        height: 40,
                                        width: 40,
                                      ),
                                    ),
                                  );
                                }
                              },
                            );
                          },
                        ),
                      ),
                      _controller.chatGroup.createdBy == app.userId
                          ? ElevatedButton.icon(
                              onPressed: () {
                                _controller.removeGroup();
                                Get.offAll(MainScreen());
                              },
                              icon: Icon(Icons.remove_circle),
                              label: Text('Remove Group'))
                          : ElevatedButton.icon(
                              onPressed: () {
                                _controller.exitGroup(app.userId);
                                Get.offAll(MainScreen());
                              },
                              icon: Icon(Icons.exit_to_app),
                              label: Text('Exit Group'))
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class addDesc extends StatelessWidget {
  TextEditingController _descController = TextEditingController();
  final ChatRoomController _controller = Get.find();
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('TextField AlertDemo'),
      content: TextField(
        controller: _descController,
        decoration: InputDecoration(hintText: "Enter Desc"),
      ),
      actions: [
        // ignore: deprecated_member_use
        FlatButton(
            onPressed: () async {
              await _controller.updateGroupDescription(_descController.text);
              Get.back();
            },
            child: Text('Submit'))
      ],
    );
  }
}
