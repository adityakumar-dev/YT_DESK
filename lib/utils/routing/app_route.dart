import 'package:yt_desk/pages/Download/download_feature_screen.dart';
import 'package:yt_desk/pages/Home/home_option_screen.dart';
import 'package:yt_desk/pages/Search/search_result_playlist.dart';
import 'package:yt_desk/pages/Search/search_result_screen.dart';
import 'package:yt_desk/pages/Splash/splash_screen.dart';

var appRoutes = {
  SplashScreen.rootName: (context) => const SplashScreen(),
  HomeOptionScreen.rootName: (context) => const HomeOptionScreen(),
  SearchResultScreen.rootName: (context) => const SearchResultScreen(),
  SearchResultPlaylist.rootName: (context) => const SearchResultPlaylist(),
  DownloadFeatureScreen.rootName: (context) => const DownloadFeatureScreen(),
};
