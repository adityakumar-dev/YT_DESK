import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yt_desk/Providers/path_manager_provider.dart';
import 'package:yt_desk/UiHelper/ui_helper.dart';
import 'package:yt_desk/pages/Download/download_feature_screen.dart';
import 'package:yt_desk/services/search_manager/search_manager.dart';
import 'package:yt_desk/utils/common/common.dart';

import '../../Providers/download_manager_provider.dart';

class SearchResultScreen extends StatefulWidget {
  static String rootName = "SearchResultScreen";
  const SearchResultScreen({super.key});

  @override
  State<SearchResultScreen> createState() => _SearchResultScreenState();
}

class _SearchResultScreenState extends State<SearchResultScreen> {
  void addDownload(
      {required String resolution,
      String title = " ",
      required String url,
      String description = " ",
      required String formatId}) {
    // Ensure the context is valid for Provider
    final downloadManager =
        Provider.of<DownloadManagerProvider>(context, listen: false);
    String path =
        Provider.of<PathManagerProvider>(context, listen: false).outputPath ??
            '';

    List<String> commandOptions;
    if (resolution.toLowerCase() == "audio only") {
      commandOptions = [
        '-f',
        'bestaudio',
        '-o',
        "$path/${getOutputFileName(title.trim())}-${DateTime.now()}.%(ext)s",
        '-N',
        '5',
        '--write-sub',
        '--sub-lang',
        'en',
        '--convert-subs',
        'srt',
        url
      ];
    } else {
      try {
        int.parse(formatId);
        commandOptions = [
          '-f',
          '$formatId + bestaudio',
          '-o',
          "$path/${getOutputFileName(title.trim())}-${DateTime.now()}.%(ext)s",
          '-N',
          '5',
          '--write-sub',
          '--sub-lang',
          'en',
          '--convert-subs',
          'srt',
          '--embed-subs',
          '--embed-thumbnail',
          url
        ];
      } catch (e) {
        if (kDebugMode) {
          print(e);
        }
        commandOptions = [
          '-f',
          formatId,
          '-o',
          "$path/${getOutputFileName(title.trim())}-${DateTime.now()}.%(ext)s",
          '-N',
          '5',
          url
        ];
      }
    }

    try {
      print(url);
      // Add the download with the constructed options
      downloadManager.addDownload(
          title, url, commandOptions, path, description);
    } catch (e) {
      // Handle any exceptions that might occur during the download process
      debugPrint("Error adding download: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: whiteColor,
      appBar: PreferredSize(
          preferredSize: Size(size.width, 70),
          child: Container(
            margin:
                EdgeInsets.symmetric(horizontal: kSize16, vertical: kSize11),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: primaryRed,
                    size: kSize36,
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
                    Navigator.pop(context);
                  },
                ),
                widthBox(kSize24),
                Text(
                  "Search Result",
                  style: kTextStyle(kSize24, primaryRed, false),
                )
              ],
            ),
          )),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: kSize22, vertical: kSize24),
        child: size.width > 1200
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: thumbnailSectionWidget(size)),
                  SizedBox(width: kSize16),
                  Expanded(
                      child: downloadSectionWidget(
                          size)), // Second section for download
                ],
              )
            : SingleChildScrollView(
                child: Column(
                  children: [
                    thumbnailSectionWidget(Size(size.width, size.height * 0.7)),
                    heightBox(kSize16),
                    downloadSectionWidget(
                      Size(size.width * 2, size.height),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget thumbnailSectionWidget(Size size) {
    return Container(
      height: size.height - size.height * 0.1 - 10,
      padding: EdgeInsets.symmetric(horizontal: kSize11, vertical: kSize24),
      decoration: kBoxDecoration(),
      alignment: Alignment.center,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 700,
              padding:
                  EdgeInsets.symmetric(horizontal: kSize16, vertical: kSize16),
              decoration: kBoxDecoration(),
              child: Image.network(
                SearchManager.thumbnailUrl,
                alignment: Alignment.center,
                fit: BoxFit.cover,
              ),
            ),
            heightBox(kSize16),
            Text(
              SearchManager.title,
              style: kTextStyle(kSize16, blackColor, true),
              textAlign: TextAlign.center,
            ),
            heightBox(kSize16),
            Text(
              SearchManager.description,
              overflow: TextOverflow.visible,
              style: kTextStyle(kSize13, blackColor, false),
            ),
          ],
        ),
      ),
    );
  }

  Widget downloadSectionWidget(Size size) {
    return Container(
      // Customize your download section here
      height: size.height,
      padding: EdgeInsets.symmetric(horizontal: kSize16, vertical: kSize16),

      decoration: kBoxDecoration(),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding:
                  EdgeInsets.symmetric(horizontal: kSize16, vertical: kSize16),
              decoration: kBoxDecoration(),
              child: Text(
                "Download Options",
                style: kTextStyle(kSize18, blackColor, true),
              ),
            ),
            Column(
              children: [
                heightBox(kSize16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        "Resolution",
                        textAlign: TextAlign.center,
                        style: kTextStyle(kSize16, blackColor, true),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        "Id",
                        textAlign: TextAlign.center,
                        style: kTextStyle(kSize16, blackColor, true),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        "Quality",
                        textAlign: TextAlign.center,
                        style: kTextStyle(kSize16, blackColor, true),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        "Extension",
                        textAlign: TextAlign.center,
                        style: kTextStyle(kSize16, blackColor, true),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        "Size",
                        textAlign: TextAlign.center,
                        style: kTextStyle(kSize16, blackColor, true),
                      ),
                    ),
                    const Expanded(
                      flex: 1,
                      child: SizedBox(),
                    ),
                  ],
                ),
                ...List<Widget>.generate(
                  SearchManager.mediaDetails.length,
                  (index) {
                    return downloadItemUi(size, index);
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Container downloadItemUi(Size size, int index) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: kSize11),
      padding: EdgeInsets.symmetric(vertical: kSize11, horizontal: kSize16),
      decoration: kBoxDecoration(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              SearchManager.mediaDetails[index]['resolution'].toUpperCase(),
              textAlign: TextAlign.center,
              style: kTextStyle(kSize13, mutedBlueColor, false),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              SearchManager.mediaDetails[index]['formatId'].toUpperCase(),
              textAlign: TextAlign.center,
              style: kTextStyle(kSize13, mutedBlueColor, false),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              SearchManager.mediaDetails[index]['quality'].toUpperCase(),
              textAlign: TextAlign.center,
              style: kTextStyle(kSize13, mutedBlueColor, false),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              SearchManager.mediaDetails[index]['extension'].toUpperCase(),
              textAlign: TextAlign.center,
              style: kTextStyle(kSize13, mutedBlueColor, false),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              SearchManager.mediaDetails[index]['size'],
              textAlign: TextAlign.center,
              style: kTextStyle(kSize13, mutedBlueColor, false),
            ),
          ),
          Flexible(
            flex: 1,
            child: IconButton(
              onPressed: () {
                print(SearchManager.publicUrl);
                addDownload(
                  resolution: SearchManager.mediaDetails[index]['resolution'],
                  title: SearchManager.title,
                  url: SearchManager.publicUrl,
                  description: SearchManager.description,
                  formatId: SearchManager.mediaDetails[index]['formatId'],
                );
                print(
                    "${SearchManager.mediaDetails[index]['resolution']}, ${SearchManager.title}, ${SearchManager.publicUrl} , ${SearchManager.description ?? ""}, ${SearchManager.mediaDetails[index]['formatId']}");
                ScaffoldMessenger.of(context)
                  ..hideCurrentMaterialBanner()
                  ..showMaterialBanner(
                    MaterialBanner(
                      dividerColor: lightRed,
                      backgroundColor: whiteColor,
                      content: Text(
                        "Download Starting...",
                        style: kTextStyle(kSize24, blackColor, false),
                      ),
                      actions: [
                        GestureDetector(
                          onTap: () {
                            ScaffoldMessenger.of(context)
                                .hideCurrentMaterialBanner();
                            Navigator.pushNamed(
                                context, DownloadFeatureScreen.rootName);
                          },
                          child: Text(
                            "View",
                            style: kTextStyle(kSize28, primaryRed, false),
                          ),
                        )
                      ],
                    ),
                  );
                Future.delayed(const Duration(milliseconds: 3000), () {
                  ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
                });
              },
              icon: const Icon(
                Icons.download,
                color: primaryRed,
              ),
              alignment: Alignment.centerRight,
            ),
          ),
        ],
      ),
    );
  }
}
