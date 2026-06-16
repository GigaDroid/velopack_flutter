import 'package:flutter/material.dart';
import 'package:velopack_flutter/velopack_flutter.dart';

Future<void> main(List<String> args) async {
  await initializeVelopack(url: 'http://localhost/releases');
  runApp(const MyApp());
}

class Updater extends StatefulWidget {
  const Updater({super.key});

  @override
  State<Updater> createState() => _UpdaterState();
}

class _UpdaterState extends State<Updater> {
  late Stream<int> progressStream = Stream.value(0);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 24,
      children: [
        Card(
          elevation: 8,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              spacing: 20,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.cloud_download_outlined,
                    size: 48,
                    color: Colors.blue.shade600,
                  ),
                ),
                FilledButton.icon(
                  onPressed: () async {
                    try {
                      setState(() {
                        progressStream = checkAndDownloadUpdatesWithProgress();
                      });
                    } catch (e) {
                      debugPrint('Error starting update: $e');
                    }
                  },
                  label: const Text("Download Update"),
                  icon: const Icon(Icons.download),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    backgroundColor: Colors.blue.shade600,
                  ),
                ),
                StreamBuilder(
                  stream: progressStream,
                  builder: (context, progressValue) {
                    debugPrint('Progress update: ${progressValue.data}');
                    final progress = progressValue.hasData
                        ? progressValue.data!.toDouble() / 100
                        : 0.0;
                    return Column(
                      spacing: 16,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: SizedBox(
                            height: 24,
                            width: 280,
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor: Colors.grey.shade200,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.blue.shade600,
                              ),
                            ),
                          ),
                        ),
                        Text(
                          'Progress: ${progressValue.data ?? 'Waiting...'}%',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        if (progressValue.data == 100)
                          Column(
                            spacing: 12,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  border:
                                      Border.all(color: Colors.green.shade300),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  spacing: 8,
                                  children: [
                                    Icon(Icons.check_circle,
                                        color: Colors.green.shade600),
                                    Text(
                                      'Update ready! Restart required.',
                                      style: TextStyle(
                                          color: Colors.green.shade700),
                                    ),
                                  ],
                                ),
                              ),
                              FilledButton.icon(
                                onPressed: () async {
                                  try {
                                    await updateAndRestart();
                                  } catch (e) {
                                    debugPrint('Error applying update: $e');
                                  }
                                },
                                label: const Text('Restart Now'),
                                icon: const Icon(Icons.restart_alt),
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.green.shade600,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('App Update Manager'),
          elevation: 0,
          backgroundColor: Colors.blue.shade600,
          foregroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 24,
              children: [
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: FutureBuilder(
                      future: currentVersion(),
                      builder: (context, snap) => Column(
                        spacing: 12,
                        children: [
                          Icon(Icons.info_outline,
                              size: 32, color: Colors.blue.shade600),
                          Text(
                            'Current Version',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: Colors.grey.shade600,
                                ),
                          ),
                          Text(
                            snap.data ?? 'Loading...',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade600,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                FutureBuilder(
                  future: isUpdateAvailable(),
                  builder: (context, snap) {
                    if (snap.error != null) {
                      return Card(
                        color: Colors.red.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            spacing: 12,
                            children: [
                              Icon(Icons.error_outline,
                                  color: Colors.red.shade600),
                              Flexible(
                                child: Text('Error: ${snap.error}'),
                              ),
                            ],
                          ),
                        ),
                      );
                    } else if (snap.hasData && snap.data == true) {
                      return const UpdateStatus();
                    } else {
                      return Card(
                        color: Colors.green.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            spacing: 12,
                            children: [
                              Icon(Icons.check_circle,
                                  color: Colors.green.shade600),
                              const Flexible(
                                child: Text('App is up to date'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class UpdateStatus extends StatelessWidget {
  const UpdateStatus({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 16,
      children: [
        FutureBuilder(
          future: getLatestUpdateInfo(),
          builder: (context, updateInfoSnap) {
            if (updateInfoSnap.hasError) {
              return Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Error: ${updateInfoSnap.error}'),
                ),
              );
            }

            return Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  spacing: 16,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.system_update,
                        size: 40,
                        color: Colors.amber.shade600,
                      ),
                    ),
                    Text(
                      'Update Available',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    if (updateInfoSnap.hasData) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Text(
                          'v${updateInfoSnap.data!.targetFullRelease.version}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Text(
                        'Release Notes',
                        style:
                            Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: Colors.grey.shade600,
                                ),
                      ),
                      Container(
                        constraints:
                            const BoxConstraints(maxHeight: 80, maxWidth: 300),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: SingleChildScrollView(
                          child: Text(
                            updateInfoSnap
                                    .data?.targetFullRelease.notesMarkdown ??
                                'No details available',
                            style: Theme.of(context).textTheme.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    const Updater(),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
