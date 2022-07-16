import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zakupyapk/core/apprelease.dart';
import 'package:zakupyapk/utils/app_info.dart';

class DownloadUpdateDialog extends StatelessWidget {
  final AppRelease latestRelease;

  const DownloadUpdateDialog({Key? key, required this.latestRelease}) : super(key: key);

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
            // commented out - doesn't work TODO
            // launchUrl(Uri.parse(latestRelease.downloadUrl));
            Clipboard.setData(
                ClipboardData(text: latestRelease.downloadUrl));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'Link do pobrania aktualizacji skopiowany do '
                        'schowka. Wklej go do przeglądarki'),
              ),
            );

            Navigator.of(context).pop();
          },
          child: Text('Pobierz'),
        ),
      ],
    );
  }
}
