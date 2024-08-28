import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yt_desk/services/download_manager.dart';

class DownloadScreen extends StatelessWidget {
  const DownloadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DownloadManager>(
      builder: (context, downloadProvider, child) {
        return Scaffold(
          appBar: AppBar(title: const Text('Download Manager')),
          body: ListView.builder(
            itemCount: downloadProvider.processes.length,
            itemBuilder: (context, index) {
              final data = downloadProvider.processes[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white12),
                child: ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        data.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Visibility(
                        visible: data.isCompleted,
                        child: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            downloadProvider.cancelDownload(index);
                            downloadProvider.removeDownload(index);
                          },
                        ),
                      ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Visibility(
                          visible: !data.isCompleted,
                          child: Text('Stdout: ${data.stdout}')),
                      if (data.isFailed ?? false)
                        const Text(
                          'Failed',
                          style: TextStyle(color: Colors.red),
                        ),
                      if (data.isCompleted)
                        const Text(
                          'Completed',
                          style: TextStyle(color: Colors.green),
                        ),
                      Text(
                        "Path : ${data.outputPath}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.lightBlue,
                        ),
                      ),
                    ],
                  ),
                  trailing: Visibility(
                    visible: !data.isCompleted,
                    child: IconButton(
                      icon: const Icon(Icons.cancel),
                      onPressed: () {
                        downloadProvider.cancelDownload(index);
                        data.deleteFile();
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
