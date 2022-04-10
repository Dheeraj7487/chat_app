import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../Controller/chatroom_controller.dart';
import '../../Themes/mythemes.dart';

class OpponentProfile extends StatelessWidget {
  static const routeName = '/opponent-profile';
  final ChatRoomController _controller = Get.find();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyTheme.lightTheme.primaryColor,
      appBar: AppBar(
        backgroundColor: MyTheme.lightTheme.primaryColor,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Positioned(
            height: MediaQuery.of(context).size.height * 0.3,
            width: MediaQuery.of(context).size.width,
            child: Container(
              color: MyTheme.lightTheme.primaryColor,
              child: Column(
                children: [
                  _controller.user.imageUrl.isEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.asset(
                            'assets/images/default_pic.png',
                            height: 100,
                            width: 100,
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.network(
                            _controller.user.imageUrl,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    _controller.user.name,
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  Text(
                    _controller.user.number,
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          Icon(
                            Icons.call,
                            size: 40,
                            color: Colors.white,
                          ),
                        ],
                      ),
                      SizedBox(
                        width: 30,
                      ),
                      Column(
                        children: [
                          Icon(
                            Icons.video_call,
                            size: 40,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            height: MediaQuery.of(context).size.height * 0.58,
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
                  Container(
                    padding: EdgeInsets.all(20),
                    width: double.infinity,
                    child: Text(
                      _controller.user.pStatus,
                      style: TextStyle(color: Colors.black),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
