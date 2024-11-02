import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yt_desk/Providers/download_manager_provider.dart';
import 'package:yt_desk/UiHelper/ui_helper.dart'; // Assuming this contains your theme, styles, and common widgets.
import 'package:yt_desk/services/search_manager/search_manager.dart'; // Assuming this manages your media data.

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
      appBar: PreferredSize(
          preferredSize: Size(size.width, 70),
          child: Container(
            margin:
                EdgeInsets.symmetric(horizontal: kSize16, vertical: kSize16),
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
          )),
      backgroundColor: whiteColor,
      body: Padding(
        padding: EdgeInsets.all(kSize16),
        child: Column(
          children: [
            // Search bar at the top
            // Container(
            //   margin: EdgeInsets.only(bottom: kSize16),
            //   padding: EdgeInsets.symmetric(horizontal: kSize16),
            //   decoration: BoxDecoration(
            //     color: Colors.white,
            //     borderRadius: BorderRadius.circular(kSize9),
            //     boxShadow: [
            //       BoxShadow(color: Colors.grey.shade300, blurRadius: 5)
            //     ],
            //   ),
            //   child: Row(
            //     children: [
            //       const Icon(Icons.search, color: Colors.grey),
            //       Expanded(
            //         child: TextField(
            //           decoration: InputDecoration(
            //             hintText: 'Search for media...',
            //             border: InputBorder.none,
            //             contentPadding: EdgeInsets.symmetric(vertical: kSize13),
            //           ),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            // Download items list
            Expanded(
              child: ListView.builder(
                itemCount: Provider.of<DownloadManagerProvider>(context)
                    .downloadList
                    .length,
                itemBuilder: (context, index) {
                  return downloadItemUi(context, size, index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget for each download item
  Widget downloadItemUi(BuildContext context, Size size, int index) {
    final proivder = Provider.of<DownloadManagerProvider>(context);
    final item = proivder.downloadList[index].model;
    return Container(
      margin: EdgeInsets.symmetric(vertical: kSize11),
      padding: EdgeInsets.all(kSize16),
      decoration: kBoxDecoration(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                proivder.downloadList[index].model.title,
                style: kTextStyle(kSize16, blackColor, true),
              ),
              SizedBox(height: kSize9),
              Text(
                proivder.downloadList[index].model.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: kTextStyle(kSize16, blackColor, true),
              ),
              SizedBox(height: kSize9),
              Visibility(
                visible: item.isRunning,
                child: Text(
                  "Status : ${item.stdout}",
                  style: kTextStyle(kSize16, blackColor, false),
                ),
              ),
              Visibility(
                visible: !item.isRunning,
                child: Text(
                  item.isFailed == true ? "Failed" : "Completed",
                  style: kTextStyle(kSize16,
                      item.isFailed == false ? deepRed : primaryRed, false),
                ),
              )
            ],
          ),
          Visibility(
            visible: item.isRunning,
            child: IconButton(
              icon: const Icon(Icons.close, color: primaryRed),
              onPressed: item.isRunning
                  ? () {
                      proivder.cancelDownload(index);
                    }
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
