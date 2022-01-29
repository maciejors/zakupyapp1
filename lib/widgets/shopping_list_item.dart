import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zakupyapk/utils/storage_manager.dart';
import 'package:zakupyapk/utils/urgency.dart';
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

  /// Returns an urgency based on product's deadline.
  Urgency? getUrgency() {
    if (deadline == null) {
      return null;
    }
    DateTime nowExact = DateTime.now();
    DateTime today = DateTime(
        nowExact.year, nowExact.month, nowExact.day); // now but ignoring hour
    DateTime deadlineDay = DateTime(deadline!.year, deadline!.month,
        deadline!.day); // deadline but ignoring hour
    int dayDiff = deadlineDay.difference(today).inDays;
    Urgency result = Urgency.not_urgent;
    if (nowExact.isAfter(deadline!)) {
      if (today.isAtSameMomentAs(deadlineDay) && !showHourInDeadline!) {
        result = Urgency.urgent;
      }
      else {
        result = Urgency.too_late;
      }
    }
    else if (dayDiff <= 1) {
      result = Urgency.urgent;
    }
    return result;
  }

  /// Forms a nice looking text with icon informing about the
  /// product's deadline.
  ///
  /// It assumes that [deadline] and [showHourInDeadline] are not `null`.
  Widget _formDeadlineDescription(double fontSize) {
    if (deadline == null) {
      return Container();
    }
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
    Color color;
    Urgency urgency = getUrgency()!;
    switch (urgency) {
      case Urgency.too_late:
        color = Colors.grey;
        break;
      case Urgency.urgent:
        color = Colors.red;
        break;
      case Urgency.not_urgent:
        color = Colors.black;
        break;
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
        description += ' o ${deadline!.hour}:'
            '${deadline!.minute.toString().padLeft(2, '0')}';
      }
    }
    else if (dayDiff < 0) {
      description = '$dayDiff dni temu';
    }
    else if (dayDiff > 0) {
      description = 'za $dayDiff dni';
    }
    description = 'Potrzebne na: $description';
    return SimpleTextWithIcon(
      text: description,
      iconData: Icons.access_time,
      color: color,
      size: fontSize,
      fontStyle: FontStyle.italic,
    );
  }

  /// Map does not contain ID of the product
  Map<String, dynamic> toMap() {
    Map<String, dynamic> result = {
      'name': name,
      'dateAddedToDisplay': dateAddedToDisplay,
      'shop': shop,
      'whoAdded': whoAdded,
    };
    if (deadline != null) {
      result['deadline'] = deadline.toString();
      result['showHourInDeadline'] = showHourInDeadline!;
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    // adding custom shops
    if (!allAvailableShops.contains(shop) &&
        shop != '' &&
        // true for settings screen
        shop != 'Przykładowy') {
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
                child: SizedBox(height: mainFontSize * 0.1),
              ),
              Visibility(
                visible: deadline != null,
                child: _formDeadlineDescription(mainFontSize),
              ),
              SizedBox(height: mainFontSize * 0.33),
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
