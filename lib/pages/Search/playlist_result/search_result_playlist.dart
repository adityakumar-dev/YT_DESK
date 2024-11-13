import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yt_desk/UiHelper/ui_helper.dart';
import 'package:yt_desk/services/search_manager/search_manager.dart';
import 'package:yt_desk/utils/common/common.dart';

class SearchResultPlaylist extends StatefulWidget {
  static const rootName = "SearchResultPlaylist";
  const SearchResultPlaylist({super.key});

  @override
  State<SearchResultPlaylist> createState() => _SearchResultPlaylistState();
}

class _SearchResultPlaylistState extends State<SearchResultPlaylist> {
  List<bool> selectedVideos = [];
  bool thumnailInitDone = false;
  @override
  void initState() {
    super.initState();
    selectedVideos =
        List<bool>.filled(SearchManager.playlistEntries.length, true);
    fetchThumbnails();
  }

  void addToDownloadList(int index) {
    if (selectedVideos[index]) {
      print("Added video: ${SearchManager.playlistEntries[index]['title']}");
    } else {
      print("Removed video: ${SearchManager.playlistEntries[index]['title']}");
    }
  }

  Future<void> fetchThumbnails() async {
    if (!thumnailInitDone) {
      try {
        // Fetch thumbnails for all playlist entries concurrently
        await Future.wait(SearchManager.playlistEntries.map((video) async {
          final url = video['url'];
          await SearchManager.searchPlaylistThumnailUrl(url);
        }));
        setState(() {
          thumnailInitDone =
              true; // Update state after all thumbnails are loaded
        });
      } catch (e) {
        if (kDebugMode) {
          print("Error loading thumbnails: $e");
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
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
                  "Playlist Videos",
                  style: kTextStyle(kSize24, primaryRed, false),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    setState(() {
                      selectedVideos = List<bool>.filled(
                          SearchManager.playlistEntries.length, true);
                    });
                  },
                  child: Text(
                    "Select All",
                    style: kTextStyle(kSize16, primaryRed, false),
                  ),
                ),
                widthBox(kSize22)
              ],
            ),
          )),
      bottomNavigationBar: Container(
        height: kSize70,
        decoration: kBoxDecoration(),
        padding: EdgeInsets.symmetric(horizontal: kSize22, vertical: kSize5),
        child: Row(
          children: [
            Text(
              "Select your desired videos to download, then press 'Download' to proceed.",
              style: kTextStyle(kSize16, primaryRed, false),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryRed,
                padding: EdgeInsets.symmetric(
                    horizontal: kSize18, vertical: kSize11),
              ),
              onPressed: () {
                int trueCount = 0;
                selectedVideos.forEach((el) {
                  if (el) {
                    trueCount++;
                  }
                });
                if (trueCount != 0) {
                  handlePlaylistDownload(context, selectedVideos);
                } else {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(
                        backgroundColor: whiteColor,
                        content: Text(
                          "Please select the playlist Video ",
                          style: kTextStyle(kSize16, primaryRed, false),
                        ),
                      ),
                    );
                }
              },
              child: Text(
                "Download",
                style: kTextStyle(kSize22, whiteColor, false),
              ),
            )
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: ListView.builder(
          itemCount: SearchManager.playlistEntries.length,
          itemBuilder: (context, index) {
            final video = SearchManager.playlistEntries[index];

            return Container(
              padding: EdgeInsets.symmetric(
                horizontal: kSize22,
              ),
              margin: EdgeInsets.symmetric(vertical: kSize5),
              decoration: kBoxDecoration(),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                onTap: () async {
                  try {
                    launchUrl(
                      Uri.parse(video['url']),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(
                          backgroundColor: whiteColor,
                          content: Text(
                            "Error failed to open in browser",
                            style: kTextStyle(kSize16, primaryRed, false),
                          ),
                        ),
                      );
                  }
                },
                leading: (SearchManager.playListThumnail.isNotEmpty &&
                        SearchManager.playListThumnail.length > index)
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(kSize9),
                        child: GestureDetector(
                          onTap: () {
                            showThumbnailDailogWidget(
                                context,
                                '${video['title'] ?? "No Title"}',
                                SearchManager.playListThumnail[index]);
                          },
                          child: Image.network(
                            SearchManager.playListThumnail[index],
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.error,
                                color: primaryRed,
                                size: kSize36,
                              );
                            },
                          ),
                        ),
                      )
                    : const Icon(
                        Icons.video_library,
                        color: primaryRed,
                      ),
                title: Row(
                  children: [
                    widthBox(kSize30),
                    Text(
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      video['title'] ?? 'No Title',
                      style: kTextStyle(kSize16, primaryRed, false),
                    ),
                  ],
                ),
                subtitle: Row(
                  children: [
                    widthBox(kSize30),
                    Text(
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        video['url'] ?? 'No URL'),
                    widthBox(kSize5),
                    video['url'] != null
                        ? copyUrlWidget(video['url'], context)
                        : const SizedBox.shrink(),
                    widthBox(kSize11),
                    Text("${video['duration']}")
                  ],
                ),
                trailing: CheckboxTheme(
                  data: const CheckboxThemeData(
                    side: BorderSide(color: Colors.grey, width: 2),
                  ),
                  child: Checkbox(
                    activeColor: primaryRed,
                    value: selectedVideos[index],
                    onChanged: (bool? isSelected) {
                      if (isSelected == null) return;
                      setState(() {
                        selectedVideos[index] = isSelected;
                      });
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
