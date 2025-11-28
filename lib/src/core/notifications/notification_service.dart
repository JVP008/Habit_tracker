import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:logger/logger.dart';
import 'package:habit_tracker/src/features/habits/data/models/habit_model.dart';
import 'package:habit_tracker/src/features/challenges/data/models/challenge_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  final Logger _logger = Logger();
  bool _initialized = false;

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Initialize timezone
      tz.initializeTimeZones();

      // Android settings
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS settings
      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
          );

      // Initialization settings
      const InitializationSettings settings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      // Initialize the plugin
      await _notifications.initialize(
        settings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // Create notification channels
      await _createNotificationChannels();

      _initialized = true;
      _logger.i('Notification service initialized successfully');
    } catch (e) {
      _logger.e('Failed to initialize notification service: $e');
    }
  }

  /// Create notification channels for Android
  Future<void> _createNotificationChannels() async {
    const AndroidNotificationChannel habitChannel = AndroidNotificationChannel(
      'habit_reminders',
      'Habit Reminders',
      description: 'Reminders for daily habits',
      importance: Importance.high,
      sound: RawResourceAndroidNotificationSound('notification_sound'),
    );

    const AndroidNotificationChannel challengeChannel =
        AndroidNotificationChannel(
          'challenge_deadlines',
          'Challenge Deadlines',
          description: 'Notifications for challenge deadlines',
          importance: Importance.high,
          sound: RawResourceAndroidNotificationSound('notification_sound'),
        );

    const AndroidNotificationChannel insightsChannel =
        AndroidNotificationChannel(
          'daily_insights',
          'Daily Insights',
          description: 'Daily wellness insights and summaries',
          importance: Importance.defaultImportance,
        );

    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(habitChannel);

    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(challengeChannel);

    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(insightsChannel);
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    _logger.i('Notification tapped: ${response.payload}');
    // Navigate to specific screen based on payload
    // This would integrate with your navigation system
  }

  /// Request notification permissions
  Future<bool> requestPermissions() async {
    try {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _notifications
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();

      final bool? grantedNotificationPermission = await androidImplementation
          ?.requestNotificationsPermission();

      return grantedNotificationPermission ?? false;
    } catch (e) {
      _logger.e('Failed to request permissions: $e');
      return false;
    }
  }

  /// Schedule habit reminder
  Future<void> scheduleHabitReminder(HabitModel habit) async {
    if (!_initialized) await initialize();

    try {
      final now = tz.TZDateTime.now(tz.local);
      final scheduledTime = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        habit.reminderTime.hour,
        habit.reminderTime.minute,
      );

      // If time has passed today, schedule for tomorrow
      final actualTime = scheduledTime.isBefore(now)
          ? scheduledTime.add(const Duration(days: 1))
          : scheduledTime;

      await _notifications.zonedSchedule(
        habit.id.hashCode, // Unique ID for this notification
        'Habit Reminder',
        'Time to complete: ${habit.title}',
        actualTime,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'habit_reminders',
            'Habit Reminders',
            channelDescription: 'Reminders for daily habits',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            largeIcon: const DrawableResourceAndroidBitmap(
              '@mipmap/ic_launcher',
            ),
            styleInformation: const BigTextStyleInformation(''),
            actions: [
              AndroidNotificationAction('mark_done', 'Mark Done'),
              AndroidNotificationAction('skip', 'Skip'),
            ],
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            sound: 'notification_sound.aiff',
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'habit_${habit.id}',
      );

      _logger.i('Scheduled habit reminder for ${habit.title} at $actualTime');
    } catch (e) {
      _logger.e('Failed to schedule habit reminder: $e');
    }
  }

  /// Schedule challenge deadline reminder
  Future<void> scheduleChallengeDeadlineReminder(
    ChallengeModel challenge,
  ) async {
    if (!_initialized) await initialize();

    try {
      final now = tz.TZDateTime.now(tz.local);
      final deadline = tz.TZDateTime.from(challenge.endDate, tz.local);

      // Schedule reminders: 1 week before, 3 days before, 1 day before, and on deadline
      final reminders = [
        deadline.subtract(const Duration(days: 7)),
        deadline.subtract(const Duration(days: 3)),
        deadline.subtract(const Duration(days: 1)),
        deadline,
      ];

      for (int i = 0; i < reminders.length; i++) {
        final reminderTime = reminders[i];
        if (reminderTime.isAfter(now)) {
          String title, body;

          switch (i) {
            case 0: // 1 week before
              title = 'Challenge Deadline Approaching';
              body =
                  '${challenge.title} ends in 1 week! Keep up the great work!';
              break;
            case 1: // 3 days before
              title = 'Challenge Deadline Soon';
              body = 'Only 3 days left in ${challenge.title}!';
              break;
            case 2: // 1 day before
              title = 'Final Day Tomorrow';
              body = 'Last day tomorrow for ${challenge.title}!';
              break;
            case 3: // Deadline day
              title = 'Challenge Deadline Today';
              body = 'Today is the final day for ${challenge.title}!';
              break;
            default:
              continue;
          }

          await _notifications.zonedSchedule(
            '${challenge.id}_deadline_$i'.hashCode,
            title,
            body,
            reminderTime,
            NotificationDetails(
              android: AndroidNotificationDetails(
                'challenge_deadlines',
                'Challenge Deadlines',
                channelDescription: 'Notifications for challenge deadlines',
                importance: Importance.high,
                priority: Priority.high,
                icon: '@mipmap/ic_launcher',
                styleInformation: const BigTextStyleInformation(''),
              ),
              iOS: const DarwinNotificationDetails(
                presentAlert: true,
                presentBadge: true,
                presentSound: true,
              ),
            ),
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
            payload: 'challenge_${challenge.id}',
          );
        }
      }

      _logger.i(
        'Scheduled deadline reminders for challenge: ${challenge.title}',
      );
    } catch (e) {
      _logger.e('Failed to schedule challenge deadline reminder: $e');
    }
  }

  /// Schedule daily insights notification
  Future<void> scheduleDailyInsights() async {
    if (!_initialized) await initialize();

    try {
      final now = tz.TZDateTime.now(tz.local);
      final scheduledTime = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        20, // 8 PM
        0,
      );

      // If time has passed today, schedule for tomorrow
      final actualTime = scheduledTime.isBefore(now)
          ? scheduledTime.add(const Duration(days: 1))
          : scheduledTime;

      await _notifications.zonedSchedule(
        'daily_insights'.hashCode,
        'Daily Insights',
        'Check your wellness summary and achievements!',
        actualTime,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_insights',
            'Daily Insights',
            channelDescription: 'Daily wellness insights and summaries',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
            icon: '@mipmap/ic_launcher',
            styleInformation: const BigTextStyleInformation(''),
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time, // Repeat daily
        payload: 'daily_insights',
      );

      _logger.i('Scheduled daily insights notification at $actualTime');
    } catch (e) {
      _logger.e('Failed to schedule daily insights: $e');
    }
  }

  /// Cancel specific notification
  Future<void> cancelNotification(int id) async {
    try {
      await _notifications.cancel(id);
      _logger.i('Cancelled notification with ID: $id');
    } catch (e) {
      _logger.e('Failed to cancel notification: $e');
    }
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    try {
      await _notifications.cancelAll();
      _logger.i('Cancelled all notifications');
    } catch (e) {
      _logger.e('Failed to cancel all notifications: $e');
    }
  }

  /// Show instant notification
  Future<void> showInstantNotification({
    required String title,
    required String body,
    String? payload,
    String channelId = 'habit_reminders',
  }) async {
    if (!_initialized) await initialize();

    try {
      await _notifications.show(
        DateTime.now().millisecondsSinceEpoch.hashCode,
        title,
        body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            'Instant Notification',
            channelDescription: 'Instant notification',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: payload,
      );

      _logger.i('Showed instant notification: $title');
    } catch (e) {
      _logger.e('Failed to show instant notification: $e');
    }
  }

  /// Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      return await _notifications.pendingNotificationRequests();
    } catch (e) {
      _logger.e('Failed to get pending notifications: $e');
      return [];
    }
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    try {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _notifications
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();

      final bool? grantedNotificationPermission = await androidImplementation
          ?.areNotificationsEnabled();

      return grantedNotificationPermission ?? false;
    } catch (e) {
      _logger.e('Failed to check notification permissions: $e');
      return false;
    }
  }
}
