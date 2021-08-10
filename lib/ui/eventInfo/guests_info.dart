import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:test_flutter/core/Utils.dart';
import 'package:test_flutter/models/Event.dart';
import 'package:test_flutter/models/User.dart' as UserClass;
import 'package:test_flutter/ui/profile/user_profile.dart';

final FirebaseAuth auth = FirebaseAuth.instance;
var userListReference = FirebaseFirestore.instance
    .collection("core")
    .doc("users")
    .collection("list");

var eventListReference = FirebaseFirestore.instance
    .collection("core")
    .doc("events")
    .collection("list");

class GuestInfoWidget extends StatefulWidget {
  GuestInfoWidget(this.eventId);

  String eventId;

  @override
  _GuestInfoWidgetState createState() => _GuestInfoWidgetState();
}

class _GuestInfoWidgetState extends State<GuestInfoWidget>
    with TickerProviderStateMixin {
  late TabController mTabController;
  final PageController mPageController = PageController(initialPage: 0);

  @override
  void initState() {
    mTabController = TabController(
      length: 2,
      vsync: this,
    );
    mTabController.addListener(() {
      //TabBar listener
      if (mTabController.indexIsChanging) {
        onPageChange(mTabController.index, p: mPageController);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    mTabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.eventId != "") {
      return StreamBuilder(
          stream: eventListReference.doc(widget.eventId).snapshots(),
          builder: (context, snapshot) {
            return Scaffold(
                appBar: AppBar(),
                body: FutureBuilder(
                    future: Utils.getInfoAboutEvent(widget.eventId),
                    builder: (context, AsyncSnapshot<Event> eventSnap) {
                      if (eventSnap.hasData) {
                        return Column(
                          children: [
                            Container(
                              color: new Color(0xfff4f5f6),
                              padding:
                                  EdgeInsets.only(right: 10, left: 10, top: 5),
                              height: 38.0,
                              child: TabBar(
                                unselectedLabelColor: Colors.black54,
                                indicatorSize: TabBarIndicatorSize.tab,
                                indicator: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: Theme.of(context).primaryColor),
                                isScrollable: false,
                                controller: mTabController,
                                tabs: ["Принятые", "Запросы"].map((item) {
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
                                  getAcceptedGuestsFuture(eventSnap.data!),
                                  getNotAcceptedGuestsFuture(eventSnap.data!)
                                ],
                              ),
                            )
                          ],
                        );
                      } else {
                        return Container();
                      }
                    }));
          });
    } else {
      return Container();
    }
  }

  ListView acceptedGuestWidget(
      AsyncSnapshot<List<UserClass.User>> tempRequestsSnap) {
    final List<UserClass.User> requestsData = tempRequestsSnap.data ?? [];
    return ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: requestsData.length,
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
            customBorder: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(26.0),
            ),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          UserProfile(requestsData[index].id)));
            },
            child: Card(
              color: const Color(0xFFFBF1A3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  children: [
                    Utils.getAvatarWidget(requestsData[index].avatarURL, 20),
                    Padding(padding: EdgeInsets.only(right: 5)),
                    Text(
                      requestsData[index].name,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  getAcceptedGuestsFuture(Event event) {
    return FutureBuilder(
      future: Utils.getEventAcceptedGuests(event),
      builder: (context, AsyncSnapshot<List<UserClass.User>> requestsSnap) {
        if (requestsSnap.connectionState == ConnectionState.none ||
            !requestsSnap.hasData) {
          //print('project snapshot data is: ${projectSnap.data}');
          return Container();
          //TODO сделать экран с загрузкой
        }
        return RefreshIndicator(
            onRefresh: () async {}, child: acceptedGuestWidget(requestsSnap));
      },
    );
  }

  ListView notAcceptedGuestWidget(
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
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          UserProfile(requestsData[index].id)));
            },
            child: Card(
              color: const Color(0xFFFBF1A3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  children: [
                    Utils.getAvatarWidget(requestsData[index].avatarURL, 20),
                    Padding(padding: EdgeInsets.only(right: 5)),
                    Text(
                      requestsData[index].name,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const Spacer(),
                    //Принятие запроса на мероприятие
                    IconButton(
                      icon: const Icon(Icons.check_rounded),
                      onPressed: () {
                        //Удаление пользоователя из списка входящих запросов на дружбу
                        userListReference.doc(requestsData[index].id).update({
                          "events": {widget.eventId: true}
                        });
                        //Добавление пользователя в список друзей у обоих пользователей
                        eventListReference.doc(widget.eventId).update({
                          "users": {requestsData[index].id: true}
                        });
                        setState(() {
                          //TODO доделать
                        });
                      },
                    ),
                    const Padding(padding: EdgeInsets.only(left: 5)),
                    //Отклонение запроса на дружбу
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () {
                        eventListReference.doc(widget.eventId).update({
                          "users.${requestsData[index].id}": FieldValue.delete()
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

  getNotAcceptedGuestsFuture(Event event) {
    return FutureBuilder(
      future: Utils.getEventNotAcceptedGuests(event),
      builder: (context, AsyncSnapshot<List<UserClass.User>> requestsSnap) {
        if (requestsSnap.connectionState == ConnectionState.none ||
            !requestsSnap.hasData) {
          //print('project snapshot data is: ${projectSnap.data}');
          return Container();
          //TODO сделать экран с загрузкой
        }
        return RefreshIndicator(
            onRefresh: () async {},
            child: notAcceptedGuestWidget(requestsSnap));
      },
    );
  }

  onPageChange(int index, {PageController? p, TabController? t}) async {
    if (p != null) {
      //determine which switch is
      await mPageController.animateToPage(index,
          duration: Duration(milliseconds: 500),
          curve: Curves
              .ease); //Wait for pageview to switch, then release pageivew listener
    } else {
      mTabController.animateTo(index);
    }
  }
}
