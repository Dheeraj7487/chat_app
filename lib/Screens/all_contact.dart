
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Controller/all_contact_controller.dart';
import '../Models/chatusers.dart';
import '../Themes/mythemes.dart';

class AllContact extends StatelessWidget {
  static const routeName = '/all-contact';
  final _controller = Get.put(AllContactController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyTheme.lightTheme.primaryColor,
        toolbarHeight: 100,
        centerTitle: false,
        title: Row(
          children: [
            Expanded(
              child: Text(
                'Select contact',
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
        stream: _controller.getAllContacts(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            _controller.profiles =
                snapshot.data!.docs.map((e) => ChatUser.fromDoc(e)).toList();
            return ListView.separated(
              cacheExtent: 400,
              itemCount: _controller.profiles.length,
              shrinkWrap: true,
              physics: BouncingScrollPhysics(),
              separatorBuilder: (_, __) => Divider(height: 0.5,),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () async {
                    Get.back();
                    await _controller.startCnv(
                        isGroup: false,
                        imageUrl: '',
                        groupName: '',
                        ids: [_controller.profiles[index].uid]);
                  },
                  child: ListTile(
                    leading: _controller.profiles[index].imageUrl.isEmpty
                        ? CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.white,
                            child: Image.asset(
                              'assets/images/default_pic.png',
                            ),
                          )
                        : CircleAvatar(
                            radius: 30,
                            backgroundImage: NetworkImage(
                                _controller.profiles[index].imageUrl),
                          ),
                    title: Text(
                      _controller.profiles[index].name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      _controller.profiles[index].pStatus,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              },
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
