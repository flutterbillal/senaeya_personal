library;

import 'dart:developer';

import 'package:Senaeya/Core/AppRoute/app_route.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

import 'package:permission_handler/permission_handler.dart';

import '../../Helper/shared_prefe/shared_prefe.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialize Firebase in the background
  await Firebase.initializeApp();

  log('Handling a background message: ${message.messageId}');
  log('Background message title: ${message.notification?.title}');
  log('Background message body: ${message.notification?.body}');
  log('Background message data: ${message.data}');

  // You can show a local notification from background handler if needed.
}

@pragma('vm:entry-point')
class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  // Initialize Flutter Local Notifications Plugin
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Create custom notification channel with custom sound
  /// This must be called before FCM setup (ideally in main.dart)
  static Future<void> createCustomNotificationChannel() async {
    try {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'custom_channel', // Channel ID - must match FCM payload
        'Custom Notifications', // Channel Name
        description: 'Channel with custom notification sound',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
        // Custom sound file: android/app/src/main/res/raw/alert.mp3
        // Reference WITHOUT extension
        sound: RawResourceAndroidNotificationSound('alert'),
      );

      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      log('✅ Custom notification channel created successfully');
    } catch (e) {
      log('❌ Error creating notification channel: $e');
    }
  }

  Future<void> setupFCM() async {
    try {
      // Initialize Firebase
      await Firebase.initializeApp();

      // Initialize local notifications plugin
      // Use the default launcher icon name that exists in most Flutter projects
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/launcher_icon');

      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          // Handle notification tap - open notification screen with payload
          log('Notification tapped: ${response.payload}');
          try {
            Get.toNamed(
              AppRoute.notificationScreen,
              arguments: {
                'tabIndex': 0,
                'payload': response.payload,
              },
            );
          } catch (e) {
            log('Error navigating on notification tap: $e');
          }
        },
      );

      // Create Android notification channel (after plugin initialized)
      if (GetPlatform.isAndroid) {
        await createCustomNotificationChannel();
      }

      // For iOS: ensure notifications are presented while app is in foreground
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // Request permission for notifications (iOS specific + Android 13+)
      NotificationSettings settings =
          await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      // Handle Android 13+ permission explicitly
      if (GetPlatform.isAndroid) {
        var status = await Permission.notification.status;
        if (status.isDenied) {
          log('Requesting notification permission for Android 13+');
          await Permission.notification.request();
        }
      }

      log('User granted permission: ${settings.authorizationStatus}');
      print('User granted permission: ${settings.authorizationStatus}');

      // Get the token for the device
      String? token = await _firebaseMessaging.getToken();
      log('🛑 Device Token: $token');
      print('🛑 Device Token: $token');
      await SharePrefsHelper.setString(SharedPreferenceValue.fcmToken, token);

      // Listen for token refresh
      _firebaseMessaging.onTokenRefresh.listen((String token) {
        //! log('FCM Token refreshed: $token');
        SharePrefsHelper.setString(SharedPreferenceValue.fcmToken, token);
      });

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _handleForegroundMessage(message);
      });

      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);
      // Handle notification when app is opened from a terminated state
      RemoteMessage? initialMessage =
          await FirebaseMessaging.instance.getInitialMessage();
      if (initialMessage != null) {
        _handleNotificationNavigation(initialMessage);
      }
      // Handle when the app is resumed from the background via notification tap
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        _handleNotificationNavigation(message);
      });
    } catch (e) {
      log("An error occurred during FCM setup: $e");
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    log('Received message in foreground: ${message.notification?.title}, ${message.notification?.body}');

    // Show local notification with custom sound
    _showLocalNotification(message);

    // Still show an in-app snackbar for quick feedback
    // showCustomSnackBar(
    //   message.notification?.title ?? 'Notification',isError: false
    // );
  }

  /// Show local notification with custom sound for both Android and iOS
  Future<void> _showLocalNotification(RemoteMessage message) async {
    try {
      // Android notification details with custom sound
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'custom_channel', // Must match the channel created earlier
        'Custom Notifications',
        channelDescription: 'Channel with custom notification sound',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        sound: RawResourceAndroidNotificationSound(
            'alert'), // Custom sound for Android
      );

      // iOS notification details with custom sound
      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound:
            'alert.caf', // Custom sound for iOS (must be in ios/Runner directory)
      );

      const NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Build a concise title & body fallbacks
      final title = message.notification?.title ??
          message.data['title'] ??
          'New Notification';
      final body = message.notification?.body ?? message.data['body'] ?? '';

      // Display local notification (this will show a system notification while app is in foreground)
      await flutterLocalNotificationsPlugin.show(
        message.hashCode, // Unique notification ID
        title,
        body,
        platformDetails,
        payload: message.data.isNotEmpty ? message.data.toString() : null,
      );

      log('✅ Local notification shown with custom sound');
      print('✅ Local notification shown with custom sound');
    } catch (e, stack) {
      log('❌ Error showing local notification: $e');
      print('❌ Error showing local notification: $e');
      print(stack);
    }
  }

  void _handleNotificationNavigation(RemoteMessage message) {
    log('Navigating to notification screen due to message: ${message.notification?.title}');

    // Extract data from the notification
    Map<String, dynamic> data = message.data;

    // Navigate to notification screen
    // You can customize the tabIndex or pass additional data based on your needs
    Get.toNamed(
      AppRoute.notificationScreen,
      arguments: {
        'tabIndex': 0,
        'messageId': message.messageId,
        'title': message.notification?.title,
        'body': message.notification?.body,
        'data': data,
      },
    );
  }
}
