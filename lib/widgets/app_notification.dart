import 'package:awesome_notifications/awesome_notifications.dart';

class AppNotification {
  @pragma("vm:entry-point")
  static Future<void> onNotificationCreatedMethod(
      ReceivedNotification receivedNotification) async {}
  @pragma("vm:entry-point")
  static Future<void> onNotificationDisplayedMethod(
      ReceivedNotification receivedNotification) async {}
  @pragma("vm:entry-point")
  static Future<void> onNotificationDismissedMethod(
      ReceivedNotification receivedNotification) async {}
  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(
      ReceivedNotification receivedNotification) async {}
}
