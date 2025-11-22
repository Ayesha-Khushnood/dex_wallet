import '../../../../../data/base_vm.dart';

class NotificationsVM extends BaseVM {
  List<NotificationItem> _notifications = [
    NotificationItem(
      date: "Sep 13, 2024",
      title: "You have been Reimbursed",
      description: "Your wallet was impacted by an IOS app issue affecting some Optimism transaction. The affective transaction ha.",
    ),
    NotificationItem(
      title: "Notify this test push in CC pls",
      description: "Notify this test push by backend team pls",
    ),
    NotificationItem(
      date: "Dec 03, 2023",
      title: "BTC Tops \$40k!",
      description: "Buy, sell, or swap BTC in-app with our trusted partners. Explore now! →",
    ),
  ];

  List<NotificationItem> get notifications => _notifications;

  void markAsRead(int index) {
    // Handle marking notification as read
    notifyListeners();
  }

  void clearAllNotifications() {
    _notifications.clear();
    notifyListeners();
  }
}

class NotificationItem {
  final String? date;
  final String title;
  final String description;

  NotificationItem({
    this.date,
    required this.title,
    required this.description,
  });
}
