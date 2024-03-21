import 'package:background_fetch/background_fetch.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String message = '';

  @override
  void initState() {
    super.initState();
 
    initBackgroundFetch();
  }

  Future<void> initBackgroundFetch() async {
    print("from initBackgroundFetch");
    BackgroundFetch.configure(BackgroundFetchConfig(
      minimumFetchInterval: 1,
      stopOnTerminate: false,
      enableHeadless: true,
      startOnBoot: true,
      requiresBatteryNotLow: false,
      requiresCharging: false,
      requiresStorageNotLow: false,
      requiresDeviceIdle: false,
      requiredNetworkType: NetworkType.NONE,
    ), (String taskId) async {
      
      print("[Background Fetch] Event received: $taskId");
      await storeValueInFirestore();
      BackgroundFetch.finish(taskId);
    }).then((int status) {
      print('[Background Fetch] configure success: $status');
    }).catchError((e) {
      print('[Background Fetch] configure error: $e');
    });
  }

  Future<void> storeValueInFirestore() async {
    try {
      print("from storeValueInFirestore");
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      await firestore.collection('values').add({
        
        'timestamp': DateTime.now(),
      });
      setState(() {
        message = 'Value stored in Firestore';
      });
    } catch (e) {
      print('Error storing value in Firestore: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextButton(child: Text("SAVE VALUE"),onPressed: () {
          print("from ");
          storeValueInFirestore().then((value) => print("Value stored"));
        },),
      ),
    );
  }
}