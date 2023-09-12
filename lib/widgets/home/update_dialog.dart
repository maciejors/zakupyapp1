import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:zakupyapp/core/models/apprelease.dart';
import 'package:zakupyapp/utils/app_info.dart';

class DownloadUpdateDialog extends StatelessWidget {
  final AppRelease release;

  const DownloadUpdateDialog({Key? key, required this.release})
      : super(key: key);

  void downloadInBrowser(BuildContext context) async {
    Navigator.of(context).pop();
    bool success = await launchUrl(
      Uri.parse(release.downloadUrl),
      mode: LaunchMode.externalApplication,
    );
    if (!success) {
      Clipboard.setData(ClipboardData(text: release.downloadUrl));
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
          Text('Najnowsza wersja: ${release.id} '
              '(${release.getRoundedSizeMB()}MB)'),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Później'),
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
