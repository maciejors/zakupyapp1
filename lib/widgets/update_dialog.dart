import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:zakupyapp/core/apprelease.dart';
import 'package:zakupyapp/utils/app_info.dart';

class DownloadUpdateDialog extends StatelessWidget {
  final AppRelease latestRelease;

  const DownloadUpdateDialog({Key? key, required this.latestRelease})
      : super(key: key);

  void copyDownloadUrl(BuildContext context) {
    Navigator.of(context).pop();
    Clipboard.setData(ClipboardData(text: latestRelease.downloadUrl));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Link do pobrania aktualizacji skopiowany do schowka.'),
      ),
    );
  }

  void downloadInBrowser(BuildContext context) async {
    Navigator.of(context).pop();
    bool success = await launchUrl(
      Uri.parse(latestRelease.downloadUrl),
      mode: LaunchMode.externalApplication,
    );
    if (!success) {
      Clipboard.setData(ClipboardData(text: latestRelease.downloadUrl));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(seconds: 8),
          content: Text('Nie udało się rozpocząć pobierania. '
              'Link do pobrania aktualizacji został skopiowany do schowka. '
              'Aby ręcznie pobrać aktualizację, wklej go do przeglądarki'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Dostępna aktualizacja'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Twoja wersja: ${AppInfo.getVersion()}'),
          Text('Najnowsza wersja: ${latestRelease.id} '
              '(${latestRelease.getRoundedSizeMB()}MB)'),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Anuluj'),
        ),
        TextButton(
          onPressed: () {
            copyDownloadUrl(context);
          },
          child: Text('Skopiuj link'),
        ),
        TextButton(
          onPressed: () {
            downloadInBrowser(context);
          },
          child: Text('Pobierz'),
        ),
      ],
    );
  }
}
