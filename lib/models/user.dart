class CustomUser {

  final String uid;

  CustomUser ( {this.uid} );


}

class UserData {
  final String uid;
  final String email;
  final bool isGoogleUser;
  String username;
  String currency;
  double balance;

  UserData( {this.uid, this.email, this.isGoogleUser, this.username, this.currency, this.balance} );
}