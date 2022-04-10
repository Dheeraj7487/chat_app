import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:shimmer/shimmer.dart';

import '../Controller/main_screen_controller.dart';
import '../Models/app_model.dart';
import '../Models/chatmembers.dart';
import '../Models/chats.dart';
import '../Models/searchModel.dart';
import '../Screens/chatroom.dart';
import '../Themes/mythemes.dart';

class OneSearch extends SearchDelegate<Chats> {
  final _controller = Get.find<MainScreenController>();
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
          onPressed: () {
            query = '';
          },
          icon: Icon(Icons.clear))
    ];
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    return ThemeData(
      primaryColor: HexColor("#E246CB"),
      fontFamily: GoogleFonts.poppins().fontFamily,
      colorScheme: ColorScheme.light(primary: Colors.white),
      textTheme: Theme.of(context).textTheme.copyWith(
            headline6: TextStyle(color: Colors.white),
          ),
      inputDecorationTheme:
          InputDecorationTheme(hintStyle: TextStyle(color: Colors.white)),
      appBarTheme: AppBarTheme(
          elevation: 0,
          toolbarHeight: 100,
          color: MyTheme.lightTheme.primaryColor,
          foregroundColor: Colors.white),
    );
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
        onPressed: () {
          close(context, Chats());
        },
        icon: AnimatedIcon(
          icon: AnimatedIcons.menu_arrow,
          progress: transitionAnimation,
        ));
  }

  @override
  Widget buildResults(BuildContext context) {
    return Text("");
    // return StreamBuilder<List<SearchModel>>(
    //   stream: _controller.query(query.toLowerCase()),
    //   builder: (context, snapshot) {
    //     if (!snapshot.hasData) {
    //       return SizedBox();
    //     }
    //     List<SearchModel> searchList = snapshot.data!
    //         .where((element) => element.id != app.userId)
    //         .toList();
    //
    //     return ListView.separated(
    //       itemCount: searchList.length,
    //       itemBuilder: (context, index) {
    //         return FutureBuilder<QuerySnapshot>(
    //           future: _controller.getChatbyId(
    //               searchList[index].id, searchList[index].isGroup),
    //           builder: (context, snapshot) {
    //             if (!snapshot.hasData) {
    //               return SizedBox();
    //             }
    //             if (snapshot.data!.docs.isNotEmpty) {
    //               Chats chats =
    //                   snapshot.data!.docs.map((e) => Chats.fromDoc(e)).first;
    //               if (chats.isGroup == searchList[index].isGroup) {
    //                 return ConvList(chats: chats);
    //               }
    //             }
    //             return SizedBox();
    //           },
    //         );
    //       },
    //       separatorBuilder: (BuildContext context, int index) {
    //         return Divider(
    //           height: 0.5,
    //         );
    //       },
    //     );
    //   },
    // );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return StreamBuilder<List<SearchModel>>(
      stream: _controller.query(query.toLowerCase()),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SizedBox();
        }
        List<SearchModel> searchList = snapshot.data!
            .where((element) => element.id != app.userId)
            .toList();
        print("searchList Data = " +
            searchList.map((e) => e.id).toList().toString());
        return ListView.separated(
          itemCount: searchList.length,
          physics: BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            return searchList[index].isGroup
                ? FutureBuilder<Chats>(
                    future:
                        _controller.getSearchGroupInfo(searchList[index].id),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Padding(
                          padding: EdgeInsets.all(8),
                          child: Shimmer.fromColors(
                              child: _controller.dummyListViewCell(),
                              baseColor: Colors.grey.shade300,
                              highlightColor: Colors.grey.shade300),
                        );
                      }
                      Chats chat = snapshot.data!;
                      return StreamBuilder<DocumentSnapshot>(
                          stream: _controller.getAppMemberInfo(chat.chatId),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return SizedBox();
                            }
                            ChatMembers members =
                                ChatMembers.fromDoc(snapshot.data!);
                            return InkWell(
                              onTap: () {
                                Get.toNamed(ChatRoom.routeName,arguments: [chat,members]);
                              },
                              child: ListTile(
                                leading: CircleAvatar(
                                  radius: 30,
                                  backgroundColor: Colors.white,
                                  child: _controller
                                      .profileImage(searchList[index].photo),
                                ),
                                title: Text(
                                  searchList[index].displayName,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Text(
                                  chat.lastmsg,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            );
                          });
                    },
                  )
                : FutureBuilder<Chats>(
                    future:
                        _controller.getSearchUserInfo(searchList[index].id),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Padding(
                          padding: EdgeInsets.all(8),
                          child: Shimmer.fromColors(
                              child: _controller.dummyListViewCell(),
                              baseColor: Colors.grey,
                              highlightColor: Colors.grey),
                        );
                      }
                      Chats chat = snapshot.data!;
                      return StreamBuilder<DocumentSnapshot>(
                          stream: _controller.getAppMemberInfo(chat.chatId),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return SizedBox();
                            }
                            ChatMembers members =
                                ChatMembers.fromDoc(snapshot.data!);
                            return InkWell(
                              onTap: () {
                                Get.toNamed(ChatRoom.routeName,arguments: [chat,members]);
                              },
                              child: ListTile(
                                leading: CircleAvatar(
                                  radius: 30,
                                  backgroundColor: Colors.white,
                                  child: _controller
                                      .profileImage(searchList[index].photo),
                                ),
                                title: Text(
                                  searchList[index].displayName,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Text(
                                  chat.lastmsg,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            );
                          });
                    },
                  );
            // : FutureBuilder<Chats>(
            //     future:
            //         _controller.getSearchGroupInfo(searchList[index].id),
            //     builder: (context, snapshot) {
            //       if (!snapshot.hasData) {
            //         return Padding(
            //           padding: EdgeInsets.all(8),
            //           child: Shimmer.fromColors(
            //               child: _controller.dummyListViewCell(),
            //               baseColor: Colors.grey,
            //               highlightColor: Colors.grey),
            //         );
            //       }
            //       Chats chat = snapshot.data!;
            //       return StreamBuilder<DocumentSnapshot>(
            //         stream: _controller.getAppMemberInfo(chat.chatId),
            //         builder: (context, snapshot) {
            //           if (!snapshot.hasData) {
            //             return SizedBox();
            //           }
            //           ChatMembers members =
            //               ChatMembers.fromDoc(snapshot.data!);
            //           return InkWell(
            //             onTap: () {},
            //             child: ListTile(
            //               leading: CircleAvatar(
            //                 radius: 30,
            //                 backgroundColor: Colors.white,
            //                 child: _controller
            //                     .profileImage(searchList[index].photo),
            //               ),
            //               title: Text(
            //                 searchList[index].name,
            //                 style: const TextStyle(
            //                   fontSize: 14,
            //                   fontWeight: FontWeight.w600,
            //                 ),
            //               ),
            //               subtitle: Text(
            //                 chat.lastmsg,
            //                 style: TextStyle(
            //                   fontSize: 13,
            //                   color: Colors.grey.shade600,
            //                 ),
            //               ),
            //             ),
            //           );
            //         },
            //       );
            //     },
            //   );
          },
          separatorBuilder: (BuildContext context, int index) {
            return Divider();
          },
        );
      },
    );
  }
}
