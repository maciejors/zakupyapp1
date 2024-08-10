import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:zakupyapp/constants.dart';
import 'package:zakupyapp/utils/app_info.dart';

class DownloadUpdateDialog extends StatelessWidget {
  final String newVersionId;

  const DownloadUpdateDialog({Key? key, required this.newVersionId})
      : super(key: key);

  Future<void> _copyDownloadLinkToClipboard() async {
    await Clipboard.setData(
        ClipboardData(text: Constants.FAMILY_STORE_APP_URL));
  }

  Future<void> downloadInBrowser(BuildContext context) async {
    Navigator.of(context).pop();
    Uri uri = Uri.parse(Constants.FAMILY_STORE_APP_URL);
    bool success = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
    if (!success) {
      await _copyDownloadLinkToClipboard();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 8),
          content: const Text('Nie udało się otworzyć strony aplikacji w '
              'Family Store. Link do niej został skopiowany do schowka. '
              'Aby ręcznie pobrać aktualizację, wklej go do przeglądarki'),
        ),
      );
    }
  }

  Future<void> copyDownloadLink(BuildContext context) async {
    await _copyDownloadLinkToClipboard();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: Durations.extralong4,
        content: const Text('Link skopiowany do schowka'),
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Dostępna aktualizacja'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Twoja wersja: ${AppInfo.getVersion()}'),
          Text('Najnowsza wersja: ${newVersionId}'),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Później'),
        ),
        TextButton(
          onPressed: () => copyDownloadLink(context),
          child: const Text('Skopiuj link'),
        ),
        TextButton(
          onPressed: () => downloadInBrowser(context),
          child: const Text('Pobierz'),
        ),
      ],
    );
  }
}
