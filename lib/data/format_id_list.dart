class FormatIdList {
  // Audio Formats (M4A)
  static List<Map<String, String>> audioFormatsM4a = [
    {'format_id': '140', 'type': 'm4a', 'quality': '128k'},
  ];

// Audio Formats (WebM)
  static List<Map<String, String>> audioFormatsWebm = [
    {'format_id': '249', 'type': 'webm', 'quality': '50k'},
    {'format_id': '250', 'type': 'webm', 'quality': '70k'},
    {'format_id': '251', 'type': 'webm', 'quality': '160k'},
  ];

  // Video Formats (MP4)
  static List<Map<String, String>> videoFormatsMp4 = [
    {'format_id': '160', 'type': 'mp4', 'quality': '144p'},
    {'format_id': '133', 'type': 'mp4', 'quality': '240p'},
    {'format_id': '134', 'type': 'mp4', 'quality': '360p'},
    {'format_id': '135', 'type': 'mp4', 'quality': '480p'},
    {'format_id': '136', 'type': 'mp4', 'quality': '720p'},
    {'format_id': '137', 'type': 'mp4', 'quality': '1080p'},
  ];

// Video Formats (WebM)
  static List<Map<String, String>> videoFormatsWebm = [
    {'format_id': '248', 'type': 'webm', 'quality': '1080p', 'fps': '60fps'},
    {'format_id': '271', 'type': 'webm', 'quality': '1440p'},
    {'format_id': '313', 'type': 'webm', 'quality': '2160p'},
    {'format_id': '315', 'type': 'webm', 'quality': '2160p', 'fps': '60fps'},
    {'format_id': '272', 'type': 'webm', 'quality': '4320p'},
  ];

  // HDR Formats (MP4)
  static List<Map<String, String>> hdrFormats = [
    {'format_id': '330', 'type': 'mp4', 'quality': '2160p', 'feature': 'HDR'},
    {'format_id': '332', 'type': 'mp4', 'quality': '4320p', 'feature': 'HDR'},
  ];

  // Premium Formats
  static List<Map<String, String>> premiumFormats = [
    {'format_id': '313', 'type': 'webm', 'quality': '2160p'},
    {'format_id': '315', 'type': 'webm', 'quality': '2160p', 'fps': '60fps'},
    {'format_id': '272', 'type': 'webm', 'quality': '4320p'},
  ];
}
