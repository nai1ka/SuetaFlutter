import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:test_flutter/core/Utils.dart';
import 'package:test_flutter/models/Event.dart';
import 'package:test_flutter/ui/eventInfo/event_info_widget.dart';

final FirebaseAuth auth = FirebaseAuth.instance;
var userListReference = FirebaseFirestore.instance
    .collection("core")
    .doc("users")
    .collection("list");

class MyListsWidget extends StatefulWidget {
  const MyListsWidget({Key? key}) : super(key: key);

  @override
  _MyListWidgetState createState() => _MyListWidgetState();
}

class _MyListWidgetState extends State<MyListsWidget>
    with TickerProviderStateMixin {
  TabController? mTabController;
  final PageController mPageController = PageController(initialPage: 0);

  @override
  void initState() {
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
  void dispose() {
    super.dispose();
    mTabController!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      backgroundColor: Colors.amber,
      leading: BackButton(),
    ),
      body: StreamBuilder<Object>(
          stream: userListReference.doc(auth.currentUser!.uid).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {

                return SafeArea(
                  child: Column(
                    children: [
                      Container(
                        color: new Color(0xfff4f5f6),
                        padding: EdgeInsets.only(right: 10, left: 10, top: 5),
                        height: 38.0,
                        child: TabBar(
                          unselectedLabelColor: Colors.black54,
                          indicatorSize: TabBarIndicatorSize.tab,
                          indicator: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Theme.of(context).primaryColor),
                          isScrollable: false,
                          controller: mTabController,
                          tabs: ["Созданные", "Доступные"].map((item) {
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
                          children: [myEventsFuture(), availableEventsFuture()],
                        ),
                      )
                    ],
                  ),
                );

            }
            return Text("fdsdf");
          }),
    );
  }

  myEventsWidget(AsyncSnapshot<List<Event>> tempRequestsSnap) {
    var requestsData = tempRequestsSnap.data ?? [];
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
                          EventInfoWidget(requestsData[index].id)));
            },
            child: Card(
              color: Color(0xFFFBF1A3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Padding(
                padding: EdgeInsets.all(10.0),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              "${requestsData[index].eventName}",
                              style: TextStyle(fontSize: 14),
                            ),
                            Padding(padding: EdgeInsets.only(right: 5)),
                            Text(
                              "${Utils.humanizeDate(requestsData[index].eventDate)}",
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                        Text(
                            "Нужно ещё ${requestsData[index].peopleNumber - requestsData[index].users.length} гостей")
                      ],
                    ),
                    Spacer(),
                    IconButton(
                        onPressed: () {
                          CoolAlert.show(
                              context: context,
                              type: CoolAlertType.confirm,
                              title: "Вы уверены?",
                              text: 'Удаление нельзя отменить',
                              confirmBtnText: 'Да',
                              cancelBtnText: 'Нет',
                              confirmBtnColor: Colors.green,
                              onConfirmBtnTap: () {
                               Navigator.pop(context);

                                var status = Utils.deleteEvent(
                                    requestsData[index]);
                                if(!status) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Ошибка удаления, обратиитесь к разработчику")));
                               setState(() {

                               });
                              });
                        },
                        icon: Icon(Icons.delete))
                  ],
                ),
              ),
            ),
          );
        });
  }

  availableEventsWidget(AsyncSnapshot<List<Event>> tempRequestsSnap) {
    var requestsData = tempRequestsSnap.data ?? [];
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
                          EventInfoWidget(requestsData[index].id)));
            },
            child: Card(
              color: Color(0xFFFBF1A3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Padding(
                padding: EdgeInsets.all(10.0),
                child: Row(
                  children: [
                    Padding(padding: EdgeInsets.only(right: 5)),
                    Text(
                      "${requestsData[index].eventName}",
                      style: TextStyle(fontSize: 14),
                    ),
                    Padding(padding: EdgeInsets.only(right: 5)),
                    Text(
                      "${Utils.humanizeDate(requestsData[index].eventDate)}",
                      style: TextStyle(fontSize: 14),
                    ),
                    Spacer(),
                  ],
                ),
              ),
            ),
          );
        });
  }

  myEventsFuture() {
    return FutureBuilder(
        future: Utils.getUsersOwnEvents(auth.currentUser!.uid),
        builder: (context, AsyncSnapshot<List<Event>> requestsSnap) {
          if (requestsSnap.connectionState == ConnectionState.none ||
              !requestsSnap.hasData) {
            return Container();
          }
          return RefreshIndicator(
              onRefresh: () async {}, child: myEventsWidget(requestsSnap));
        });
  }

  availableEventsFuture() {
    return FutureBuilder(
        future: Utils.getUsersAvailableEvents(auth.currentUser!.uid),
        builder: (context, AsyncSnapshot<List<Event>> requestsSnap) {
          if (requestsSnap.connectionState == ConnectionState.none ||
              !requestsSnap.hasData) {
            return Container();
          }
          return RefreshIndicator(
              onRefresh: () async {},
              child: availableEventsWidget(requestsSnap));
        });
  }
}
