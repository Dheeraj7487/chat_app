
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Controller/chatroom_controller.dart';
import '../Models/chatusers.dart';
import '../Themes/mythemes.dart';

class AddNewMembers extends StatefulWidget {
  static const routeName = '/add-new-members';

  @override
  _AddNewMembersState createState() => _AddNewMembersState();
}

class _AddNewMembersState extends State<AddNewMembers> {
  final ChatRoomController _controller = Get.find();
  List<ChatUser> selectedUsers = [];
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
            _controller.addNewParticipants(selectedUsers);
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
                'Add new member',
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
      body: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30), topRight: Radius.circular(30))),
        width: double.maxFinite,
        child: StreamBuilder<QuerySnapshot>(
          stream: _controller.getNewParticipants(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              _controller.notInGroup =
                  snapshot.data!.docs.map((e) => ChatUser.fromDoc(e)).toList();
              return ListView.builder(
                itemCount: _controller.notInGroup.length,
                padding: EdgeInsets.only(top: 10),
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      setState(() {
                        if (selectedUsers
                                .where((element) =>
                                    element.uid ==
                                    _controller.notInGroup[index].uid)
                                .length ==
                            0) {
                          selectedUsers.add(_controller.notInGroup[index]);
                        } else {
                          selectedUsers.removeWhere((element) =>
                              element.uid == _controller.notInGroup[index].uid);
                        }
                        print("selectedUsers = " +
                            selectedUsers.length.toString());
                      });
                    },
                    child: ListTile(
                      leading: _controller.notInGroup[index].imageUrl.isEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: Image.asset(
                                'assets/images/default_pic.png',
                                height: 50,
                                width: 50,
                              ),
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: Image.network(
                                _controller.notInGroup[index].imageUrl,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                            ),
                      title: Text(_controller.notInGroup[index].name),
                      subtitle: Text(_controller.notInGroup[index].pStatus),
                      trailing: selectedUsers
                                  .where((element) =>
                                      element.uid ==
                                      _controller.notInGroup[index].uid)
                                  .length !=
                              0
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
                },
              );
            } else {
              return Text("");
            }
          },
        ),
      ),
    );
  }
}
