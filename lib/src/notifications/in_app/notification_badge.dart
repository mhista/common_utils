
import 'package:material_ui/material_ui.dart';
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

  /// When set, only unread entries of this channel/category are counted.
  final String? channelId;

  const NotificationBadge({super.key, required this.child, this.channelId});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<NotificationCubit, NotificationState, int>(
      selector: (state) => channelId == null
          ? state.unreadCount
          : state.unreadCountFor(channelId!),
      builder: (context, count) {
        if (count == 0) return child;
        return Semantics(
          label: '$count unread notification${count == 1 ? '' : 's'}',
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              child,
              Positioned(
                top: -4,
                right: -4,
                child: ExcludeSemantics(child: _Badge(count: count)),
              ),
            ],
          ),
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
        style: TextStyle(
          color: Theme.of(context).colorScheme.onError,
          fontSize: 9,
          fontWeight: FontWeight.bold,
          height: 1,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

