import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:chat_app_project_demo/Widgets/ChatWidgets/audioCall.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart';
import '../Controller/chatroom_controller.dart';
import '../Models/app_model.dart';
import '../Models/chatgroups.dart';
import '../Models/chatmembers.dart';
import '../Models/chatusers.dart';
import '../Models/messages.dart';
import '../Themes/mythemes.dart';
import '../Widgets/ChatWidgets/index.dart';
import '../Widgets/ChatWidgets/videoCall.dart';
import '../Widgets/buildChatComposer.dart';
import '../Widgets/chat.dart';
import '../collection_name.dart';
import 'Profiles/group_profile.dart';
import 'Profiles/opponent_profile.dart';

class ChatRoom extends StatefulWidget {
  static const routeName = '/chat-room';

  @override
  State<ChatRoom> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {


  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChatRoomController>(
      builder: (_controller) {
        return StreamBuilder<DocumentSnapshot>(
            stream: _controller.getOpponentProfile(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Scaffold(body: Center(child: Text('No Data')));
              }
              if (_controller.chats.isGroup) {
                _controller.chatGroup = ChatGroups.fromDoc(snapshot.data!);
              } else {
                _controller.user = ChatUser.fromDoc(snapshot.data!);
              }
              return Scaffold(
                appBar: AppBar(
                  backgroundColor: MyTheme.lightTheme.primaryColor,
                  toolbarHeight: 100,
                  centerTitle: false,
                  title: InkWell(
                    onTap: () {
                      if (_controller.chats.isGroup) {
                        Get.toNamed(GroupProfile.routeName);
                      } else {
                        Get.toNamed(OpponentProfile.routeName);
                      }
                    },
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white,
                          child: _controller.chats.isGroup
                              ? groupImage(_controller.chatGroup.photo)
                              : opponentImage(_controller.user.imageUrl),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _controller.chats.isGroup
                                    ? _controller.chatGroup.name
                                    : _controller.user.name,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                              StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection(CollectionName.Chats)
                                    .doc(_controller.chats.chatId)
                                    .collection(CollectionName.ChatMembers)
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return _controller.chats.isGroup
                                        ? Text(
                                            'Tap for more info',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                            ),
                                          )
                                        : Text(
                                            'Offline',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                            ),
                                          );
                                  }
                                  _controller.chatMembers = snapshot.data!.docs
                                      .map((e) => ChatMembers.fromDoc(e))
                                      .toList();
                                  List<ChatMembers> tempMembers = _controller
                                      .chatMembers
                                      .where((element) =>
                                          element.typing == true &&
                                          element.uId != app.userId)
                                      .toList();
                                  print("TYPING STATUS = " +
                                      tempMembers.length.toString());
                                  if (tempMembers.length == 0) {
                                    return _controller.chats.isGroup
                                        ? Text(
                                            'Tap for more info',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                            ),
                                          )
                                        : StreamBuilder<DocumentSnapshot>(
                                            stream: _controller.getInfo(
                                                _controller.chats.opponentUser),
                                            builder: (context, snapshot) {
                                              if (!snapshot.hasData) {
                                                return Text(
                                                  'offline',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 10,
                                                  ),
                                                );
                                              }
                                              ChatUser model = ChatUser.fromDoc(
                                                  snapshot.data!);
                                              return Text(
                                                model.status == onoff.online
                                                    ? "online"
                                                    : "offline",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                ),
                                              );
                                            },
                                          );
                                  }
                                  return StreamBuilder<DocumentSnapshot>(
                                    stream: _controller
                                        .getInfo(tempMembers.first.uId),
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData) {
                                        return _controller.chats.isGroup
                                            ? Text(
                                                'Tap for more info',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                ),
                                              )
                                            : Text(
                                                'Offline',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                ),
                                              );
                                      }
                                      ChatUser model =
                                          ChatUser.fromDoc(snapshot.data!);
                                      return Text(
                                        model.name + " is typing..",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    IconButton(
                        onPressed: () {
                          setState(() {
                            JoinChannel().onJoinVideo(context);
                          });
                          },
                        icon: Icon(Icons.videocam_outlined)),
                    IconButton(
                      onPressed: () {
                        JoinChannel().onJoinAudio(context);
                        },
                        icon: Icon(Icons.call)),
                  ],
                  elevation: 0,
                ),
                backgroundColor: MyTheme.lightTheme.primaryColor,
                body: GestureDetector(
                  onTap: () {
                    FocusScope.of(context).unfocus();
                  },
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 30),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(30),
                                    topRight: Radius.circular(30))),
                            child: _controller.inGroupUser.length ==
                                    _controller.chats.displayUsers.length
                                ? ChatList()
                                : Center(
                                    child: CircularProgressIndicator(),
                                  )),
                      ),
                      BuildChatComposer(
                        chats: _controller.chats,
                        chatGroups: _controller.chatGroup,
                        members: _controller.appUser,
                      ),
                    ],
                  ),
                ),
              );
            });
      },
    );
  }

  Widget groupImage(String imageUrl) {
    return imageUrl.isEmpty
        ? ClipRRect(
            child: Image.asset('assets/images/default_pic.png'),
            borderRadius: BorderRadius.circular(50),
          )
        : ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: Image.network(
              imageUrl,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
          );
  }

  Widget opponentImage(String imageUrl) {
    return imageUrl.isEmpty
        ? ClipRRect(
            child: Image.asset('assets/images/default_pic.png'),
            borderRadius: BorderRadius.circular(50),
          )
        : ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: Image.network(
              imageUrl,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
          );
  }
}

class ChatList extends StatelessWidget {
  final ChatRoomController _controller = Get.find();
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _controller.getChats(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.docs.length > 0) {
          _controller.messages =
              snapshot.data!.docs.map((e) => Messages.fromDoc(e)).toList();
          return ListView.builder(
            controller: _controller.scrollController,
            itemCount: _controller.messages.length,
            shrinkWrap: true,
            reverse: true,
            padding: const EdgeInsets.only(top: 10, bottom: 10),
            itemBuilder: (context, index) {
              _controller
                  .updateSingleMsgStatus(_controller.messages[index].msgId);
              return Chat(message: _controller.messages[index]);
            },
          );
        } else {
          return Center(
            child: Text('No Data...'),
          );
        }
      },
    );
  }
}
