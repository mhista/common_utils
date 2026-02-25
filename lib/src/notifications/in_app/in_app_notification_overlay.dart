// Toast widget — no state management changes needed here.
// InAppNotificationController wires into the Cubit via addFromPayload().
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../notification_payload.dart';
import 'notification_cubit.dart';

// ── Controller ────────────────────────────────────────────────────────────────

class InAppNotificationController {
  InAppNotificationController._();
  static final InAppNotificationController instance =
      InAppNotificationController._();

  OverlayState? _overlay;
  OverlayEntry? _current;
  Timer? _timer;
  NotificationCubit? _cubit;

  void attach(OverlayState overlay, NotificationCubit cubit) {
    _overlay = overlay;
    _cubit = cubit;
  }

  /// Show a toast from a payload and persist to the cubit store.
  Future<void> showFromPayload(
    NotificationPayload payload, {
    Duration duration = const Duration(seconds: 4),
    VoidCallback? onTap,
  }) async {
    // Persist to cubit (drives badge + notification centre)
    await _cubit?.addFromPayload(payload);

    _show(
      title: payload.title ?? '',
      body: payload.body ?? '',
      type: payload.type,
      duration: duration,
      onTap: onTap,
    );
  }

  /// Show a toast for an in-app event (follow, promo trigger, etc.)
  /// Pass [persistToStore: false] if this is purely ephemeral.
  Future<void> show({
    required String title,
    required String body,
    String? type,
    Duration duration = const Duration(seconds: 4),
    VoidCallback? onTap,
    bool persistToStore = true,
  }) async {
    if (persistToStore) {
      // Build a minimal payload so it lands in the notification centre
      await _cubit?.addFromPayload(
        NotificationPayload.local(
          title: title,
          body: body,
          type: type ?? 'general',
        ),
      );
    }

    _show(
      title: title,
      body: body,
      type: type,
      duration: duration,
      onTap: onTap,
    );
  }

  void _show({
    required String title,
    required String body,
    String? type,
    required Duration duration,
    VoidCallback? onTap,
  }) {
    if (_overlay == null) {
      debugPrint('⚠️ InAppNotificationController: not attached yet');
      return;
    }
    _dismiss();

    _current = OverlayEntry(
      builder: (context) => _NotificationToast(
        title: title,
        body: body,
        type: type,
        onTap: () {
          _dismiss();
          onTap?.call();
        },
        onDismiss: _dismiss,
      ),
    );

    _overlay!.insert(_current!);
    _timer = Timer(duration, _dismiss);
  }

  void _dismiss() {
    _timer?.cancel();
    _timer = null;
    _current?.remove();
    _current = null;
  }
}


// ── Overlay widget ────────────────────────────────────────────────────────────

/// Wrap your MaterialApp builder with this.
///
/// ```dart
/// MaterialApp.router(
///   builder: (context, child) => InAppNotificationOverlay(child: child!),
/// )
/// ```
class InAppNotificationOverlay extends StatefulWidget {
  final Widget child;
  const InAppNotificationOverlay({super.key, required this.child});

  @override
  State<InAppNotificationOverlay> createState() =>
      _InAppNotificationOverlayState();
}

class _InAppNotificationOverlayState
    extends State<InAppNotificationOverlay> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Read the cubit provided by your app's BlocProvider tree
      final cubit = context.read<NotificationCubit>();
      InAppNotificationController.instance
          .attach(Overlay.of(context), cubit);
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

// ── Toast UI ──────────────────────────────────────────────────────────────────

class _NotificationToast extends StatefulWidget {
  final String title;
  final String body;
  final String? type;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _NotificationToast({
    required this.title,
    required this.body,
    this.type,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  State<_NotificationToast> createState() => _NotificationToastState();
}

class _NotificationToastState extends State<_NotificationToast>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _fade = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _slideOut() async {
    await _ctrl.reverse();
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final safeTop = MediaQuery.of(context).padding.top;
    final iconData = _iconForType(widget.type);
    final iconColor = _colorForType(widget.type, theme);

    return Positioned(
      top: safeTop + 8,
      left: 16,
      right: 16,
      child: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: widget.onTap,
              onVerticalDragUpdate: (d) {
                if (d.delta.dy < -5) _slideOut();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                  border: Border.all(
                    color:
                        theme.colorScheme.outlineVariant.withOpacity(0.5),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: iconColor.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child:
                          Icon(iconData, color: iconColor, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.title.isNotEmpty)
                            Text(
                              widget.title,
                              style: theme.textTheme.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          if (widget.body.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              widget.body,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color:
                                    theme.colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: _slideOut,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Icon(Icons.close,
                            size: 16,
                            color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


  IconData _iconForType(String? type) {
    switch (type) {
      case 'new_order':
      case 'order_update':
      case 'order_shipped':
      case 'order_delivered':
      case 'order_confirmed':
        return Icons.shopping_bag_outlined;
      case 'new_follower':
      case 'follow':
        return Icons.person_add_outlined;
      case 'new_message':
      case 'chat_reply':
        return Icons.chat_bubble_outline;
      case 'flash_sale':
      case 'promo':
        return Icons.local_offer_outlined;
      case 'low_stock':
      case 'out_of_stock':
        return Icons.inventory_2_outlined;
      case 'payout_processed':
      case 'withdrawal_success':
        return Icons.account_balance_wallet_outlined;
      case 'price_drop':
        return Icons.trending_down;
      case 'back_in_stock':
        return Icons.check_circle_outline;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _colorForType(String? type, ThemeData theme) {
    switch (type) {
      case 'new_order':
      case 'order_shipped':
      case 'order_delivered':
        return Colors.green;
      case 'low_stock':
      case 'out_of_stock':
        return Colors.orange;
      case 'flash_sale':
      case 'promo':
      case 'price_drop':
        return Colors.purple;
      case 'new_message':
      case 'chat_reply':
      case 'new_follower':
        return Colors.blue;
      case 'payout_processed':
      case 'withdrawal_success':
        return Colors.teal;
      default:
        return theme.colorScheme.primary;
    }
  }

