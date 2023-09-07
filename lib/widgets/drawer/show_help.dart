import 'package:flutter/material.dart';

Future<void> showHelpDialog(BuildContext context) async {
  String sep = '\n\n';
  await showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text('Pomoc'),
      content: Text.rich(
        TextSpan(
          style: TextStyle(
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
            TextSpan(text: ', kliknij w niego i przytrzymaj.$sep'),
            TextSpan(text: 'Aby '),
            TextSpan(
              text: 'dodać lub usunąć deklarację zamiaru kupna danego produktu',
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
              size: 17,
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
