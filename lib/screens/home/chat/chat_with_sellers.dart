import 'package:bookmart/screens/home/chat/specific_chat.dart';
import 'package:bookmart/shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:bookmart/models/user.dart';

class ChatWithSellers extends StatefulWidget {
  @override
  _ChatWithSellersState createState() => _ChatWithSellersState();

  final String currentTheme;
  List<QueryDocumentSnapshot> chatsWithSellers;

  ChatWithSellers({this.currentTheme, this.chatsWithSellers});

}

class _ChatWithSellersState extends State<ChatWithSellers> {

  bool loading = false;

  @override
  Widget build(BuildContext context) {
    Color primaryColor;
    Color secondaryColor;
    final user = Provider.of<CustomUser>(context);

    String imagePath;
    Gradient currentGradient;
    if (widget.currentTheme == 'Light') {
      primaryColor = Colors.teal;
      secondaryColor = Colors.white;
      imagePath = 'images/book-blueAccent.png';
      currentGradient = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.teal, Colors.white]);
    }

    if (widget.currentTheme == 'Blue') {
      primaryColor = Colors.blueAccent;
      secondaryColor = Colors.white;
      imagePath = 'images/book-white.png';
      // currentGradient = LinearGradient(
      //     begin: Alignment.topCenter,
      //     end: Alignment.bottomCenter,
      //     colors: [Colors.lightBlue[300], Colors.blue[700]]);
      currentGradient = LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Colors.lightBlue[600], Colors.blueAccent]);
    }

    if (widget.currentTheme == 'Dark') {
      primaryColor = Colors.black;
      secondaryColor = Colors.grey[350];
      imagePath = 'images/book-blueAccent.png';
      currentGradient = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black, Colors.grey[800]]);
    }

    print(widget.chatsWithSellers.runtimeType);
    bool isChatNull = false; // Are there chats at all?
    if (widget.chatsWithSellers.isEmpty) {
      isChatNull = true;
    }
    print(isChatNull);


    // widget.chatsWithSellers.removeWhere((element) => element.data()['messages'].isEmpty);
    // if (widget.chatsWithSellers.isEmpty) {
    //   isChatNull = true;
    // }
    // print(isChatNull);

    // List<bool> isSpecificChatNull = List.generate(widget.chatsWithSellers.length, (index) => false);
    // for (int index = 0; index <= widget.chatsWithSellers.length - 1; index++) {
    //   if (widget.chatsWithSellers.data()['messages'][0] == null || isChatNull) {
    //     isSpecificChatNull[index] = true;
    //   }
    // }
    // print(isSpecificChatNull[0]);
    //print(widget.chatsWithSellers[0].reference.id);
    print(widget.chatsWithSellers.length);
    List<dynamic> chatUIDs = List.generate(widget.chatsWithSellers.length, (index) => '');
    //print(widget.chatsWithSellers[0].data()['participants'][0].id);
    if (widget.chatsWithSellers.length > 0) {
      chatUIDs = widget.chatsWithSellers.map((e) => e.data()['participants'][0].id).toList();
      print(chatUIDs[0]);
    }

    // List<dynamic> chatUIDs = widget.chatsWithSellers.map((e) => e.data()['participants'][0].id ?? '').toList();



    if (loading) {

      return Loading(currentTheme: widget.currentTheme,);

    } else {
      return StreamBuilder<QuerySnapshot>(
        stream: chatUIDs.isEmpty ? FirebaseFirestore.instance.collection('users').where(FieldPath.documentId, isEqualTo: '123').snapshots() : FirebaseFirestore.instance.collection('users').where(FieldPath.documentId, whereIn: chatUIDs).snapshots(),
        builder: (context, snapshot) {

          if (snapshot.hasData) {
            List<QueryDocumentSnapshot> docs = snapshot.data.docs;
            List<dynamic> usernames = List.generate(docs.length, (index) => '');
            int index = 0;
            // print(docs[0].data()['username']);
            // docs.forEach((element) {
            //   usernames[index] = element.data()['username'];
            //   index++;
            // });
            if (docs.length != 0) {
              for (int index = 0; index < docs.length; index ++) {
                var snap = docs.where((element) => element.id == chatUIDs[index]);

                usernames[index] = snap.first.data()['username'];


              }
            }
            //List<dynamic> usernames = docs.map((e) => e.data()['username']).toList();
            // print(usernames[0]);
            return Scaffold(
              body: Container(
                decoration:
                BoxDecoration(color: primaryColor, gradient: currentGradient),
                child: Flex(
                  direction: Axis.vertical,
                  children: [
                    Expanded(child: isChatNull ?  Center(
                        child: Padding(
                          padding: const EdgeInsets.all(30),
                          child: Text(
                            'You have no chats to show.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: secondaryColor, fontFamily: 'Poppins Bold', fontSize: 14),
                          ),
                        )) : ListView.builder(
                        itemCount: widget.chatsWithSellers.length,
                        itemBuilder: (context, index) {
                          bool areNewMessages = false;
                          int totalMessages = widget.chatsWithSellers[index].data()['messages'] == null ? 0 : widget.chatsWithSellers[index].data()['messages'].length ?? 0;
                          if (totalMessages > 0) {
                            if (widget.chatsWithSellers[index]
                                .data()['messages'][totalMessages -
                                1]['readBy'][1] == false) {
                              areNewMessages = true;
                            }
                          } else {
                            areNewMessages = false;
                          }
                          print('Are new messages: $areNewMessages');
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Card(
                              shape:
                              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: secondaryColor)),
                              //margin: EdgeInsets.fromLTRB(20, 6 , 20, 0),
                              color: secondaryColor,
                              elevation: 0,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(10),
                                onTap: () async {
                                  setState(() {
                                    loading = true;
                                  });
                                  int lengthOfMessages = widget.chatsWithSellers[index].data()['messages'] == null ? 0 : widget.chatsWithSellers[index].data()['messages'].length;
                                  List<bool> readBy = List.generate(lengthOfMessages, (index) => true);
                                  for (int number = 0; number < lengthOfMessages - 1; number++) {
                                    List<dynamic> allMessages = widget.chatsWithSellers[index].data()['messages'];
                                    allMessages.forEach((element) {element['readBy'][1] = true;});
                                    await widget.chatsWithSellers[index].reference.update(
                                        {
                                          'messages' : allMessages
                                        }
                                    );
                                    // ['messages'][number].reference.update(
                                    //     {
                                    //       'readBy' : readBy
                                    //     }
                                    // );
                                  }

                                  // bool payableSeller = false;
                                  // String productID = widget.chatsWithSellers[index].data()['participants'];
                                  // var doc = await FirebaseFirestore.instance.collection('ads').doc(productID).get();
                                  // String sellerUID =  doc.data()['uid'];

                                  bool payable = false;
                                  String sellerUID = widget.chatsWithSellers[index].data()['participants'][0].id;
                                  String buyerUID = widget.chatsWithSellers[index].data()['participants'][1].id;

                                  var sellerDoc = await FirebaseFirestore.instance.collection('users').doc(sellerUID).get();
                                  var buyerDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

                                  if ((sellerDoc.data()['currency'] == "ZAR") && (buyerDoc.data()['currency'] == "ZAR") && (buyerDoc.data()['lastCountry'] == "South Africa") && (sellerDoc.data()['lastCountry'] == "South Africa")) {
                                    payable = true;

                                  }

                                  setState(() {
                                    loading = false;
                                  });
                                  Navigator.push(
                                    this.context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            SpecificChat(
                                              currentTheme:
                                              widget.currentTheme,
                                              chatroomID:
                                              widget.chatsWithSellers[index].id,
                                              chattingTo: usernames[index],
                                              payable: payable,
                                            )),
                                  );
                                },
                                child: Column(
                                  children: [
                                    ListTile(
                                      title: Text(
                                        '${widget.chatsWithSellers[index].data()['initialProduct']}',
                                        style: TextStyle(
                                            color: primaryColor,
                                            fontFamily: 'Poppins Bold',
                                            fontSize: 15),
                                      ),
                                      subtitle: areNewMessages ? Text(
                                        'New messages available',
                                        style: TextStyle(
                                            color: primaryColor,
                                            fontFamily: 'Poppins Regular',
                                            fontSize: 14),
                                      ) : null,
                                      trailing: Text(
                                        'Seller: ${usernames[index].toString()}',
                                        style: TextStyle(
                                            color: primaryColor,
                                            fontFamily: 'Poppins Regular',
                                            fontSize: 13),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );

                        }
                    ))

                  ],
                ),
              ),
            );

          } else {

            return Loading(currentTheme: widget.currentTheme,);

          }






        }
      );
    }
  }
}
