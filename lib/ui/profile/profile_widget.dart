import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:test_flutter/core/Utils.dart';
import 'package:test_flutter/ui/dialogs/AddFriendDialog.dart';
import 'package:test_flutter/ui/registration/registration_widget.dart';
import 'package:test_flutter/models/User.dart' as UserClass;

final FirebaseAuth auth = FirebaseAuth.instance;
var userListReference = FirebaseFirestore.instance
    .collection("core")
    .doc("users")
    .collection("list");

class ProfileWidget extends StatefulWidget {
  const ProfileWidget({Key? key}) : super(key: key);

  @override
  _ProfileWidgetState createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget>
    with TickerProviderStateMixin {
  TabController? mTabController;
  final PageController mPageController = PageController(initialPage: 0);
  var newAvatar = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    mTabController = TabController(
      length: 2,
      vsync: this,
    );
    mTabController!.addListener(() {
      //TabBar listener
      if (mTabController!.indexIsChanging) {
        onPageChange(mTabController!.index, p: mPageController);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    mTabController!.dispose();
  }

  onPageChange(int index, {PageController? p, TabController? t}) async {
    if (p != null) {
      //determine which switch is
      await mPageController.animateToPage(index,
          duration: Duration(milliseconds: 500),
          curve: Curves
              .ease); //Wait for pageview to switch, then release pageivew listener
    } else {
      mTabController!.animateTo(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: FutureBuilder(
                future: Utils.getInfoAboutUser(auth.currentUser!.uid),
                builder: (BuildContext context,
                    AsyncSnapshot<UserClass.User> userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.done &&
                      userSnapshot.hasData) {
                    var user = userSnapshot.data!;
                    return Container(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              InkWell(
                                  onTap: () async {
                                    var image =
                                    await ImagePicker().pickImage(
                                        source: ImageSource.gallery);
                                    if (image != null) {
                                      Utils.changeAvatarImage(File(image.path));
                                      setState(() {
                                        newAvatar = image.path;
                                      });

                                    };
                                  },
                                  child: getAvatarWidget(user.avatarURL)
                              )
                            ],
                          ),
                          Padding(padding: EdgeInsets.only(bottom: 10)),
                          Text(
                            "${user.name}",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Padding(padding: EdgeInsets.only(bottom: 10)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              /*FlatButton(
                                onPressed: () {},
                                color: Color(0xFFEAEAEA),
                                child: Icon(
                                  Icons.settings,
                                  size: 24,
                                  color: Color(0xFF282828),
                                ),
                                padding: EdgeInsets.all(2),
                                shape: CircleBorder(),
                              ),*/
                              FlatButton(
                                onPressed: () {},
                                color: Color(0xFFEAEAEA),
                                child: Icon(
                                  Icons.settings,
                                  size: 24,
                                  color: Color(0xFF282828),
                                ),
                                shape: CircleBorder(),
                              ),
                              FlatButton(
                                onPressed: () {
                                  auth.signOut();
                                  Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              RegistrationWidget()),
                                          (Route<dynamic> route) => false);
                                },
                                color: Color(0xFFEAEAEA),
                                child: Icon(
                                  Icons.exit_to_app,
                                  size: 24,
                                  color: Color(0xFF282828),
                                ),
                                shape: CircleBorder(),
                              )
                            ],
                          ),
                          Container(
                            width: double.infinity,
                            height: 70,
                            padding: EdgeInsets.all(10.0),
                            child: ElevatedButton(
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AddFriendDialog();
                                    });
                              },
                              child: Text("Добавить друзей"),
                              style: ButtonStyle(
                                  shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            10.0),
                                      ))),
                            ),
                          ),
                          Divider(
                            thickness: 2,
                          ),
                          Expanded(
                              child: Column(
                                children: [
                                  Container(
                                    color: new Color(0xfff4f5f6),
                                    height: 38.0,
                                    child: TabBar(
                                      unselectedLabelColor: Colors.black54,
                                      indicatorSize: TabBarIndicatorSize.tab,
                                      indicator: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                              8),
                                          color: Theme
                                              .of(context)
                                              .primaryColor),
                                      controller: mTabController,
                                      tabs: ["Друзья", "Заявки"].map((item) {
                                        return Tab(
                                          text: item,
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                  Expanded(
                                    child: PageView(
                                      controller: mPageController,
                                      children: [
                                        friendsFuture(user),
                                        requestsFuture(user),
                                      ],
                                    ),
                                  )
                                ],
                              ))
                        ],
                      ),
                    );
                  }
                  return Text("Loading...");
                })));
  }

  friendsWidget(AsyncSnapshot<List<UserClass.User>> friendsSnap) {
    return ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: (friendsSnap.data != null ? friendsSnap.data!.length : 0),
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
            customBorder: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(26.0),
            ),
            onTap: () {},
            child: Card(
              color: Color(0xFFFBF1A3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Padding(
                padding: EdgeInsets.all(10.0),
                child: Row(
                  children: [
                    getSmallAvatarWidget(friendsSnap.data![index].avatarURL),
                    Padding(padding: EdgeInsets.only(right: 5)),
                    Text(
                      "${friendsSnap.data![index].name}",
                      style: TextStyle(fontSize: 14),
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  friendsFuture(UserClass.User user) {
    return StreamBuilder(
        stream: userListReference.doc(user.id).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return FutureBuilder(
                future: Utils.getUsersFriendsProfiles(auth.currentUser!.uid),
                builder: (context,
                    AsyncSnapshot<List<UserClass.User>> requestsSnap) {
                  if (requestsSnap.connectionState == ConnectionState.none ||
                      !requestsSnap.hasData) {
                    //print('project snapshot data is: ${projectSnap.data}');
                    return Container();
                  }
                  return RefreshIndicator(
                      onRefresh: () async {},
                      child: friendsWidget(requestsSnap));
                });
          }
          return const Center(
              child: Text(
                "Ошибка загрузки. Попробуйте ещё раз",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ));
        });
  }

  ListView requestsWidget(
      AsyncSnapshot<List<UserClass.User>> tempRequestsSnap) {
    final requestsData = tempRequestsSnap.data ?? [];
    return ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: requestsData.length,
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
            customBorder: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(26.0),
            ),
            onTap: () {},
            child: Card(
              color: const Color(0xFFFBF1A3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  children: [
                    getSmallAvatarWidget(requestsData[index].avatarURL),
                    Padding(padding: EdgeInsets.only(right: 5)),
                    Text(
                      requestsData[index].name,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const Spacer(),
                    //Принятие запроса на дружбу
                    IconButton(
                        icon: const Icon(Icons.check_rounded),
                        onPressed: () {
                          //Удаление пользоователя из списка входящих запросов на дружбу
                          userListReference.doc(auth.currentUser!.uid).update({
                            "friendRequests":
                            FieldValue.arrayRemove([requestsData[index].id])
                          });
                          //Добавление пользователя в список друзей у обоих пользователей
                          userListReference.doc(auth.currentUser!.uid).update({
                            "friends": {requestsData[index].id: true}
                          });
                          userListReference.doc(requestsData[index].id).update({
                            "friends": {auth.currentUser!.uid: true}
                          });
                        }),
                    const Padding(padding: EdgeInsets.only(left: 5)),
                    //Отклонение запроса на дружбу
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () {
                        //Удаление пользоователя из списка входящих запросов на дружбу
                        userListReference.doc(auth.currentUser!.uid).update({
                          "friendRequests":
                          FieldValue.arrayRemove([requestsData[index].id])
                        });
                        //Удаление пользователя из списка исходящих запросов на дружбу
                        userListReference.doc(requestsData[index].id).update({
                          "friends.${auth.currentUser!.uid}":
                          FieldValue.delete()
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  StreamBuilder<DocumentSnapshot<Map<String, dynamic>>> requestsFuture(
      UserClass.User user) {
    return StreamBuilder(
        stream: userListReference.doc(user.id).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return FutureBuilder(
                future: Utils.getUsersRequests(auth.currentUser!.uid),
                builder: (context,
                    AsyncSnapshot<List<UserClass.User>> requestsSnap) {
                  if (requestsSnap.connectionState == ConnectionState.none ||
                      !requestsSnap.hasData) {
                    //print('project snapshot data is: ${projectSnap.data}');
                    return Container();
                  }
                  return RefreshIndicator(
                      onRefresh: () async {},
                      child: requestsWidget(requestsSnap));
                });
          }
          return const Text("fdsdf");
        });
  }

  Future<Future<List<List<UserClass.User>>>> getFriendsList(String id) async {
    return Future.wait([Utils.getUsersFriendsProfiles(id)]);
  }

  Future<Future<List<List<UserClass.User>>>> getRequestsList(String id) async {
    return Future.wait([Utils.getUsersRequests(id)]);
  }

  getAvatarWidget(String downloadURL) {
    if (newAvatar == "") {
      if (downloadURL == "") {
        return CircleAvatar(
            radius: 60,
            child: Icon(Icons.person));
      }
      else {
        return CircleAvatar(
            radius: 60,
            backgroundImage: NetworkImage(downloadURL));
      }
    }
    else {
      var newAvatarWidget =
      CircleAvatar(
          radius: 60,
          backgroundImage: FileImage(File(newAvatar)));
      newAvatar = "";
      return newAvatarWidget;
    }
  }


  getSmallAvatarWidget(String downloadURL) {
    if (downloadURL == "") {
      return CircleAvatar(
          radius: 20,
          child: Icon(Icons.person));
    }
    else {
      return CircleAvatar(
          radius: 20,
          backgroundImage: NetworkImage(downloadURL));
    }
  }
}
