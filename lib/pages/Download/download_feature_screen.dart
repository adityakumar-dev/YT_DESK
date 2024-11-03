import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
            return downloadManager.downloadList.isNotEmpty
                ? _buildDownloadList(downloadManager, size)
                : Center(
                    child: Text(
                      "No downloads available",
                      style: kTextStyle(kSize18, Colors.grey, false),
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

  Widget _buildDownloadList(
      DownloadManagerProvider downloadManager, Size size) {
    return ListView.builder(
      itemCount: downloadManager.downloadList.length,
      itemBuilder: (context, index) {
        return _buildDownloadItem(context, downloadManager, index);
      },
    );
  }

  Widget _buildDownloadItem(
      BuildContext context, DownloadManagerProvider provider, int index) {
    final item = provider.downloadList[index].model;

    return Container(
      margin: EdgeInsets.symmetric(vertical: kSize11),
      padding: EdgeInsets.all(kSize16),
      decoration: kBoxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            item.title,
            style: kTextStyle(kSize16, blackColor, true),
          ),
          heightBox(kSize9),
          // Description
          Text(
            item.description,
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
                  item.isRunning
                      ? "Status: ${item.stdout}"
                      : item.isFailed == true
                          ? "Failed"
                          : "Completed",
                  style: kTextStyle(
                    kSize15,
                    item.isFailed == true
                        ? primaryRed
                        : (item.isRunning ? blackColor : deepRed),
                    false,
                  ),
                ),
              ),

              // Cancel button
              if (item.isRunning)
                IconButton(
                  icon: const Icon(Icons.close, color: primaryRed),
                  onPressed: () => provider.cancelDownload(index),
                  tooltip: 'Cancel Download',
                ),
            ],
          ),
          heightBox(kSize9),
          Text(
            "Download Path : ${item.outputPath}",
            style: kTextStyle(kSize13, lightRed, false),
          ),
        ],
      ),
    );
  }
}
