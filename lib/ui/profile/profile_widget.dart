import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:test_flutter/core/Utils.dart';
import 'package:test_flutter/ui/dialogs/AddFriendDialog.dart';
import 'package:test_flutter/ui/registration/registration_widget.dart';
import 'package:test_flutter/models/User.dart' as UserClass;

final FirebaseAuth auth = FirebaseAuth.instance;

class ProfileWidget extends StatefulWidget {
  const ProfileWidget({Key? key}) : super(key: key);

  @override
  _ProfileWidgetState createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget>
    with TickerProviderStateMixin {
  TabController? mTabController;
  final PageController mPageController = PageController(initialPage: 0);

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
            child: FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection("core")
                    .doc("users")
                    .collection("list")
                    .doc(auth.currentUser!.uid)
                    .get(),
                builder: (BuildContext context,
                    AsyncSnapshot<DocumentSnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    Map<String, dynamic> data =
                        snapshot.data!.data() as Map<String, dynamic>;
                    return Container(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 60,
                                backgroundImage: NetworkImage(
                                    "https://sun9-35.userapi.com/impg/if9IW4cjk9NqMP8jIDlpnyN4OzYwgI_slPuIRg/eI_lz4ndboQ.jpg?size=1707x1707&quality=96&sign=494450df4ad7064b42ef36684f1580f5&type=album"),
                              )
                            ],
                          ),
                          Padding(padding: EdgeInsets.only(bottom: 10)),
                          Text(
                            "${data["name"]}",
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
                                borderRadius: BorderRadius.circular(10.0),
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
                                      borderRadius: BorderRadius.circular(8),
                                      color: Theme.of(context).primaryColor),
                                  isScrollable: false,
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
                                  scrollDirection: Axis.horizontal,
                                  controller: mPageController,
                                  children: [
                                    friendsFuture(data),
                                    requestsFuture(data),
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
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(
                          "https://sun9-35.userapi.com/impg/if9IW4cjk9NqMP8jIDlpnyN4OzYwgI_slPuIRg/eI_lz4ndboQ.jpg?size=1707x1707&quality=96&sign=494450df4ad7064b42ef36684f1580f5&type=album"),
                    ),
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

  friendsFuture(Map<String, dynamic> data) {
    Future<List<UserClass.User>> friendsList =
        Utils.getUsersFriendsProfiles(data["friends"]);
    return FutureBuilder<List<UserClass.User>>(
      builder: (context, AsyncSnapshot<List<UserClass.User>> friendsSnap) {
        if (friendsSnap.connectionState == ConnectionState.none ||
            !friendsSnap.hasData) {
          //print('project snapshot data is: ${projectSnap.data}');
          return Container();
        }
        return RefreshIndicator(
            child: friendsWidget(friendsSnap),
            onRefresh: () async {
              /*setState(() {
                friendsList = getFriendsList(data);
              });*/
            });
      },
      future: Utils.getUsersFriendsProfiles(data["friends"]),
    );
  }

  requestsWidget(AsyncSnapshot<List<UserClass.User>> requestsSnap) {
    return ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: (requestsSnap.data != null ? requestsSnap.data!.length : 0),
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
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(
                          "https://sun9-35.userapi.com/impg/if9IW4cjk9NqMP8jIDlpnyN4OzYwgI_slPuIRg/eI_lz4ndboQ.jpg?size=1707x1707&quality=96&sign=494450df4ad7064b42ef36684f1580f5&type=album"),
                    ),
                    Padding(padding: EdgeInsets.only(right: 5)),
                    Text(
                      "${requestsSnap.data![index].name}",
                      style: TextStyle(fontSize: 14),
                    ),
                    Spacer(),
                    IconButton(
                      icon: Icon(Icons.check_rounded),
                      onPressed: () {},
                    ),
                    Padding(padding: EdgeInsets.only(left: 5)),
                    IconButton(
                      icon: Icon(Icons.close_rounded),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  requestsFuture(Map<String, dynamic> data) {
    Future<List<UserClass.User>> requestsList =
        Utils.getUsersRequests(data["friendRequests"]);
    return FutureBuilder<List<UserClass.User>>(
      builder: (context, AsyncSnapshot<List<UserClass.User>> requestsSnap) {
        if (requestsSnap.connectionState == ConnectionState.none ||
            !requestsSnap.hasData) {
          //print('project snapshot data is: ${projectSnap.data}');
          return Container();
        }
        return RefreshIndicator(
            onRefresh: () async {
              /*setState(() {
                requestsList = getRequestsList(data);
              });*/
            },
            child: requestsWidget(requestsSnap));
      },
      future: requestsList,
    );
  }
}
