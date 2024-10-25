import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

const textInputDecoration = InputDecoration(
  errorStyle: TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'Poppins Regular'),
  labelStyle: TextStyle(fontFamily: 'Poppins Regular'),
  hintStyle: TextStyle(fontFamily: 'Poppins Regular'),
  fillColor: Colors.white,
  filled: true,
  enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.grey),
      borderRadius: BorderRadius.all((Radius.circular(12)))),
  focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all((Radius.circular(12))),
      borderSide: BorderSide(color: Colors.blueAccent)),
);

AlertDialog googleWarningAlertDialog() {
  // return AlertDialog(
  //   title: Text('Attention', style: TextStyle(fontFamily: 'Open Sans Semi Bold'),),
  //   content: Text('You cannot do this when you are signed in with Google.', style: TextStyle(fontFamily: 'Open Sans Semi Bold'),),
  //   actions: [
  //     FlatButton(onPressed: () {
  //         Navigator.of(context, rootNavigator: true).pop();
  //     }, child: Text('Ok'))
  //   ],
  //   elevation: 24,
  //   backgroundColor: Colors.white,
  //  // shape: CircleBorder(),
  // );
}

SizedBox homeSelectionCard(String action, Icon icon, Function function) {
  return SizedBox(
    width: double.infinity,
    child: Card(
      shape:
      RoundedRectangleBorder(
          side: BorderSide(color: Colors.white, width: 1),
          borderRadius: BorderRadius.circular(45)),
      color: Colors.white,
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          function.call();
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: icon,
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(action, style: TextStyle(color: Colors.blueAccent, fontSize: 20, fontFamily: "Poppins Bold", ), textAlign: TextAlign.center,),
            )
          ],
        ),
      ),
    ),
  );
}

Card simpleTestCard() {
  return Card(
    shape:
    RoundedRectangleBorder(
        side: BorderSide(color: Colors.blueAccent, width: 1),
        borderRadius: BorderRadius.circular(10)),
    color: Colors.white,
    elevation: 0,
    child: InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () {

      },
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              radius: 30,
            ),
            title: Text(
              "Test Book",
              style: TextStyle(
                  color: Colors.blueAccent,
                  fontFamily: 'Poppins Bold',
                  fontSize: 15),
            ),
            subtitle: Text(
              'Author: Test Author',
              style: TextStyle(
                  color: Colors.blueAccent, fontFamily: 'Poppins Regular'),
              textAlign: TextAlign.left,
            ),
            trailing: Text(
              "R500",
              style: TextStyle(
                  color: Colors.blueAccent, fontFamily: 'Poppins Regular'),
            ),
          ),
          ListTile(
            title: Text(
              'Condition: Good',
              style: TextStyle(
                  color: Colors.blueAccent,
                  fontFamily: 'Poppins Bold',
                  fontSize: 13),
            ),
            subtitle: Text(
              'Cape Town, South Africa',
              style: TextStyle(
                  color: Colors.blueAccent,
                  fontFamily: 'Poppins Regular',
                  fontSize: 13),
            ),
            trailing: Text(
              ' 5 km away',
              style: TextStyle(
                  color: Colors.blueAccent, fontFamily: 'Poppins Regular'),
            ),
          ),
        ],
      ),
    ),
  );
}

