import 'package:aprende_mas/config/environment/environment.dart';
import 'package:aprende_mas/config/router/router.dart';
import 'package:aprende_mas/config/utils/app_theme.dart';
import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/config/services/services.dart';
import 'package:aprende_mas/models/models.dart';
import 'package:aprende_mas/providers/data/connectivity_provider.dart';
import 'package:aprende_mas/providers/providers.dart';
import 'package:aprende_mas/views/widgets/snackbars/no_internet_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {
  await Environment.initEnvironment();
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  await FirebaseCMConfiguration.initializeFCM();
  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  void onNewNotice(WidgetRef ref) {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        final notices = ref.read(notificationsProvider.notifier);
        NotificationModel notice = FirebaseCM.onNewMessage(message);
        notices.onNewNotice(notice);
      }
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appRouter = ref.watch(goRouterProvider);
    final isConnected = ref.watch(connectivityStatusProvider);
    onNewNotice(ref);
    
    return MaterialApp.router(
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
      theme: AppTheme().theme(),
      builder: (context, child) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!isConnected) {
            NoInternetSnackBar.show(context);
          } else {
            NoInternetSnackBar.hide(context);
          }
        });
        return child!;
      },
    );
  }
}
