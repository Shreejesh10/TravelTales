import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:traveltales/api/api.dart';
import 'package:traveltales/core/model/event_model.dart';
import 'package:traveltales/core/route_config/route_names.dart';
import 'package:flutter/foundation.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await NotificationService.instance.persistIncomingMessage(message);
  debugPrint('Background message: ${message.messageId}');
  debugPrint('Title: ${message.notification?.title}');
  debugPrint('Body: ${message.notification?.body}');
  debugPrint('Data: ${message.data}');
}

class NotificationInboxItem {
  final String title;
  final String body;
  final DateTime receivedAt;
  final Map<String, dynamic> data;
  final bool isRead;

  const NotificationInboxItem({
    required this.title,
    required this.body,
    required this.receivedAt,
    required this.data,
    required this.isRead,
  });

  Map<String, dynamic> toJson() => {
    "title": title,
    "body": body,
    "received_at": receivedAt.toIso8601String(),
    "data": data,
    "is_read": isRead,
  };

  factory NotificationInboxItem.fromJson(Map<String, dynamic> json) {
    return NotificationInboxItem(
      title: json["title"]?.toString() ?? "",
      body: json["body"]?.toString() ?? "",
      receivedAt: DateTime.tryParse(json["received_at"]?.toString() ?? "") ??
          DateTime.now(),
      data: Map<String, dynamic>.from(json["data"] ?? const {}),
      isRead: json["is_read"] == true,
    );
  }
}

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static const String _inboxStorageKey = 'notification_inbox';
  static const String _fcmTokenStorageKey = 'device_fcm_token';
  static const String _lastSyncedTokenStorageKey = 'device_fcm_token_synced';
  static const String _channelId = 'traveltales_general_notifications';

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final ValueNotifier<int> unreadCountNotifier = ValueNotifier<int>(0);
  bool _isInitialized = false;
  bool _localNotificationsReady = false;
  Map<String, dynamic>? _pendingNavigationData;

  Future<void> init() async {
    if (_isInitialized) return;

    if (kIsWeb) {
      debugPrint('Skipping Firebase Messaging on Web');
      await _refreshUnreadCount();
      _isInitialized = true;
      return;
    }

    if (!kIsWeb) {
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    }
    await _configureLocalNotifications();

    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    debugPrint('Permission status: ${settings.authorizationStatus}');

    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    final token = await _getTokenSafely();
    if (token != null && token.isNotEmpty) {
      await _storage.write(key: _fcmTokenStorageKey, value: token);
      debugPrint('FCM Token: $token');
      await _syncTokenToBackend(token);
    }

    _messaging.onTokenRefresh.listen((newToken) async {
      debugPrint('Refreshed FCM Token: $newToken');
      await _storage.write(key: _fcmTokenStorageKey, value: newToken);
      await _syncTokenToBackend(newToken);
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      debugPrint('Foreground message: ${message.messageId}');
      debugPrint('Title: ${message.notification?.title}');
      debugPrint('Body: ${message.notification?.body}');
      debugPrint('Data: ${message.data}');
      await persistIncomingMessage(message);
      await _showLocalNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      debugPrint('Message clicked!');
      debugPrint('Data: ${message.data}');
      await _handleNotificationTap(message.data);
    });

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('Opened from terminated state');
      debugPrint('Data: ${initialMessage.data}');
      _pendingNavigationData = Map<String, dynamic>.from(initialMessage.data);
    }

    await _refreshUnreadCount();
    _isInitialized = true;
  }

  Future<void> onUserAuthenticated() async {
    if (kIsWeb) {
      return;
    }

    final token = await _storage.read(key: _fcmTokenStorageKey) ??
        await _getTokenSafely();

    if (token == null || token.isEmpty) return;

    await _storage.write(key: _fcmTokenStorageKey, value: token);
    await _syncTokenToBackend(token, force: true);
  }

  Future<void> onUserLoggedOut() async {
    if (kIsWeb) {
      return;
    }

    try {
      await removeFcmToken();
    } catch (e) {
      debugPrint('Failed to remove FCM token from backend: $e');
    }

    await _storage.delete(key: _lastSyncedTokenStorageKey);
  }

  Future<void> persistIncomingMessage(RemoteMessage message) async {
    final title = message.notification?.title ??
        message.data['title']?.toString() ??
        'Travel Tales';
    final body = message.notification?.body ??
        message.data['body']?.toString() ??
        '';

    await _saveInboxItem(
      NotificationInboxItem(
        title: title,
        body: body,
        receivedAt: DateTime.now(),
        data: Map<String, dynamic>.from(message.data),
        isRead: false,
      ),
    );
  }

  Future<List<NotificationInboxItem>> getInboxItems() async {
    final prefs = await SharedPreferences.getInstance();
    final encodedItems = prefs.getStringList(_inboxStorageKey) ?? const [];

    return encodedItems
        .map(
          (item) => NotificationInboxItem.fromJson(
            Map<String, dynamic>.from(jsonDecode(item)),
          ),
        )
        .toList()
      ..sort((a, b) => b.receivedAt.compareTo(a.receivedAt));
  }

  Future<void> flushPendingNavigation() async {
    final pendingData = _pendingNavigationData;
    if (pendingData == null) return;

    _pendingNavigationData = null;
    await _handleNotificationTap(pendingData);
  }

  Future<void> _configureLocalNotifications() async {
    if (_localNotificationsReady) return;

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (response) async {
        final payload = response.payload;
        if (payload == null || payload.isEmpty) {
          await _openNotificationCenter();
          return;
        }

        final data = Map<String, dynamic>.from(jsonDecode(payload));
        await _handleNotificationTap(data);
      },
    );

    const channel = AndroidNotificationChannel(
      _channelId,
      'Travel Tales Notifications',
      description: 'General Travel Tales notifications',
      importance: Importance.max,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    _localNotificationsReady = true;
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    if (!_localNotificationsReady) return;

    final notification = message.notification;
    final title =
        notification?.title ?? message.data['title']?.toString() ?? 'Travel Tales';
    final body = notification?.body ?? message.data['body']?.toString() ?? '';

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      'Travel Tales Notifications',
      channelDescription: 'General Travel Tales notifications',
      importance: Importance.max,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      details,
      payload: jsonEncode(message.data),
    );
  }

  Future<void> _syncTokenToBackend(String token, {bool force = false}) async {
    final accessToken = await _storage.read(key: 'access_token');
    if (accessToken == null || accessToken.isEmpty) {
      return;
    }

    final lastSyncedToken = await _storage.read(key: _lastSyncedTokenStorageKey);
    if (!force && lastSyncedToken == token) {
      return;
    }

    try {
      await saveFcmToken(token);
      await _storage.write(key: _lastSyncedTokenStorageKey, value: token);
    } catch (e) {
      debugPrint('Failed to sync FCM token: $e');
    }
  }

  Future<void> _saveInboxItem(NotificationInboxItem item) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getStringList(_inboxStorageKey) ?? <String>[];
    final updated = <String>[jsonEncode(item.toJson()), ...existing];
    await prefs.setStringList(_inboxStorageKey, updated.take(50).toList());
    await _refreshUnreadCount();
  }

  Future<void> markAllAsRead() async {
    final prefs = await SharedPreferences.getInstance();
    final encodedItems = prefs.getStringList(_inboxStorageKey) ?? const [];

    if (encodedItems.isEmpty) {
      unreadCountNotifier.value = 0;
      return;
    }

    final updatedItems = encodedItems
        .map(
          (item) => NotificationInboxItem.fromJson(
            Map<String, dynamic>.from(jsonDecode(item)),
          ),
        )
        .map(
          (item) => item.isRead
              ? item
              : NotificationInboxItem(
                  title: item.title,
                  body: item.body,
                  receivedAt: item.receivedAt,
                  data: item.data,
                  isRead: true,
                ),
        )
        .map((item) => jsonEncode(item.toJson()))
        .toList();

    await prefs.setStringList(_inboxStorageKey, updatedItems);
    unreadCountNotifier.value = 0;
  }

  Future<bool> openInboxItem(NotificationInboxItem item) async {
    return _handleNotificationTap(item.data);
  }

  Future<void> _refreshUnreadCount() async {
    final prefs = await SharedPreferences.getInstance();
    final encodedItems = prefs.getStringList(_inboxStorageKey) ?? const [];

    final unreadCount = encodedItems
        .map(
          (item) => NotificationInboxItem.fromJson(
            Map<String, dynamic>.from(jsonDecode(item)),
          ),
        )
        .where((item) => !item.isRead)
        .length;

    unreadCountNotifier.value = unreadCount;
  }

  Future<bool> _handleNotificationTap(Map<String, dynamic> data) async {
    if (navigatorKey.currentState == null) {
      _pendingNavigationData = data;
      return false;
    }

    final eventId = int.tryParse(data['event_id']?.toString() ?? '');
    if (eventId == null) {
      await _openNotificationCenter();
      return true;
    }

    try {
      final events = await getAllEvents();
      final Event event = events.firstWhere((item) => item.eventId == eventId);
      navigatorKey.currentState?.pushNamed(
        RouteName.eventDetailScreen,
        arguments: event,
      );
      return true;
    } catch (e) {
      debugPrint('Failed to open event from notification: $e');
      return false;
    }
  }

  Future<void> _openNotificationCenter() async {
    navigatorKey.currentState?.pushNamed(RouteName.notificationScreen);
  }

  Future<String?> _getTokenSafely() async {
    try {
      return await _messaging.getToken();
    } catch (e, stackTrace) {
      debugPrint('Failed to get FCM token: $e');
      debugPrintStack(stackTrace: stackTrace);
      return null;
    }
  }
}
