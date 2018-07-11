import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import './flexibleAppBar.dart';

ListTile phoneTile(String phNumber) {
  return ListTile(
    title: Text(phNumber,style: TextStyle(color: Colors.red)),
    leading: Icon(Icons.call),
    dense: true,
    onTap: () => launch("tel://" + phNumber),
  );
}
phoneSeciton() {
  return 
      Column(
            children: <Widget>[
              phoneTile("9801188110"),
              phoneTile("01-5261045"),
              phoneTile("9801167223"),
              phoneTile("9801167225"),
            ],
          );
}

addressSection() {

}

emailSection() {
  var card=Column(
      children: <Widget>[ 
        emailTile("nconstructionm@gmail.com"),
        emailTile("info@nepalconstructionmart.com"),
      ]
        );
  return card;
}
ListTile emailTile(String email) {
  return ListTile(
    title: Text(email, style: TextStyle(color: Colors.blue[500]),),
    leading: Icon(Icons.email),
    dense: true,
    onTap: () => launch("mailto://" + email),
  );
}

class ContactsWidget extends StatelessWidget {
  final pageAppBarBackground =
      "http://www.nepalconstructionmart.com/wp-content/uploads/2016/11/WAL-PAPER-SCROL.jpg";
  @override
  Widget build(BuildContext context) {
    var contactChildren=[ 
      Container(
        child: Row(
        children:<Widget>[
         Expanded(child: phoneSeciton(),),
         Expanded(child: emailSection(),)],),
      )
    ];
 
    return wrapWithSilverAppBar(
          "Contact Us", contactChildren, pageAppBarBackground);
  }
}
