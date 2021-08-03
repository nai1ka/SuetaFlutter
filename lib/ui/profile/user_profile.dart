import 'package:flutter/material.dart';
import 'package:test_flutter/core/Utils.dart';
import 'package:test_flutter/models/User.dart';

class UserProfile extends StatelessWidget {
  UserProfile(this.userId);

  String userId = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                          CircleAvatar(
                            radius: 40,
                            backgroundImage: NetworkImage(
                                "https://sun9-35.userapi.com/impg/if9IW4cjk9NqMP8jIDlpnyN4OzYwgI_slPuIRg/eI_lz4ndboQ.jpg?size=1707x1707&quality=96&sign=494450df4ad7064b42ef36684f1580f5&type=album"),
                          ),
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
                                        var status = Utils.sendFriendsRequest(userId);
                                        if(!status) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Ошибка отправки запроса, проверьте данные")));
                                      },
                                      child: Text("Добавить в друзья", style: TextStyle(color: Colors.white, fontSize: 12),),
                                      style: ButtonStyle(
                                        backgroundColor: MaterialStateProperty.all(Colors.indigo),
                                          shape: MaterialStateProperty.all<
                                                  RoundedRectangleBorder>(
                                              RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          16),
                                              )))),
                                  Padding(padding: EdgeInsets.only(right: 16)),
                                  TextButton(
                                      onPressed: () {},
                                      child: Icon(Icons.send, color: Colors.white, size: 16,),
                                      style: ButtonStyle(
                                          backgroundColor: MaterialStateProperty.all(Colors.indigo),
                                          shape: MaterialStateProperty.all<
                                              RoundedRectangleBorder>(
                                              RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius.circular(
                                                    16),
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
}
