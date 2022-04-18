import 'package:flutter/material.dart';
import 'package:test_flutter/core/Utils.dart';
import 'package:test_flutter/models/User.dart';
import 'package:test_flutter/ui/chat/ChatActivity.dart';

class UserProfile extends StatelessWidget {
  UserProfile(this.userId);

  String userId = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        leading: BackButton(),
      ),
      body: FutureBuilder(
          future: Utils.getInfoAboutUser(userId),
          builder: (BuildContext context, AsyncSnapshot<User> userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.none ||
                !userSnapshot.hasData) {
              //print('project snapshot data is: ${projectSnap.data}');
              return Container();
            }
            var user = userSnapshot.data!;
            return SafeArea(
              child: Container(
                padding: EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          getAvatarWidget(user.avatarURL),
                          Padding(padding: EdgeInsets.only(right: 24)),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${user.name}",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20),
                              ),
                              Padding(padding: EdgeInsets.only(bottom: 6)),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  TextButton(
                                      onPressed: () {
                                        Utils.sendFriendsRequest(userId)
                                            .then((value) {
                                          if (value.isError)
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                                    content: Text(
                                                        value.errorText!)));
                                        });
                                      },
                                      child: Text(
                                        "Добавить в друзья",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 12),
                                      ),
                                      style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                                  Colors.indigo),
                                          shape: MaterialStateProperty.all<
                                                  RoundedRectangleBorder>(
                                              RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          )))),
                                  Padding(padding: EdgeInsets.only(right: 16)),
                                  TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ChatActivity(peerId: this.userId,isGroupMode: false,)));
                                      },
                                      child: Icon(
                                        Icons.send,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                      style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                                  Colors.indigo),
                                          shape: MaterialStateProperty.all<
                                                  RoundedRectangleBorder>(
                                              RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          )))),
                                ],
                              )
                            ],
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            );
          }),
    );
  }

  getAvatarWidget(String downloadURL) {
    if (downloadURL == "") {
      return CircleAvatar(radius: 40, child: Icon(Icons.person));
    } else {
      return CircleAvatar(
          radius: 60, backgroundImage: NetworkImage(downloadURL));
    }
  }
}
