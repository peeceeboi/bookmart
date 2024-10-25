import 'dart:convert';
import 'package:http/http.dart';
import 'package:bookmart/models/autogenjsondartbooks.dart';
import 'package:string_validator/string_validator.dart';

class BookFromAPI {
  String isbnNumber;

  BookFromAPI({this.isbnNumber});

  String title;

  dynamic getCover() async {

  }

  dynamic getMetadeta() async {
    try {

      print('Checking ISBN: $isbnNumber');
      final uri = Uri.parse('https://openlibrary.org/isbn/$isbnNumber.json');
      Response response = await get(uri);
      print(response.body);
      
      String body = response.body;
      bool match = isJson(response.body);
      if (!match) {
        return null;
      } else {
        Map data = json.decode(response.body);
        BookFromApi book = BookFromApi.fromJson(data);

        print(book.title);

        return book;
      }

    } catch (e) {
      return null;
    }
  }
}

class Details {
  String title;
  String subtitle;


}
