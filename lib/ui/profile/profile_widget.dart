import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:test_flutter/core/Utils.dart';
import 'package:test_flutter/ui/registration/registration_widget.dart';
import 'package:test_flutter/models/User.dart' as UserClass;

final FirebaseAuth auth = FirebaseAuth.instance;

class ProfileWidget extends StatefulWidget {
  const ProfileWidget({Key? key}) : super(key: key);

  @override
  _ProfileWidgetState createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {
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
                              onPressed: () {},
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
                              child: FutureBuilder<List<UserClass.User>>(
                            builder: (context,
                                AsyncSnapshot<List<UserClass.User>>
                                    friendsSnap) {
                              if (friendsSnap.connectionState ==
                                      ConnectionState.none &&
                                  friendsSnap.hasData) {
                                //print('project snapshot data is: ${projectSnap.data}');
                                return Container();
                              }
                              return ListView.builder(
                                  padding: const EdgeInsets.all(8),
                                  itemCount: friendsSnap.data!.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return InkWell(
                                      customBorder: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(26.0),
                                      ),
                                      onTap: () {},
                                      child: Card(
                                        color: Color(0xFFFBF1A3),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
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
                                              Padding(
                                                  padding: EdgeInsets.only(
                                                      right: 5)),
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
                            },
                            future:
                                Utils.getUsersFriendsProfiles(data["friends"]),
                          ))
                        ],
                      ),
                    );
                  }
                  return Text("Loading...");
                })));
  }
}
