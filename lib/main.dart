import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/task_provider.dart';
import 'providers/user_provider.dart';
import 'providers/behavior_tracking_provider.dart';
import 'screens/role_selection_screen.dart';
import 'utils/local_notification_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalNotificationHelper.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => BehaviorTrackingProvider()),
      ],
      child: MaterialApp(
        title: 'Tymko - Student Task Manager',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6366F1),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(elevation: 0, centerTitle: false),
        ),
        initialRoute: '/',
        routes: {'/': (context) => const RoleSelectionScreen()},
      ),
    );
  }
}
