import 'dart:async';
import 'dart:io';
import 'package:alarm/alarm.dart';
import 'package:alarm/model/alarm_settings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

//import 'package:background_fetch/background_fetch.dart';
import 'package:mawaqit_notification_test/firebase_options.dart';
import 'package:workmanager/workmanager.dart';

Future<void> storeValueInFirestore() async {
  String checkPlatform;
  if (Platform.isIOS) {
    checkPlatform = "from ios";
  } else{
    checkPlatform = "from android";
  }
  try {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    await firestore.collection('values').add({
      'timestamp': DateTime.now(),
      'platform': checkPlatform,
    });
  } catch (e) {
    print('Error storing value in Firestore: $e');
  }
}

void setAlarm() async {
  DateTime now = DateTime.now();
  final alarmSettings = AlarmSettings(
    id: 42,
    dateTime: now.add(const Duration(minutes: 5)),
    assetAudioPath: 'assets/sound.mp3',
    loopAudio: true,
    vibrate: true,
    volume: 0.8,
    fadeDuration: 3.0,
    notificationTitle: 'Asar prayer',
    notificationBody: 'adhan',
    enableNotificationOnKill: false,
  );
  await Alarm.set(alarmSettings: alarmSettings);
}

// @pragma('vm:entry-point')
// void backgroundFetchHeadlessTask(HeadlessTask task) async {
//   String taskId = task.taskId;
//   bool isTimeout = task.timeout;
//   if (isTimeout) {
//     print("[BackgroundFetch] Headless task timed-out: $taskId");
//     BackgroundFetch.finish(taskId);
//     return;
//   }
//   print('[BackgroundFetch] Headless event received.');
//   // Do your work here...
//   await storeValueInFirestore();
//   BackgroundFetch.finish(taskId);
// }

void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    await Alarm.init();
    print("[WorkManager] Headless event received.");
    await storeValueInFirestore();
    setAlarm();
    return true;
  }); 
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Alarm.init();
  runApp(const MyApp());
  Workmanager().initialize(callbackDispatcher);

  Workmanager().registerPeriodicTask(
    "1",
    "backgroundFetchTask",
    frequency: const Duration(minutes: 15),
  );
  //BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
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

  // Future<void> initPlatformState() async {
  //   int status = await BackgroundFetch.configure(
  //       BackgroundFetchConfig(
  //           minimumFetchInterval: 2,
  //           stopOnTerminate: false,
  //           enableHeadless: true,
  //           requiresBatteryNotLow: false,
  //           requiresCharging: false,
  //           requiresStorageNotLow: false,
  //           requiresDeviceIdle: false,
  //           requiredNetworkType: NetworkType.NONE), (String taskId) async {
  //     print("[BackgroundFetch] Event received $taskId");
  //     await storeValueInFirestore();
  //     setAlarm();
  //     setState(() {
  //       events.insert(0, DateTime.now());
  //     });
  //     BackgroundFetch.finish(taskId);
  //   }, (String taskId) async {
  //     print("[BackgroundFetch] TASK TIMEOUT taskId: $taskId");
  //     BackgroundFetch.finish(taskId);
  //   });
  //   print('[BackgroundFetch] configure success: $status');
  //   setState(() {
  //     _status = status;
  //   });
  //   if (!mounted) return;
  // }

  Future<void> initPlatformState() async {
    Workmanager().initialize(callbackDispatcher);
    print('[WorkManager] Initialized');
  }

  void _onClickEnable(enabled) {
    setState(() {
      _enabled = enabled;
    });
    if (enabled) {
      Workmanager().registerPeriodicTask(
        "1",
        "backgroundFetchTask",
        frequency: Duration(minutes: 15),
      );
      print('[WorkManager] Task started');
    } else {
      Workmanager().cancelAll();
      print('[WorkManager] Task stopped');
    }
  }

  // void _onClickEnable(enabled) {
  //   setState(() {
  //     _enabled = enabled;
  //   });
  //   if (enabled) {
  //     BackgroundFetch.start().then((int status) {
  //       print('[BackgroundFetch] start success: $status');
  //     }).catchError((e) {
  //       print('[BackgroundFetch] start FAILURE: $e');
  //     });
  //   } else {
  //     BackgroundFetch.stop().then((int status) {
  //       print('[BackgroundFetch] stop success: $status');
  //     });
  //   }
  // }

  // void _onClickStatus() async {
  //   int status = await BackgroundFetch.status;
  //   print('[BackgroundFetch] status: $status');
  //   setState(() {
  //     _status = status;
  //   });
  // }

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
          child: ElevatedButton(
            onPressed: () => Alarm.stopAll(),
            child: const Text('Stop alarm'),
          ),
        ),
      ),
    );
  }
}
