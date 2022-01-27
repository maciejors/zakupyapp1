import 'package:flutter/material.dart';
import 'package:zakupyapk/utils/storage_manager.dart';
import 'package:zakupyapk/widgets/text_with_icon.dart';

class ShoppingListItem extends StatelessWidget {
  static List<String> allAvailableShops = [
    'Biedronka',
    'Lidl',
    'Selgros',
    'Emilka'
  ];

  final String id;
  final String name;
  final String shop;
  final String dateAddedToDisplay;
  final String whoAdded;

  final VoidCallback editFunc;
  final VoidCallback deleteFunc;

  final DateTime? deadline;
  final bool? showHourInDeadline;

  final double? mainFontSize;

  /// hero tag to be used if this widget is wrapped with a Hero widget
  final String heroTag;

  const ShoppingListItem(
      {Key? key,
      required this.id,
      required this.name,
      required this.shop,
      required this.dateAddedToDisplay,
      required this.whoAdded,
      required this.editFunc,
      required this.deleteFunc,
      this.mainFontSize,
      this.deadline,
      this.showHourInDeadline})
      : heroTag = "shoppingListItem$id",
        super(key: key);

  /// Forms a nice looking text with icon informing about the
  /// product's deadline.
  ///
  /// It assumes that [deadline] and [showHourInDeadline] are not `null`.
  Widget _formDeadlineDescription(double fontSize) {
    DateTime nowExact = DateTime.now();
    DateTime today = DateTime(
        nowExact.year, nowExact.month, nowExact.day); // now but ignoring hour
    DateTime deadlineDay = DateTime(deadline!.year, deadline!.month,
        deadline!.day); // deadline but ignoring hour
    int dayDiff = deadlineDay.difference(today).inDays;
    // setting the color
    // red if date is close (today or tomorrow)
    // grey if it's too late
    // otherwise black
    Color color = Colors.black;
    if (nowExact.isAfter(deadline!)) {
      color = Colors.grey;
    } else if (dayDiff <= 1) {
      color = Colors.red;
    }
    // setting a string description
    String description = '';
    if (dayDiff.abs() <= 2) {
      switch (dayDiff) {
        case -2:
          description = 'przedwczoraj';
          break;
        case -1:
          description = 'wczoraj';
          break;
        case 0:
          description = 'dzisiaj';
          break;
        case 1:
          description = 'jutro';
          break;
        case 2:
          description = 'pojutrze';
          break;
      }
      if (showHourInDeadline!) {
        description += ' o ${deadline!.hour}:${deadline!.minute}';
      }
    } else if (dayDiff < 0) {
      description = '$dayDiff dni temu';
    } else if (dayDiff > 0) {
      description = 'za $dayDiff dni';
    }
    description = 'Potrzebne na: $description';
    return SimpleTextWithIcon(
      text: description,
      iconData: Icons.access_time,
      color: color,
      size: fontSize,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!allAvailableShops.contains(shop) &&
        shop != '' &&
        shop != 'Przykładowy') {
      // last one is true for settings screen
      allAvailableShops.add(shop);
    }
    double mainFontSize = this.mainFontSize ?? SM.getMainFontSize();
    return Card(
      color: Colors.orange[50],
      child: InkWell(
        onTap: deleteFunc,
        onDoubleTap: editFunc,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                name,
                style: TextStyle(
                  fontSize: mainFontSize * 1.2,
                ),
              ),
              SizedBox(height: mainFontSize / 3),
              Visibility(
                visible: shop != '',
                child: SimpleTextWithIcon(
                  text: 'Sklep: $shop',
                  iconData: Icons.shopping_cart,
                  color: Colors.black,
                  fontStyle: FontStyle.italic,
                  size: mainFontSize,
                ),
              ),
              Visibility(
                visible: deadline != null,
                child: _formDeadlineDescription(mainFontSize),
              ),
              SizedBox(height: mainFontSize * 0.66),
              RichText(
                text: TextSpan(
                  style: TextStyle(fontSize: mainFontSize, color: Colors.black),
                  children: <TextSpan>[
                    TextSpan(
                      text: 'Dodane przez: ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: whoAdded,
                    ),
                  ],
                ),
              ),
              Text(
                dateAddedToDisplay,
                style: TextStyle(
                  fontSize: mainFontSize,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
