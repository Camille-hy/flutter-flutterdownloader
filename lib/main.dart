import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Plugin must be initialized before using
  await FlutterDownloader.initialize(
    debug: true,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController url = TextEditingController();
  bool _downloading = false;

  // Future openFile({required String url, String? fileName}) async {
  //   final name = fileName ?? url.split('/').last;
  //   final file = await downloadFile(url, name);

  //   if (file == null) return;

  //   print('Path: ${file.path}');

  //   OpenFile.open(file.path);
  // }

  Future<File?> downloadFile({required String url, String? name}) async {
    // final fileDir = await getApplicationDocumentsDirectory();
    final fileDir = await getExternalStorageDirectory();
    final file = File('${fileDir!.path}/$name');

    final taskId = await FlutterDownloader.enqueue(
      url: url,
      savedDir: fileDir.path,
      fileName: name,
      showNotification: true,
      openFileFromNotification: true,
    );
    return file;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Download file',
            ),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: url,
                decoration: const InputDecoration(label: Text('Url')),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () async {
                setState(() {
                  _downloading = true;
                });

                final status = await Permission.storage.request();
                if (status.isGranted) {
                  await downloadFile(url: url.text);
                } else {
                  print('Permission denied');
                }

                setState(() {
                  _downloading = false;
                });
              },
              child: _downloading ? CircularProgressIndicator():Text(
                'Download',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
