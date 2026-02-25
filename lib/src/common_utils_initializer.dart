import 'package:common_utils2/common_utils2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'medias/downloads/download_cubit.dart';

class CommonUtilsInitializer {
  final NotificationCubit? notificationCubit;
  final DownloadCubit? downloadCubit;

  CommonUtilsInitializer._({this.notificationCubit, this.downloadCubit});

  /// Initialize all common_utils features.
  ///
  /// [notificationConfig] - Required for push notifications
  /// [enableDownloads] - Enable download manager (default: true)
  /// [enableNotifications] - Enable in-app notifications (default: true)
  static Future<CommonUtilsInitializer> initialize({
    NotificationConfig? notificationConfig,
    bool enableDownloads = true,
    bool enableNotifications = true,
  }) async {
    NotificationCubit? notificationCubit;
    DownloadCubit? downloadCubit;

    // Initialize notifications
    if (enableNotifications) {
      if (notificationConfig != null) {
        await CommonNotificationService.instance.initialize(notificationConfig);
      }

      notificationCubit = NotificationCubit();
      await notificationCubit.initialize();
    }

    // Initialize downloads
    if (enableDownloads) {
      downloadCubit = DownloadCubit();
    }

    return CommonUtilsInitializer._(
      notificationCubit: notificationCubit,
      downloadCubit: downloadCubit,
    );
  }

  /// Get list of common_utils providers to merge with your app providers
  List<BlocProvider> get providers {
    final list = <BlocProvider>[];

    if (notificationCubit != null) {
      list.add(
        BlocProvider<NotificationCubit>.value(value: notificationCubit!),
      );
    }

    if (downloadCubit != null) {
      list.add(BlocProvider<DownloadCubit>.value(value: downloadCubit!));
    }

    return list;
  }

  /// Original method - still works
  Widget provideCubits({required Widget child}) {
    if (providers.isEmpty) return child;
    return MultiBlocProvider(providers: providers, child: child);
  }
}
