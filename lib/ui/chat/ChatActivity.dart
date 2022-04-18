import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:test_flutter/core/Utils.dart';
import 'package:test_flutter/models/ChatMessage.dart';

class ChatActivity extends StatefulWidget {
  ChatActivity({Key? key, required this.peerId, required this.isGroupMode}) : super(key: key);

  String peerId = "";
  bool isGroupMode = false;


  @override
  _ChatActivityState createState() => _ChatActivityState();
}

class _ChatActivityState extends State<ChatActivity> {
  final myController = new TextEditingController();
  List<QueryDocumentSnapshot> listMessage = new List.from([]);
  List<ChatMessage> messages = [];
  int _limit = 20;
  int _limitIncrement = 20;
  String chatId = "";

  final TextEditingController textEditingController = TextEditingController();
  final ScrollController listScrollController = ScrollController();


  _scrollListener() {
    if (listScrollController.offset >= listScrollController.position.maxScrollExtent &&
        !listScrollController.position.outOfRange) {
      setState(() {
        _limit += _limitIncrement;
      });
    }
  }
//TODO сделать чтобы отпаленно сообщения появлялось даже если оно не не отправлено, то ест грузится
  @override
  void initState() {
    super.initState();
    listScrollController.addListener(_scrollListener);
    var currentId = FirebaseAuth.instance.currentUser!.uid;
    var peerId = widget.peerId;
    if(!widget.isGroupMode){
      if (currentId.hashCode <= peerId.hashCode) {
        chatId = '$currentId-$peerId';
      } else {
        chatId = '$peerId-$currentId';
      }
    }
    else chatId = widget.peerId;

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(child: buildBottomPart(),)
    );
  }


  void onMessageSubmitted(String message) async {

  }


  Widget buildBottomPart() {
    return Column(
      children: <Widget>[
        StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('core')
                .doc('chat')
                .collection("messages")
                .doc(chatId)
                .collection(chatId)
                .orderBy('timestamp', descending: false)
                .limit(_limit)
                .snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) {
                return Center(
                    child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.cyan)));
              } else {
                listMessage = snapshot.data!.docs;
                messages = Utils.getMessageList(listMessage);
                return Expanded(
                  child: ListView.builder(

                    itemCount: messages.length,
                    shrinkWrap: true,
                    padding: EdgeInsets.only(top: 10,bottom: 10),
                    physics: AlwaysScrollableScrollPhysics(),
                    itemBuilder: (context, index){
                      return Container(
                        padding: EdgeInsets.only(left: 14,right: 14,top: 10,bottom: 10),
                        child: Align(
                          alignment: (messages[index].messageType == MessageTypes.receiver ? Alignment.topLeft : Alignment.topRight),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: (messages[index].messageType  == MessageTypes.receiver ? Colors.grey.shade200 : Colors.blue[200]),
                            ),
                            padding: EdgeInsets.all(16),
                            child: Text(messages[index].messageContent, style: TextStyle(fontSize: 15),),
                          ),
                        ),
                      );
                    },
                  ),
                );
              }



              /* */
            }
        ),
          
         Container(
            padding: EdgeInsets.only(left: 10, bottom: 10, top: 10),
            height: 60,
            width: double.infinity,
            color: Colors.white,
            child: Row(
              children: <Widget>[
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    height: 30,
                    width: 30,
                    decoration: BoxDecoration(
                      color: Colors.lightBlue,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Icon(Icons.add, color: Colors.white, size: 20,),
                  ),
                ),
                SizedBox(width: 15,),
                Expanded(
                  child: TextField(
                    onSubmitted: (value) {
                      onSendMessage(textEditingController.text);
                    },
                    controller: textEditingController,
                    decoration: InputDecoration(
                        hintText: "Введите сообщение...",
                        hintStyle: TextStyle(color: Colors.black54),
                        border: InputBorder.none
                    ),
                  ),
                ),
                SizedBox(width: 15,),
                FloatingActionButton(
                  onPressed: () {
                    onSendMessage(textEditingController.text);
                  },
                  child: Icon(Icons.send, color: Colors.white, size: 18,),
                  backgroundColor: Colors.blue,
                  elevation: 0,
                ),
              ],

            ),
          ),
      
      ],
    );
  }


  void onSendMessage(String text) {
    // type: 0 = text, 1 = image, 2 = sticker
    if (text.trim() != '') {
      textEditingController.clear();

      var documentReference = FirebaseFirestore.instance
          .collection('core')
          .doc('chat')
          .collection("messages")
          .doc(chatId)
          .collection(chatId)
          .doc(DateTime.now().millisecondsSinceEpoch.toString());

      FirebaseFirestore.instance.runTransaction((transaction) async {
        await transaction.set(
          documentReference,
          {
            'idFrom': FirebaseAuth.instance.currentUser!.uid,
            'idTo': widget.peerId,
            'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
            'text': text,
          },
        );
      });
      listScrollController.animateTo(0.0, duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      Fluttertoast.showToast(msg: 'Nothing to send');
    }
  }
}
