import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:yt_desk/Providers/path_manager_provider.dart';
import 'package:yt_desk/UiHelper/ui_helper.dart';
import 'package:yt_desk/pages/Download/download_feature_screen.dart';
import 'package:yt_desk/pages/Search/search_result_screen.dart';
import 'package:yt_desk/services/path_manager/path_manager.dart';
import 'package:yt_desk/services/search_manager/search_manager.dart';

class HomeOptionScreen extends StatefulWidget {
  static const String rootName = "HomeOptionsScreen";
  const HomeOptionScreen({super.key});

  @override
  State<HomeOptionScreen> createState() => _HomeOptionScreenState();
}

class _HomeOptionScreenState extends State<HomeOptionScreen> {
  bool btnActive = false;
  TextEditingController urlController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pathProvider =
        Provider.of<PathManagerProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      pathProvider.init();
    });

    return Scaffold(
      backgroundColor: whiteColor,
      appBar: PreferredSize(
        preferredSize: Size(size.width, 120),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: kSize16, vertical: kSize11),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () => Navigator.pushNamed(
                    context, DownloadFeatureScreen.rootName),
                icon: Icon(
                  Icons.download,
                  size: kSize36,
                  color: primaryRed,
                ),
              ),
              widthBox(kSize50),
              IconButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) => StatefulBuilder(
                            builder: (context, setState) => AlertDialog(
                              shadowColor: deepRed,
                              backgroundColor: whiteColor,
                              title: Text(
                                "Settings",
                                style: kTextStyle(kSize24, primaryRed, false),
                              ),
                              content: Container(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Output Directory ",
                                      style:
                                          kTextStyle(kSize16, blackColor, true),
                                    ),
                                    heightBox(kSize16),
                                    Consumer<PathManagerProvider>(
                                        builder: (_, value, __) => Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: kSize16,
                                                      vertical: kSize16),
                                                  decoration: kBoxDecoration(),
                                                  child: Text(
                                                    value.outputPath ??
                                                        'Please Choose Download Directory',
                                                    style: kTextStyle(kSize16,
                                                        mutedBlueColor, false),
                                                  ),
                                                ),
                                                widthBox(kSize24),
                                                IconButton(
                                                    onPressed: () async {
                                                      await value.changePath();
                                                    },
                                                    icon: Icon(
                                                      Icons.folder,
                                                      color: deepRed,
                                                      size: kSize36,
                                                    ))
                                              ],
                                            ))
                                  ],
                                ),
                              ),
                            ),
                          ));
                },
                icon: Icon(
                  Icons.settings,
                  size: kSize36,
                  color: primaryRed,
                ),
              ),
              widthBox(kSize11)
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: size.height - size.height * 0.2,
          margin: EdgeInsets.symmetric(
              vertical: size.height * 0.05, horizontal: size.width * 0.05),
          decoration: kBoxDecoration(),
          padding: EdgeInsets.symmetric(
              vertical: size.height * 0.05, horizontal: size.width * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: size.height * 0.05),
              getBanner(),
              SizedBox(height: kSize42),
              Text(
                "Paste Social Media Link Here",
                style: kTextStyle(kSize24, darkGrayColor, true),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: kSize13),
              Text(
                "Easily download videos or audio from any social media platform",
                style: kTextStyle(kSize16, Colors.grey.shade600, false),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: kSize42),
              TextField(
                controller: urlController,
                style: TextStyle(color: deepRed),
                decoration:
                    getInputDecoration("Enter Social Media Link").copyWith(
                  prefixIcon: Icon(Icons.link, color: deepRed),
                ),
              ),
              SizedBox(height: kSize42),
              GestureDetector(
                onTap: () async {
                  setState(() {
                    btnActive = true;
                  });
                  Future.delayed(
                    const Duration(milliseconds: 100),
                    () {
                      setState(() {
                        btnActive = false;
                      });
                    },
                  );
                  showDialog(
                    context: context,
                    builder: (context) => Material(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(kSize18),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Lottie.asset('assets/lottie/progress.json'),
                              heightBox(kSize18),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Searching media...",
                                    style:
                                        kTextStyle(kSize24, whiteColor, true),
                                  ),
                                  widthBox(kSize22),
                                  CircularProgressIndicator(
                                    color: whiteColor,
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                  await SearchManager.search(urlController.text);
                  Navigator.pop(context);
                  Navigator.pushNamed(context, SearchResultScreen.rootName);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  decoration: BoxDecoration(
                    color: btnActive ? deepRed.withOpacity(0.8) : primaryRed,
                    borderRadius: BorderRadius.circular(kSize16),
                    boxShadow: [
                      BoxShadow(
                        color: primaryRed.withOpacity(0.4),
                        blurRadius: btnActive ? 5 : 15,
                        offset: Offset(0, btnActive ? 3 : 5),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.symmetric(
                      vertical: kSize18, horizontal: kSize42),
                  child: Center(
                    child: Text(
                      "Search Media",
                      style: kTextStyle(kSize18, whiteColor, true),
                    ),
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.1),
            ],
          ),
        ),
      ),
    );
  }
}
