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
          appBar: AppBar(title: Text('Download Manager')),
          body: ListView.builder(
            itemCount: downloadProvider.processes.length,
            itemBuilder: (context, index) {
              final data = downloadProvider.processes[index];
              return ListTile(
                title: Text(data.title),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StreamBuilder<double>(
                      stream: data.progressStream,
                      builder: (context, snapshot) {
                        final progress = snapshot.data ?? 0.0;
                        return Text(
                            'Progress: ${progress.toStringAsFixed(2)}%');
                      },
                    ),
                    Text('Stdout: ${data.stdout}'),
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
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.cancel),
                  onPressed: () {
                    downloadProvider.cancelDownload(index);
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}
