import 'package:alarm/alarm.dart';
import 'package:alarm/model/alarm_settings.dart';
import 'package:flutter/material.dart';

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  State<Notifications> createState() => _NotificationsState();
  
}

class _NotificationsState extends State<Notifications> {

@override
  void initState() {
    Alarm.init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(     
      body: alarmTest(),
    );
  }

  Widget alarmTest() {
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
            child: const Text('set alarm'),
            onPressed: () async {
              await Alarm.set(alarmSettings: alarmSettings);
              print("alarm has been set");
            }),
        TextButton(
            child: const Text('stop alarm'),
            onPressed: () async {
              await Alarm.stopAll();
              print("stop");
            }),
      ],
    );
  }
}
