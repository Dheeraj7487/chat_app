
import 'package:chat_app_project_demo/Screens/setting.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:floating_action_bubble/floating_action_bubble.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Controller/main_screen_controller.dart';
import '../Models/app_model.dart';
import '../Models/chats.dart';
import '../Themes/mythemes.dart';
import '../Widgets/all_archive.dart';
import '../Widgets/all_chats.dart';
import '../Widgets/all_favotire.dart';
import '../Widgets/oneSearch.dart';
import 'Profiles/my_profiles.dart';
import 'all_contact.dart';
import 'create_group.dart';

class MainScreen extends StatefulWidget {
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  TabController? _tabController;
  final _controller = Get.put(MainScreenController());
  Animation<double>? _animation;
  AnimationController? _animationController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance!.addObserver(this);
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) async {
      await _controller.updateStatus(1);
    });

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 260),
    );

    final curvedAnimation =
        CurvedAnimation(curve: Curves.easeInOut, parent: _animationController!);
    _animation = Tween<double>(begin: 0, end: 1).animate(curvedAnimation);
  }

  @override
  void dispose() {
    _tabController!.dispose();
    super.dispose();
    WidgetsBinding.instance!.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    print("MY APP STATE = $state");
    if (state == AppLifecycleState.inactive) {
      _controller.updateStatus(0);
    }
    if (state == AppLifecycleState.paused) {
      _controller.updateStatus(0);
    }
    if (state == AppLifecycleState.resumed) {
      _controller.updateStatus(1);
    }
    if (state == AppLifecycleState.detached) {
      _controller.updateStatus(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionBubble(
        items: <Bubble>[
          Bubble(
            title: "Group Chat",
            iconColor: Colors.white,
            bubbleColor: MyTheme.lightTheme.primaryColor,
            icon: Icons.group,
            titleStyle: TextStyle(fontSize: 16, color: Colors.white),
            onPress: () {
              Get.toNamed(CreateGroup.routeName);
              _animationController!.reverse();
            },
          ),
          // Floating action menu item
          Bubble(
            title: "Personal Chat",
            iconColor: Colors.white,
            bubbleColor: MyTheme.lightTheme.primaryColor,
            icon: Icons.person,
            titleStyle: TextStyle(fontSize: 16, color: Colors.white),
            onPress: () {
              Get.toNamed(AllContact.routeName);
              _animationController!.reverse();
            },
          ),
        ],

        // animation controller
        animation: _animation!,

        // On pressed change animation state
        onPress: () => _animationController!.isCompleted
            ? _animationController!.reverse()
            : _animationController!.forward(),

        // Floating Action button Icon color
        iconColor: MyTheme.lightTheme.primaryColor,

        // Flaoting Action button Icon
        iconData: Icons.add,
        backGroundColor: Colors.white,
      ),
      appBar: AppBar(
        backgroundColor: MyTheme.lightTheme.primaryColor,
        toolbarHeight: 100,
        centerTitle: false,
        title: Row(
          children: [
            Expanded(
              child: Text(
                'Fiber Chat',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
              onPressed: () {
                showSearch(context: context, delegate:  OneSearch());
              },
              icon: Icon(Icons.search)),
          PopupMenuButton<int>(
            icon: Icon(Icons.more_vert, color: Colors.white),
            onSelected: (item) {
              if (item == 0) {
                Get.toNamed(MyProfiles.routeName);
              }
              if (item == 1) {
                Get.toNamed(AllArchive.routeName);
              }
              if (item == 2) {
                Get.toNamed(Setting.routeName);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 0,
                child: Text(
                  'Profile',
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),
              ),
              PopupMenuItem(
                value: 1,
                child: Text(
                  'Archive Chat',
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),
              ),
              PopupMenuItem(
                value: 2,
                child: Text(
                  'Setting',
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
        ],
        elevation: 0,
      ),
      backgroundColor: MyTheme.lightTheme.primaryColor,
      body: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30), topRight: Radius.circular(30))),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Container(
                height: 45,
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: MyTheme.lightTheme.accentColor,
                  borderRadius: BorderRadius.circular(
                    25.0,
                  ),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      25.0,
                    ),
                    color: MyTheme.lightTheme.primaryColor,
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.black45,
                  tabs: [
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Chat'),
                          SizedBox(
                            width: 5,
                          ),
                          StreamBuilder<QuerySnapshot>(
                            stream: _controller.getAllusers(),
                            builder: (context, snapshot) {
                              List<Chats> allChats = [];
                              if (!snapshot.hasData) {
                                return Text('');
                              } else {
                                allChats = snapshot.data!.docs
                                    .map((e) => Chats.fromDoc(e))
                                    .toList();
                                int unReadFlagCount = allChats
                                    .where((element) =>
                                        element.unReadFlag[app.userId] == true)
                                    .toList()
                                    .length;
                                return !(unReadFlagCount == 0)
                                    ? Container(
                                        width: 25,
                                        height: 15,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.horizontal(
                                            left: Radius.circular(20),
                                            right: Radius.circular(20),
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            unReadFlagCount.toString(),
                                            style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.black,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                      )
                                    : Text('');
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    Text('Favorite'),
                    // Text('Archive'),
                  ],
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  AllChat(),
                  AllFavorite(),
                ],
                controller: _tabController,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
