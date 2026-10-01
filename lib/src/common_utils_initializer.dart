import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'medias/downloads/download_cubit.dart';
import 'notifications/common_notification_service.dart';
import 'notifications/in_app/notification_cubit.dart';
import 'notifications/notification_config.dart';

/// One-call setup for the stateful features of common_utils2.
///
/// ```dart
/// final utils = await CommonUtilsInitializer.initialize(
///   notificationConfig: NotificationConfig.withDefaults(...),
///   notificationScope: lastActiveAccountId, // optional, per-account inbox
/// );
/// runApp(MultiBlocProvider(providers: utils.providers, child: const App()));
/// ```
class CommonUtilsInitializer {
  final NotificationCubit? notificationCubit;
  final DownloadCubit? downloadCubit;
  final StreamSubscription<dynamic>? _inboxPipe;

  CommonUtilsInitializer._({
    this.notificationCubit,
    this.downloadCubit,
    StreamSubscription<dynamic>? inboxPipe,
  }) : _inboxPipe = inboxPipe;

  /// Initialize all common_utils features.
  ///
  /// * [notificationConfig] — required for push notifications. When null, only
  ///   the in-app inbox ([NotificationCubit]) is created.
  /// * [enableDownloads] — create the download manager (default: true).
  /// * [enableNotifications] — create the in-app inbox (default: true).
  /// * [notificationScope] — storage scope for the in-app inbox (e.g. the
  ///   active account ID). Change later with `notificationCubit.switchScope`.
  /// * [pipeForegroundToInbox] — when true (default) every foreground push is
  ///   also saved to the in-app inbox so badges and the notification centre
  ///   stay in sync without extra wiring.
  static Future<CommonUtilsInitializer> initialize({
    NotificationConfig? notificationConfig,
    bool enableDownloads = true,
    bool enableNotifications = true,
    String? notificationScope,
    bool pipeForegroundToInbox = true,
  }) async {
    NotificationCubit? notificationCubit;
    DownloadCubit? downloadCubit;
    StreamSubscription<dynamic>? pipe;

    if (enableNotifications) {
      if (notificationConfig != null) {
        await CommonNotificationService.instance.initialize(notificationConfig);
      }

      notificationCubit = NotificationCubit(scope: notificationScope);
      await notificationCubit.initialize();

      if (pipeForegroundToInbox &&
          CommonNotificationService.instance.isInitialized) {
        final cubit = notificationCubit;
        pipe = CommonNotificationService.instance.messages.listen(
          cubit.addFromPayload,
        );
      }
    }

    if (enableDownloads) {
      downloadCubit = DownloadCubit();
    }

    return CommonUtilsInitializer._(
      notificationCubit: notificationCubit,
      downloadCubit: downloadCubit,
      inboxPipe: pipe,
    );
  }

  /// Providers to merge with your app's providers.
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

  /// Wraps [child] in a [MultiBlocProvider] with [providers].
  Widget provideCubits({required Widget child}) {
    if (providers.isEmpty) return child;
    return MultiBlocProvider(providers: providers, child: child);
  }

  /// Stop piping foreground messages into the inbox.
  Future<void> dispose() async => _inboxPipe?.cancel();
}
