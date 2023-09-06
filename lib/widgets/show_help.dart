import 'package:flutter/material.dart';

import 'package:zakupyapp/storage/storage_manager.dart';

void showHelpDialog(BuildContext context) {
  String sep = '\n\n';
  double commonSize = SM.getMainFontSize();
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text('Pomoc'),
      content: RichText(
        text: TextSpan(
          style: TextStyle(
            fontSize: commonSize,
            color: Colors.black,
          ),
          children: <InlineSpan>[
            TextSpan(text: 'Aby '),
            TextSpan(
              text: 'usunąć produkt',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: ', kliknij w niego raz.$sep'),
            TextSpan(text: 'Aby '),
            TextSpan(
              text: 'edytować dodany przez siebie produkt',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: ', kliknij w niego podwójnie.$sep'),
            TextSpan(text: 'Aby '),
            TextSpan(
              text: 'filtrować produkty po sklepie, ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: 'kliknij '),
            WidgetSpan(
                child: Icon(
              Icons.filter_alt,
              size: commonSize * 1.1,
            )),
            TextSpan(text: '.'),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            }),
      ],
    ),
  );
}
