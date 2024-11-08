import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yt_desk/Models/download_model.dart';
import 'package:yt_desk/Providers/download_item_provider.dart';
import 'package:yt_desk/Providers/download_manager_provider.dart';
import 'package:yt_desk/UiHelper/ui_helper.dart';

class DownloadFeatureScreen extends StatefulWidget {
  static const String rootName = "DownloadFeatureScreen";
  const DownloadFeatureScreen({super.key});

  @override
  State<DownloadFeatureScreen> createState() => _DownloadFeatureScreenState();
}

class _DownloadFeatureScreenState extends State<DownloadFeatureScreen> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: _buildAppBar(size),
      backgroundColor: whiteColor,
      body: Padding(
        padding: EdgeInsets.all(kSize16),
        child: Consumer<DownloadManagerProvider>(
          builder: (context, downloadManager, child) {
            return downloadManager.activeDownloads.isEmpty &&
                    downloadManager.pendingDownloadsQueue.isEmpty &&
                    downloadManager.completedDownloads.isEmpty
                ? Center(
                    child: Text(
                      "Downloads is empty",
                      style: kTextStyle(kSize16, mutedBlueColor, false),
                    ),
                  )
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        //Running active downloads
                        ...List.generate(
                          downloadManager.activeDownloads.length,
                          (index) {
                            return _buildDownloadItem(
                              downloadManager.activeDownloads[index],
                              () {
                                downloadManager.cancelDownload(index);
                              },
                            );
                          },
                        ),
                        //Pending downloads

                        ...List.generate(
                          downloadManager.pendingDownloadsQueue.length,
                          (index) {
                            return _buildPendingDownloadItem(
                                downloadManager.pendingDownloadsQueue[index],
                                index, () {
                              downloadManager.cancelPendingDownload(index);
                            });
                          },
                        ),
                        //Completed downloads

                        ...List.generate(
                          downloadManager.completedDownloads.length,
                          (index) => _buildCompletedDownloadItem(
                            downloadManager.completedDownloads[index],
                            () {
                              downloadManager.cancelCompletedDownload(index);
                            },
                          ),
                        )
                      ],
                    ),
                  );
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(Size size) {
    return PreferredSize(
      preferredSize: Size(size.width, 70),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: kSize16, vertical: kSize16),
        child: Row(
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
      ),
    );
  }

  Widget _buildCompletedDownloadItem(
      DownloadItemProvider item, Function() callBack) {
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
          if (item.model.description.isNotEmpty)
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
                  item.model.isFailed == true ? "Failed" : "Completed",
                  style: kTextStyle(
                    kSize15,
                    primaryRed,
                    false,
                  ),
                ),
              ),

              // Cancel button

              IconButton(
                icon: const Icon(Icons.delete, color: primaryRed),
                onPressed: callBack,
                tooltip: 'Delete Download',
              ),
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

  Widget _buildDownloadItem(DownloadItemProvider item, Function() callBack) {
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
                  item.model.isRunning
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

              // Cancel button
              if (item.model.isRunning)
                IconButton(
                  icon: const Icon(Icons.close, color: primaryRed),
                  onPressed: callBack,
                  tooltip: 'Cancel Download',
                ),
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

Widget _buildPendingDownloadItem(
    DownloadItemModel model, int index, Function() callBack) {
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
        heightBox(kSize9),
        Text(
          "Download Path : ${model.outputPath}",
          style: kTextStyle(kSize13, lightRed, false),
        ),
      ],
    ),
  );
}
