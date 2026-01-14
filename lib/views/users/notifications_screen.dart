import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/models/models.dart';
import 'package:aprende_mas/providers/providers.dart';
import 'package:aprende_mas/views/widgets/widgets.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  NoticesScreenState createState() => NoticesScreenState();
}

class NoticesScreenState extends ConsumerState<NotificationsScreen> {
  @override
  void initState() {
    super.initState();

    ref.read(notificationsProvider.notifier).getLsNotices();
  }


String formatDateFriendly(String dateString) {
  final date = DateTime.parse(dateString);
  final now = DateTime.now();

  if (DateUtils.isSameDay(date, now)) {
    return 'Hoy a las ${DateFormat('HH:mm').format(date)}';
  } else {
    return '${DateFormat('dd/MM/yyyy').format(date)} a las ${DateFormat('HH:mm').format(date)}';
  }
}




  @override
  Widget build(BuildContext context) {
    final lsNotices = ref.watch(notificationsProvider);
    final noticesNotifier = ref.read(notificationsProvider.notifier);
   
   
    showModalBottom(String sentDate) {
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(16), // Bordes redondeados
          ),
        ),
        builder: (BuildContext context) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: SvgPicture.asset('assets/icons/eliminar1.svg', width: 24, height: 24),
                  title: const Text('Eliminar notificación'),
                  onTap: () {
                    noticesNotifier.deleteNotification(sentDate);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          );
        },
      );
    }

    return Scaffold(
      body: Row(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: lsNotices.length,
              itemBuilder: (BuildContext context, int index) {
                final notification = lsNotices[index];
                return GestureDetector(
                    onLongPress: () {
                      showModalBottom(notification.sentDate);
                    },
                    child: ElementTile(
                      icon: Icons.notifications,
                      iconSize: 28,
                      iconColor: Colors.white,
                      title: notification.title,
                      subtitle: formatDateFriendly(notification.sentDate),
                      onTapFunction: () {
                        NotificationModel notice = NotificationModel(
                            messageId: notification.messageId,
                            title: notification.title,
                            body: notification.body,
                            sentDate: notification.sentDate);
                        context.push('/notification-content', extra: notice);
                      },
                    ));
              },
            ),
          ),
        ],
      ),
    );
  }
}
