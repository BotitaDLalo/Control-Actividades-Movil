import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/views/users/users.dart';
import 'package:aprende_mas/providers/authentication/auth_provider.dart';
import 'package:aprende_mas/providers/notifications/notifications_provider.dart';

class NotificationsStudentScreen extends ConsumerStatefulWidget {
  const NotificationsStudentScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _NoticesStudentScreenState();
}

class _NoticesStudentScreenState extends ConsumerState<NotificationsStudentScreen> {
  @override
  void initState() {
    super.initState();
    // Obtener el userId real del estudiante autenticado usando Riverpod
    Future.microtask(() {
      final authState = ref.read(authProvider);
      final userId = authState.authUser?.userId.toString();
      if (userId != null && userId != "-1") {
        ref.read(notificationsProvider.notifier).getRemoteNotices(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const NotificationsScreen();
  }
}