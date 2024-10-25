import 'package:bookmart/models/user.dart';
import 'package:bookmart/screens/home/chat/chat_with_buyers.dart';
import 'package:bookmart/screens/home/chat/chat_with_sellers.dart';
import 'package:bookmart/shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

class Chat extends StatefulWidget {
  @override
  _ChatState createState() => _ChatState();

  final String currentTheme;

  Chat({this.currentTheme});
}

class _ChatState extends State<Chat> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool loading = false;

  @override
  Widget build(BuildContext context) {
    Color primaryColor;
    Color secondaryColor;



    if (widget.currentTheme == 'Blue') {
      primaryColor = Colors.blueAccent;
      secondaryColor = Colors.white;

    }


    final user = Provider.of<CustomUser>(context);

    if (loading) {
      return Loading(
        currentTheme: widget.currentTheme,
      );
    } else {
      return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chatrooms')
            .where('participants', arrayContains: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid))
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            print('Total conversations: ${snapshot.data.docs.length}');
            List<QueryDocumentSnapshot> allChats =  snapshot.data.docs;
            List<QueryDocumentSnapshot> chatsAsBuyer = snapshot.data.docs;
            List<QueryDocumentSnapshot> chatsAsSeller = snapshot.data.docs;
            chatsAsBuyer.removeWhere((element) => element.data()['participants'][1] != FirebaseFirestore.instance.collection('users').doc(user.uid));
            chatsAsSeller.removeWhere((element) => element.data()['participants'][0] != FirebaseFirestore.instance.collection('users').doc(user.uid));
            chatsAsBuyer.removeWhere((element) => element.data()['visibleTo'][1] == null);
            chatsAsSeller.removeWhere((element) => element.data()['visibleTo'][0] == null);

            print('chats as seller = 0? : ${chatsAsSeller.isEmpty}');
            print('chats as buyer = 0? : ${chatsAsBuyer.isEmpty}');


            //print('Chats as seller: ${chatsAsSeller.first.data()['']}');
            //print('Chats as buyer: ${chatsAsBuyer.length}');
            return DefaultTabController(
              length: 2,
              child: Scaffold(
                appBar: PreferredSize(
                  preferredSize: const Size(double.infinity, kToolbarHeight),
                  child: TabBar(
                    labelStyle: TextStyle(color: secondaryColor, fontSize: 14, fontFamily: 'Poppins Bold'),
                    indicatorColor: secondaryColor,
                    tabs: [
                      //Tab(child: Text('Buyers', style: TextStyle(color: secondaryColor, fontSize: 14, fontFamily: 'Poppins Bold'),),),
                      //Tab(child: Text('Sellers', style: TextStyle(color: secondaryColor, fontSize: 14, fontFamily: 'Poppins Bold'),),),
                      Tab(text: 'Buyers',),
                      Tab(text: 'Sellers',),
                    ],
                  ),
                  //elevation: 0,
                  //backgroundColor: primaryColor,
                ),
                backgroundColor: primaryColor,
                key: _scaffoldKey,
                body: TabBarView(
                  children: [
                    ChatWithBuyers(currentTheme: widget.currentTheme, chatsWithBuyers: chatsAsSeller,),
                    ChatWithSellers(currentTheme: widget.currentTheme, chatsWithSellers: chatsAsBuyer,),
                  ],
                ),
              ),
            );
          } else {
            return Loading(currentTheme: widget.currentTheme,);
          }
        },
      );
    }
  }
}
