import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:webookapp/view_model/auth_provider.dart';

class NotificationPage extends StatefulWidget {
  NotificationPage({Key key}) : super(key: key);
  @override
  _NotificationPageState createState() {
    return _NotificationPageState();
  }
}

class _NotificationPageState extends State<NotificationPage> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.reference();
  final FirebaseMessaging _fcm = FirebaseMessaging();

  @override
  void initState() {
    super.initState();
    _saveDeviceToken();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'My Notification Page',
            ),
          ],
        ),
      ),
      //bottomNavigationBar: BottomNavBar(),
    );
  }

  /// Get the token, save it to the database for current user
  _saveDeviceToken() async {
    String uid = "YiTgZmPt5eV8gYhxqVGI8tDO8RJ2";
    // Get the token for this device
    String fcmToken = await _fcm.getToken();
    print(fcmToken);

    // Save it to Firestore
    if (fcmToken != null) {
      await _dbRef.child('users/$uid/token').set(fcmToken);
    }
  }
}
