import 'package:flutter/material.dart';
import 'package:zakupyapp/widgets/shared/dismissible_help_dialog.dart';

class HelpDialog extends StatelessWidget {
  const HelpDialog({super.key});

  @override
  Widget build(BuildContext context) {
    String sep = '\n\n';
    return DismissibleHelpDialog(
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
            TextSpan(
              text: ', kliknij w niego podwójnie. Dzięki temu inni użytkownicy '
                  'będą wiedzieć, że planujesz kupić ten produkt.$sep',
            ),
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
            TextSpan(text: ' na górze ekranu.$sep'),
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
          ],
        ),
      ),
    );
  }
}