const List<String> allMajors = [
  'Subject Notes',
  'AgriSciences',
  'Arts and Social Sciences',
  'Economic and Management Sciences',
  'Education',
  'Engineering',
  'Law',
  'Medicine and Health Sciences',
  'Military Science',
  'Science',
  'Theology',
  'Accounting',
  'Advertising',
  'Agribusiness',
  'Agriculture (general)',
  'Agronomy & Plant Science',
  'American Studies',
  'Animal Science',
  'Anthropological Science',
  'Anthropology',
  'Aquaculture & Fisheries',
  'Architecture',
  'Art History & Theory',
  'Asian Studies',
  'Astronomy',
  'Aviation',
  'Aviation Management',
  'Biblical Studies',
  'Biochemistry',
  'Bioinformatics',
  'Biology (general)',
  'Biomedical Engineering',
  'Biomedical Sciences (not elsewhere classified)',
  'Biotechnology',
  'Botany',
  'Chemical & Process Engineering',
  'Chemistry',
  'Chinese',
  'Chinese Studies',
  'Christian Thought & History',
  'Civil Engineering',
  'Classical Studies',
  'Clothing & Textiles',
  'Communication & Professional Writing',
  'Computer Engineering',
  'Computer Science',
  'Conflict Resolution',
  'Construction & Project Management',
  'Counselling',
  'Creative Writing',
  'Criminology & Justice',
  'Cultural Studies',
  'Dance',
  'Defence Studies',
  'Dental Technology',
  'Dentistry',
  'Design (general)',
  'Drama / Theatre Studies',
  'Earth Science (general)',
  'Ecology',
  'e-Commerce',
  'Economics',
  'Education Studies',
  'Electrical Engineering',
  'Electronics',
  'Energy Studies & Management',
  'Engineering Science',
  'English',
  'English as a Second Language',
  'Entrepreneurship',
  'Environmental & Natural Resources Engineering',
  'Environmental Health',
  'Environmental Science',
  'Environmental Studies',
  'Ethics',
  'European Languages & Cultures',
  'European Studies',
  'Fashion Design',
  'Film & Media Studies',
  'Film-making',
  'Finance',
  'Fine Arts',
  'Food Science',
  'Forensic Analytical Science',
  'Forestry',
  'French',
  'Gender Studies',
  'Genetics',
  'Geography',
  'Geology',
  'German',
  'Graphic Design',
  'Greek',
  'Health Promotion',
  'History',
  'Hospitality Management',
  'Human Development Studies',
  'Human Nutrition',
  'Human Resource Management',
  'Information Science',
  'International Business',
  'International Relations',
  'International Studies',
  'Interpreting & Translating',
  'Italian',
  'Japanese',
  'Japanese Studies',
  'Journalism',
  'Korean',
  'Labour & Industrial Relations',
  'Land Use Planning & Management',
  'Latin',
  'Linguistics',
  'Management',
  'Māori Development',
  'Māori Health',
  'Māori Language / Te Reo Māori',
  'Māori Media Studies',
  'Māori Studies',
  'Māori Visual Arts',
  'Marine Biology',
  'Marine Science',
  'Maritime Engineering',
  'Marketing',
  'Mathematics',
  'Mechanical Engineering',
  'Mechatronics',
  'Medical Laboratory Science',
  'Microbiology',
  'Midwifery',
  'Music Composition',
  'Music Performance',
  'Music Studies',
  'Nanoscience',
  'Neuroscience',
  'New Zealand Sign Language',
  'Nursing',
  'Occupational Therapy & Rehabilitation',
  'Optometry',
  'Oral Health',
  'Other',
  'Pacific Island Studies',
  'Paramedicine',
  'Pastoral Studies',
  'Pharmacology',
  'Pharmacy',
  'Philosophy',
  'Photography',
  'Physics',
  'Physiology',
  'Physiotherapy',
  'Podiatry',
  'Political Studies',
  'Population & Development Studies',
  'Population Health',
  'Product & Industrial Design',
  'Psychology',
  'Public Policy',
  'Public Relations',
  'Quantity Surveying',
  'Radiation Therapy',
  'Radio, TV & Studio Production',
  'Religious Studies',
  'Russian',
  "Samoan Studies / Fa'asamoa",
  'Social Policy',
  'Social Science (general)',
  'Social Work',
  'Sociology',
  'Spanish',
  'Speech & Language Therapy',
  'Sport & Exercise Science',
  'Sport & Leisure Studies & Management',
  'Sport Coaching',
  'Statistics',
  'Supply Chain Management',
  'Surveying',
  'Taxation',
  'Teaching – Early Childhood',
  "Teaching – Māori Language",
  'Teaching – Physical Education',
  'Teaching – Primary',
  'Teaching – Secondary',
  'Teaching – Technology',
  'Tourism',
  'Valuation & Property Management',
  'Veterinary Science & Technology',
  'Web & Digital Design',
  'Zoology',
  'Unlisted Subject'
];

List<String> nonFictionalGenreList = [
  'History',
  'Biographies, autobiographies, and memoirs',
  'Travel guides and travelogues',
  'Philosophy and insight',
  'Journalism',
  'Self-help and instruction',
  'Guides and how-to manuals',
  'Humor and commentary',
];

List<String> fictionalGenreList = [
  'Crime / Mystery',
  'Fantasy',
  'Romance',
  'Science fiction',
  'Inspirational',
  'Horror',
  'Action / Adventure',
  'Suspense / Thriller',
  'Young Adult',
  'Historical',
  'Western',
];

List<String> completeList = [
  'All Categories',
  'Academics',
  'Fiction',
  'Non-fiction'
] + allMajors +
    fictionalGenreList +
    nonFictionalGenreList;

String termsOfService =
    '''
Updated: 2021-07-09

General Terms:

''';

String privacyPolicy =
    '''
Updated: 2021-07-09

    ''';

