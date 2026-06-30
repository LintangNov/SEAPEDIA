import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/driver_models.dart';
import '../data/driver_repository.dart';
import 'driver_history_screen.dart';

class DriverDashboardController extends AsyncNotifier<DriverProfileData> {
  @override
  FutureOr<DriverProfileData> build() async {
    return ref.watch(driverRepositoryProvider).getProfile();
  }

  Future<void> completeJob(String orderId) async {
    await AsyncValue.guard(() async {
      await ref.read(driverRepositoryProvider).completeJob(orderId);
      ref.invalidateSelf();
      ref.invalidate(driverHistoryProvider); // Reload delivery history in real-time
    });
  }
}

final driverDashboardProvider = AsyncNotifierProvider.autoDispose<DriverDashboardController, DriverProfileData>(
  DriverDashboardController.new,
);