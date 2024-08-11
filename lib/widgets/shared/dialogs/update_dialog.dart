import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:zakupyapp/constants.dart';
import 'package:zakupyapp/utils/app_info.dart';
import 'package:zakupyapp/widgets/shared/snackbars.dart';

class DownloadUpdateDialog extends StatelessWidget {
  final String newVersionId;

  const DownloadUpdateDialog({super.key, required this.newVersionId});

  Future<void> _copyDownloadLinkToClipboard() async {
    await Clipboard.setData(
        const ClipboardData(text: Constants.familyStoreAppUrl));
  }

  Future<void> downloadInBrowser(BuildContext context) async {
    Navigator.of(context).pop();
    Uri uri = Uri.parse(Constants.familyStoreAppUrl);
    bool success = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
    if (!success) {
      await _copyDownloadLinkToClipboard();
      if (context.mounted) {
        showSnackBar(
          context: context,
          duration: const Duration(seconds: 8),
          content: const Text('Nie udało się otworzyć strony aplikacji w '
              'Family Store. Link do niej został skopiowany do schowka. '
              'Aby ręcznie pobrać aktualizację, wklej go do przeglądarki'),
        );
      }
    }
  }

  Future<void> copyDownloadLink(BuildContext context) async {
    await _copyDownloadLinkToClipboard();
    if (context.mounted) {
      showSnackBar(
        context: context,
        duration: const Duration(seconds: 1),
        content: const Text('Link skopiowany do schowka'),
      );
      Navigator.of(context).pop();
    }
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
          Text('Najnowsza wersja: $newVersionId'),
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
