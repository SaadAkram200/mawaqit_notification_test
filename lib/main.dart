import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:background_fetch/background_fetch.dart';
import 'package:mawaqit_notification_test/firebase_options.dart';

@pragma('vm:entry-point')
void backgroundFetchHeadlessTask(HeadlessTask task) async {
  String taskId = task.taskId;
  bool isTimeout = task.timeout;
  if (isTimeout) {
    print("[BackgroundFetch] Headless task timed-out: $taskId");
    BackgroundFetch.finish(taskId);
    return;
  }
  print('[BackgroundFetch] Headless event received.');
  // Do your work here...
  await storeValueInFirestore();
  BackgroundFetch.finish(taskId);
}

Future<void> storeValueInFirestore() async {
  try {
    print("from storeValueInFirestore");
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    await firestore.collection('values').add({
      'timestamp': DateTime.now(),
    });
  } catch (e) {
    print('Error storing value in Firestore: $e');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());

  BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _enabled = true;
  int _status = 0;
  List<DateTime> events = [];

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    int status = await BackgroundFetch.configure(
        BackgroundFetchConfig(
            minimumFetchInterval: 2,
            stopOnTerminate: false,
            enableHeadless: true,
            requiresBatteryNotLow: false,
            requiresCharging: false,
            requiresStorageNotLow: false,
            requiresDeviceIdle: false,
            requiredNetworkType: NetworkType.NONE), (String taskId) async {
      print("[BackgroundFetch] Event received $taskId");
      await storeValueInFirestore();
      setState(() {
        events.insert(0, DateTime.now());
      });

      BackgroundFetch.finish(taskId);
    }, (String taskId) async {
      print("[BackgroundFetch] TASK TIMEOUT taskId: $taskId");
      BackgroundFetch.finish(taskId);
    });
    print('[BackgroundFetch] configure success: $status');
    setState(() {
      _status = status;
    });

    if (!mounted) return;
  }

  void _onClickEnable(enabled) {
    setState(() {
      _enabled = enabled;
    });
    if (enabled) {
      BackgroundFetch.start().then((int status) {
        print('[BackgroundFetch] start success: $status');
      }).catchError((e) {
        print('[BackgroundFetch] start FAILURE: $e');
      });
    } else {
      BackgroundFetch.stop().then((int status) {
        print('[BackgroundFetch] stop success: $status');
      });
    }
  }

  void _onClickStatus() async {
    int status = await BackgroundFetch.status;
    print('[BackgroundFetch] status: $status');
    setState(() {
      _status = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
            title: const Text('BackgroundFetch Example',
                style: TextStyle(color: Colors.black)),
            backgroundColor: Colors.amberAccent,
            actions: [
              Switch(value: _enabled, onChanged: _onClickEnable),
            ]),
        body: Container(
          color: Colors.black,
          child: ListView.builder(
              itemCount: events.length,
              itemBuilder: (BuildContext context, int index) {
                DateTime timestamp = events[index];
                return InputDecorator(
                    decoration: const InputDecoration(
                        contentPadding:
                            EdgeInsets.only(left: 10.0, top: 10.0, bottom: 0.0),
                        labelStyle: TextStyle(
                            color: Colors.amberAccent, fontSize: 20.0),
                        labelText: "[background fetch event]"),
                    child: Text(timestamp.toString(),
                        style: const TextStyle(
                            color: Colors.white, fontSize: 16.0)));
              }),
        ),
        bottomNavigationBar: BottomAppBar(
            child: Row(children: [
          TextButton(onPressed: _onClickStatus, child: const Text('Status')),
          Container(
              margin: const EdgeInsets.only(left: 20.0),
              child: Text("$_status"))
        ])),
      ),
    );
  }
}
