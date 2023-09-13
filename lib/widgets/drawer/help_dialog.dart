import 'package:flutter/material.dart';

class HelpDialog extends StatelessWidget {
  const HelpDialog({super.key});

  @override
  Widget build(BuildContext context) {
    String sep = '\n\n';
    return AlertDialog(
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
            TextSpan(text: '.$sep'),
            TextSpan(text: 'Aby '),
            TextSpan(
              text: 'wyświetlić tylko produkty które chcesz kupić, ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: 'kliknij '),
            WidgetSpan(
                child: Icon(
              Icons.shopping_cart_checkout,
              size: 17,
            )),
            TextSpan(text: ' na górze ekranu.'),
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
    );
  }
}
