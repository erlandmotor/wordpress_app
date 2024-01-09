import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
import 'package:wordpress_app/models/notification_model.dart';
import 'package:wordpress_app/utils/next_screen.dart';
import 'package:wordpress_app/utils/notification_dialog.dart';
import '../constants/constant.dart';

class NotificationService {


  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final String subscriptionTopic = 'all';


  Future _handleIosNotificationPermissaion () async {
    NotificationSettings settings = await _fcm.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('User granted permission');
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        debugPrint('User granted provisional permission');
      } else {
        debugPrint('User declined or has not accepted permission');
      }
  }





  Future initFirebasePushNotification(context) async {
    await _handleIosNotificationPermissaion();
    String? token = await _fcm.getToken();
    debugPrint('User FCM Token : $token');

    RemoteMessage? initialMessage = await _fcm.getInitialMessage();
    debugPrint('inittal message : $initialMessage');
    if (initialMessage != null) {
      await _saveNotificationData(initialMessage).then((value) => _navigateToDetailsScreen(context, initialMessage));
    }
    

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      debugPrint('onMessage: ${message.notification!.body}');
      await _saveNotificationData(message).then((value) => _handleOpenNotificationDialog(context, message));
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      await _saveNotificationData(message).then((value) => _navigateToDetailsScreen(context, message));
    });
  }



  Future _handleOpenNotificationDialog(context, RemoteMessage message) async {
    DateTime now = DateTime.now();
    String timestamp = DateFormat('yyyyMMddHHmmss').format(now);
    NotificationModel notificationModel = NotificationModel(
        timestamp: timestamp,
        date: DateTime.now(),
        title: message.notification!.title,
        body: message.notification!.body,
        postID: message.data['post_id'] == null ? null : int.parse(message.data['post_id']),
        thumbnailUrl: message.data['image']
    );
    openNotificationDialog(context, notificationModel);
  }


  Future _navigateToDetailsScreen(context, RemoteMessage message) async {
    DateTime now = DateTime.now();
    String timestamp = DateFormat('yyyyMMddHHmmss').format(now);
    NotificationModel notificationModel = NotificationModel(
        timestamp: timestamp,
        date: DateTime.now(),
        title: message.notification!.title,
        body: message.notification!.body,
        postID: message.data['post_id'] == null ? null : int.parse(message.data['post_id']),
        thumbnailUrl: message.data['image']
    );
    navigateToNotificationDetailsScreen(context, notificationModel);
  }



  Future _saveNotificationData(RemoteMessage message) async {
    final list = Hive.box(Constants.notificationTag);
    DateTime now = DateTime.now();
    String timestamp = DateFormat('yyyyMMddHHmmss').format(now);
    Map<String, dynamic> notificationData = {
      'timestamp': timestamp,
      'date': DateTime.now(),
      'title': message.notification!.title,
      'body': message.notification!.body,
      'post_id': message.data['post_id'],
      'image': message.data['image']
    };

    await list.put(timestamp, notificationData);
  }



  Future deleteNotificationData(key) async {
    final bookmarkedList = Hive.box(Constants.notificationTag);
    await bookmarkedList.delete(key);
  }



  Future deleteAllNotificationData() async {
    final bookmarkedList = Hive.box(Constants.notificationTag);
    await bookmarkedList.clear();
  }

  Future<bool?> checkingPermisson ()async{
    bool? accepted;
    await _fcm.getNotificationSettings().then((NotificationSettings settings)async{
      if(settings.authorizationStatus == AuthorizationStatus.authorized || settings.authorizationStatus == AuthorizationStatus.provisional){
        accepted = true;
      }else{
        accepted = false;
      }
    });
    return accepted;
  }

  Future subscribe ()async{
    await _fcm.subscribeToTopic(Constants.fcmSubcriptionTopticforAll);
  }

  Future unsubscribe ()async{
    await _fcm.unsubscribeFromTopic(Constants.fcmSubcriptionTopticforAll);
  }
}
