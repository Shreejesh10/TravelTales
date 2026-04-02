import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:traveltales/api/notification/notificationService.dart';
import 'package:traveltales/core/ui/components/app_flushbar.dart';
import 'package:traveltales/core/ui/resources/theme/appColors.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late Future<List<NotificationInboxItem>> _notificationsFuture;

  @override
  void initState() {
    super.initState();
    _notificationsFuture = NotificationService.instance.getInboxItems();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationService.instance.markAllAsRead();
    });
  }

  Future<void> _reload() async {
    final future = NotificationService.instance.getInboxItems();
    setState(() {
      _notificationsFuture = future;
    });
    await future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        actions: [
          IconButton(
            onPressed: _reload,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<List<NotificationInboxItem>>(
        future: _notificationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  "Couldn't load notifications.",
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final notifications = snapshot.data ?? const <NotificationInboxItem>[];
          if (notifications.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  "No notifications yet.",
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _reload,
            backgroundColor: Colors.white,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = notifications[index];
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () async {
                      final opened = await NotificationService.instance
                          .openInboxItem(item);
                      if (!mounted || opened) return;
                      AppFlushbar.error(context, "This event is no longer available");
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.getContainerBoxColor(context),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Theme.of(context).dividerColor.withOpacity(0.4),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title.isEmpty ? "Travel Tales" : item.title,
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.body.isEmpty
                                ? "You received a notification."
                                : item.body,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            DateFormat(
                              "MMM d, yyyy - h:mm a",
                            ).format(item.receivedAt.toLocal()),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
