import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yt_desk/Models/download_model.dart';
import 'package:yt_desk/Providers/download_item_provider.dart';
import 'package:yt_desk/Providers/download_manager_provider.dart';
import 'package:yt_desk/UiHelper/ui_helper.dart';
import 'package:yt_desk/utils/common/common.dart';
import 'package:yt_desk/utils/constants/constants.dart';

class DownloadFeatureScreen extends StatefulWidget {
  static const String rootName = "DownloadFeatureScreen";
  const DownloadFeatureScreen({super.key});

  @override
  State<DownloadFeatureScreen> createState() => _DownloadFeatureScreenState();
}

class _DownloadFeatureScreenState extends State<DownloadFeatureScreen>
    with SingleTickerProviderStateMixin {
  late TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: downloadPageTabs.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    DownloadManagerProvider value =
        Provider.of<DownloadManagerProvider>(context);
    print(value.pausedDownloads.isNotEmpty);

    return Scaffold(
      appBar: _buildAppBar(size),
      backgroundColor: whiteColor,
      body: TabBarView(
        controller: _controller,
        children: [
          Padding(
            padding: EdgeInsets.all(kSize16),
            child: value.activeDownloads.isNotEmpty ||
                    value.pausedDownloads.isNotEmpty
                ? SingleChildScrollView(
                    child: Column(
                      children: [
                        ...List.generate(
                          value.activeDownloads.length,
                          (index) {
                            return _buildDownloadItem(
                              value.activeDownloads[index],
                              false,
                              () {
                                value.cancelDownload(index, false);
                              },
                              () {
                                value.pauseDownload(index);
                              },
                            );
                          },
                        ),
                        ...List.generate(
                          value.pausedDownloads.length,
                          (index) {
                            return _buildDownloadItem(
                              value.pausedDownloads[index],
                              true,
                              () {
                                value.cancelDownload(index, true);
                              },
                              () {
                                value.resumeDownload(index);
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  )
                : emptyDownloadMessageWidget("No Active Downloads"),
          ),
          Padding(
            padding: EdgeInsets.all(kSize16),
            child: value.pendingDownloadsQueue.isNotEmpty
                ? SingleChildScrollView(
                    child: Column(
                      children: List.generate(
                        value.pendingDownloadsQueue.length,
                        (index) {
                          return _buildPendingDownloadItem(context,
                              value.pendingDownloadsQueue[index], index, () {
                            value.cancelPendingDownload(index);
                          });
                        },
                      ),
                    ),
                  )
                : emptyDownloadMessageWidget("No Pending Downloads"),
          ),
          Padding(
            padding: EdgeInsets.all(kSize16),
            child: value.completedDownloads.isNotEmpty
                ? SingleChildScrollView(
                    child: Column(children: [
                      ...List.generate(
                        value.completedDownloads.length,
                        (index) => _buildCompletedDownloadItem(
                          value.completedDownloads[index],
                          () {
                            value.cancelCompletedDownload(index);
                          },
                        ),
                      ),
                    ]),
                  )
                : emptyDownloadMessageWidget("No Completed Downloads"),
          ),
        ],
      ),
    );
  }

  Center emptyDownloadMessageWidget(String txt) {
    return Center(
      child: Text(
        txt,
        style: kTextStyle(kSize16, mutedBlueColor, false),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(Size size) {
    return PreferredSize(
      preferredSize: Size(size.width, 140),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: kSize16, vertical: kSize16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios_new_outlined),
                  color: primaryRed,
                ),
                widthBox(kSize24),
                Text(
                  "Downloads",
                  style: kTextStyle(kSize24, primaryRed, false),
                ),
              ],
            ),
            TabBar(
              labelColor: primaryRed,
              indicatorColor: primaryRed,
              controller: _controller,
              tabs: downloadPageTabs,
              dividerColor: lightRed,
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedDownloadItem(
      DownloadItemProvider item, Function() callBack) {
    return GestureDetector(
      onTap: () async {
        // print("${item.model.outputPath}");

        String fullPath = "";
        if (Platform.isWindows) {
          fullPath = "${item.model.outputPath}\\${item.model.title}.mp4";
        } else {
          fullPath = "${item.model.outputPath}.mkv";
        }
        final Uri fileUri = Uri.file(fullPath);
        if (await canLaunchUrl(fileUri)) {
          await launchUrl(fileUri);
        } else {
          print('Could not open the video file: $fullPath');
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: kSize11),
        padding: EdgeInsets.all(kSize16),
        decoration: kBoxDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              item.model.title,
              style: kTextStyle(kSize16, blackColor, true),
            ),
            heightBox(kSize9),
            // Description
            if (item.model.description.isNotEmpty)
              Text(
                item.model.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: kTextStyle(kSize15, Colors.grey, false),
              ),
            if (item.model.description.isNotEmpty) heightBox(kSize9),
            // Download status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    item.model.isFailed == true ? "Failed" : "Completed",
                    style: kTextStyle(
                      kSize15,
                      primaryRed,
                      false,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: primaryRed),
                  onPressed: callBack,
                  tooltip: 'Delete Download',
                ),
              ],
            ),
            // heightBox(kSize9),
            Row(
              children: [
                Text(
                  "Url : ${item.model.url}",
                  style: kTextStyle(kSize13, primaryRed, false),
                ),
                widthBox(kSize16),
                copyUrlWidget(item.model.url, context)
              ],
            ),
            heightBox(kSize9),
            Text(
              "Download Path : ${item.model.outputPath}",
              style: kTextStyle(kSize13, lightRed, false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDownloadItem(DownloadItemProvider item, bool isPaused,
      Function() callBack, Function() pauseCallBack) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: kSize11),
      padding: EdgeInsets.all(kSize16),
      decoration: kBoxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            item.model.title,
            style: kTextStyle(kSize16, blackColor, true),
          ),
          heightBox(kSize9),
          // Description
          Text(
            item.model.description,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: kTextStyle(kSize15, Colors.grey, false),
          ),
          heightBox(kSize9),
          // Download status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  isPaused
                      ? "Paused"
                      : item.model.isRunning
                          ? "Status: ${item.model.stdout}"
                          : item.model.isFailed == true
                              ? "Failed"
                              : "Completed",
                  style: kTextStyle(
                    kSize15,
                    item.model.isFailed == true
                        ? primaryRed
                        : (item.model.isRunning ? blackColor : deepRed),
                    false,
                  ),
                ),
              ),

              IconButton(
                onPressed: () {
                  pauseCallBack();
                  print(pauseCallBack);
                },
                icon: Icon(isPaused ? Icons.play_arrow : Icons.pause),
              ),
              // Cancel button

              IconButton(
                icon: const Icon(Icons.close, color: primaryRed),
                onPressed: () {
                  callBack();
                  print("cancel download");
                },
                tooltip: 'Cancel Download',
              ),
            ],
          ),
          Row(
            children: [
              Text(
                "Url : ${item.model.url}",
                style: kTextStyle(kSize13, primaryRed, false),
              ),
              widthBox(kSize16),
              copyUrlWidget(item.model.url, context)
            ],
          ),
          heightBox(kSize9),
          Text(
            "Download Path : ${item.model.outputPath}",
            style: kTextStyle(kSize13, lightRed, false),
          ),
        ],
      ),
    );
  }
}

Widget _buildPendingDownloadItem(BuildContext context, DownloadItemModel model,
    int index, Function() callBack) {
  return Container(
    margin: EdgeInsets.symmetric(vertical: kSize11),
    padding: EdgeInsets.all(kSize16),
    decoration: kBoxDecoration(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          model.title,
          style: kTextStyle(kSize16, blackColor, true),
        ),
        heightBox(kSize9),
        // Description
        Text(
          model.description,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: kTextStyle(kSize15, Colors.grey, false),
        ),
        heightBox(kSize9),
        // Download status
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                "Pending",
                style: kTextStyle(
                  kSize15,
                  primaryRed,
                  false,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: primaryRed),
              onPressed: callBack,
              tooltip: 'Cancel Download',
            ),
          ],
        ),
        Row(
          children: [
            Text(
              "Url : ${model.url}",
              style: kTextStyle(kSize13, primaryRed, false),
            ),
            widthBox(kSize16),
            copyUrlWidget(model.url, context)
          ],
        ),
        heightBox(kSize9),
        Text(
          "Download Path : ${model.outputPath}",
          style: kTextStyle(kSize13, lightRed, false),
        ),
      ],
    ),
  );
}
