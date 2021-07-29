
import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';

import 'package:test_flutter/ui/eventAdd/EventAddWidget.dart';
import 'package:test_flutter/ui/eventList/events_widget.dart';
import 'package:test_flutter/ui/map/map_widget.dart';
import 'package:test_flutter/ui/profile/profile_widget.dart';

final MaterialColor appColor = MaterialColor(0xFFF9D162, {
  50:Color.fromRGBO(238, 232, 224, 1.0),
  100:Color.fromRGBO(236, 227, 200, 1.0),
  200:Color.fromRGBO(245, 230, 191, 1.0),
  300:Color.fromRGBO(245, 222, 161, 1.0),
  400:Color.fromRGBO(245, 214, 130, 1.0),
  500:Color.fromRGBO(246, 208, 102, 1.0),
  600:Color.fromRGBO(245, 201, 79, 1.0),
  700:Color.fromRGBO(248, 198, 60, 1.0),
  800:Color.fromRGBO(252, 192, 27, 1.0),
  900:Color.fromRGBO(255, 186, 0, 1.0),
});
final geo = Geoflutterfire();
class MainPage extends StatefulWidget {


  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".



  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  int selectedIndex = 0;
  List<Widget> pages = [MapPage(),EventListWidget(),ProfileWidget()];
  bool isFabVisible = true;


  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Theme(data: ThemeData(primarySwatch: appColor,
    ), child: Scaffold(

        body: IndexedStack(
          index: selectedIndex,
          children: pages,
        ),
        bottomNavigationBar: buildBottomNavigationBar(),
        floatingActionButton: Visibility(child:  FloatingActionButton.extended(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => EventAddWidget()));
          },
           /* showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AddEventDialog();
                      });
                },*/
          label: Text('Навести суеты!'),
          icon: Icon(Icons.add),
        ),
          visible: isFabVisible,)



    ));
  }
  BottomNavigationBar buildBottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: selectedIndex,

      onTap: (value) {
        setState(() {
          if(value==2) isFabVisible = false;
          else isFabVisible = true;
          selectedIndex = value;
        });
      },
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.map), label: "Карта"),
        BottomNavigationBarItem(icon: Icon(Icons.event), label: "События"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Профиль"),

      ],
    );
  }


}
