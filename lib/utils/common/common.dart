import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:yt_desk/Providers/download_manager_provider.dart';
import 'package:yt_desk/Providers/path_manager_provider.dart';
import 'package:yt_desk/UiHelper/ui_helper.dart';
import 'package:yt_desk/pages/Download/download_feature_screen.dart';
import 'package:yt_desk/services/search_manager/search_manager.dart';

String getOutputFileName(String name) {
  if (Platform.isLinux) {
    String newString = '';
    for (int i = 0; i < name.length; i++) {
      if (name[i] == ' ') {
        newString += '_';
      } else {
        newString += name[i];
      }
    }
    return newString;
  } else {
    return name;
  }
}

handlePlaylistDownload(BuildContext context, List<bool> isChecked) {
  DownloadManagerProvider provider =
      Provider.of<DownloadManagerProvider>(context, listen: false);

  final PathManagerProvider path =
      Provider.of<PathManagerProvider>(context, listen: false);
  if (path.outputPath == null) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            "Please choose Correct path for download directory",
            style: kTextStyle(kSize16, primaryRed, false),
          ),
        ),
      );
    return;
  }
  final el = SearchManager.playlistEntries;
  for (int i = 0; i < el.length; i++) {
    if (isChecked[i]) {
      String outputPath = "";
      if (Platform.isWindows) {
        outputPath =
            "${path.outputPath}\\${getOutputFileName(el[i]['title'].trim())}-${DateTime.now().toString().split(" ")[1]}";
      } else {
        outputPath =
            "${path.outputPath}/${getOutputFileName(el[i]['title'].trim())}-${DateTime.now().toString().split(" ")[1]}";
      }
      provider.addDownload(
          el[i]['title'],
          el[i]['url'],
          [
            '-f',
            'bestvideo + bestaudio',
            '-o',
            "$outputPath.%(ext)s",
            '-N',
            '5',
            '--write-sub',
            '--sub-lang',
            'en',
            '--convert-subs',
            'srt',
            '--embed-subs',
            el[i]['url']
          ],
          outputPath,
          '');
    }
  }

  Navigator.pushNamed(context, DownloadFeatureScreen.rootName);
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        backgroundColor: whiteColor,
        content: Text(
          "Download added successfully",
          style: kTextStyle(kSize16, primaryRed, false),
        ),
      ),
    );
}

IconButton copyUrlWidget(String url, BuildContext context) {
  return IconButton(
    onPressed: () {
      Clipboard.setData(ClipboardData(text: url));
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            backgroundColor: whiteColor,
            showCloseIcon: true,
            closeIconColor: primaryRed,
            content: Text(
              "$url copied to clipboard successfully",
              style: kTextStyle(kSize16, primaryRed, false),
            ),
          ),
        );
    },
    icon: Icon(
      Icons.copy,
      color: mutedBlueColor,
      size: kSize22,
    ),
  );
}

Future<dynamic> showThumbnailDailogWidget(
    BuildContext context, String title, String url) {
  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: whiteColor,
      title: Row(
        children: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.close,
              size: kSize30,
              color: primaryRed,
            ),
          ),
          widthBox(kSize22),
          Text(title),
        ],
      ),
      content: Container(
        decoration: kBoxDecoration(),
        padding: EdgeInsets.symmetric(horizontal: kSize5, vertical: kSize5),
        child: Image.network(url),
      ),
    ),
  );
}
