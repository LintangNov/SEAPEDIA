import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'core/router/app_router.dart';
import 'features/auth/presentation/auth_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const storage = FlutterSecureStorage();
  final token = await storage.read(key: 'accessToken');
  final hasToken = token != null && token.isNotEmpty;

  final container = ProviderContainer();

  container.read(authControllerProvider.notifier).checkStatus(hasToken);

  runApp(
    UncontrolledProviderScope(container: container, child: const SeapediaApp()),
  );
}

class SeapediaApp extends ConsumerWidget {
  const SeapediaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'Seapedia',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}
