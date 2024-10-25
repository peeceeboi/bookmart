import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:bookmart/shared/loading.dart';
import 'package:bookmart/services/auth.dart';
import '../screens/home/home.dart';

final AuthService _auth = AuthService();

class ConnectionError extends StatefulWidget {
  @override
  _ConnectionErrorState createState() => _ConnectionErrorState();
}

class _ConnectionErrorState extends State<ConnectionError> {
  bool loading = false;
  bool connectionProblem = true;

  @override
  Widget build(BuildContext context) {

    if (connectionProblem == false) {
      return Home();
    }

    if (loading) {
      return Loading();
    } else {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [Colors.lightBlue[300], Colors.deepPurpleAccent])),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.error,
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'Check your internet connection.',
                  style: TextStyle(
                      color: Colors.red, fontFamily: 'Poppins Regular'),
                ),
                RaisedButton(
                  onPressed: () async {
                    setState(() {
                      loading = true;
                    });
                    dynamic emailVerified = _auth.emailVerified();
                    if (emailVerified == null) {
                      setState(() {
                        loading = false;
                      });

                    } else {
                      setState(() {
                        connectionProblem = false;
                      });
                    }
                  },
                  child: Text(
                    'Refresh',
                    style: TextStyle(
                        color: Colors.white, fontFamily: 'Poppins Regular'),
                  ),
                )
              ],
            ),
          ),
        ),
      );
    }
  }
}
