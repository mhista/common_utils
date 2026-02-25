
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'notification_cubit.dart';
import 'notification_state.dart';

/// Drop-in badge for any nav icon. Reads from [NotificationCubit].
///
/// ```dart
/// NavigationDestination(
///   icon: NotificationBadge(child: Icon(Icons.notifications_outlined)),
///   selectedIcon: NotificationBadge(child: Icon(Icons.notifications)),
///   label: 'Notifications',
/// )
/// ```
class NotificationBadge extends StatelessWidget {
  final Widget child;
  const NotificationBadge({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<NotificationCubit, NotificationState, int>(
      selector: (state) => state.unreadCount,
      builder: (context, count) {
        if (count == 0) return child;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            child,
            Positioned(
              top: -4,
              right: -4,
              child: _Badge(count: count),
            ),
          ],
        );
      },
    );
  }
}

class _Badge extends StatelessWidget {
  final int count;
  const _Badge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.error,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.surface,
          width: 1.5,
        ),
      ),
      child: Text(
        count > 99 ? '99+' : '$count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.bold,
          height: 1,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

