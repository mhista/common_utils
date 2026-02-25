
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'notification_cubit.dart';
import 'notification_entry.dart';
import 'notification_state.dart';

class NotificationCentrePage extends StatefulWidget {
  final void Function(NotificationEntry entry)? onEntryTap;
  const NotificationCentrePage({super.key, this.onEntryTap});

  @override
  State<NotificationCentrePage> createState() =>
      _NotificationCentrePageState();
}

class _NotificationCentrePageState
    extends State<NotificationCentrePage> {
  @override
  void initState() {
    super.initState();
    // Mark all read when the page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationCubit>().markAllRead();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          BlocSelector<NotificationCubit, NotificationState, bool>(
            selector: (s) => s.isEmpty,
            builder: (context, isEmpty) {
              if (isEmpty) return const SizedBox.shrink();
              return TextButton(
                onPressed: () => _confirmClear(context),
                child: const Text('Clear all'),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<NotificationCubit, NotificationState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.isEmpty) {
            return const _EmptyState();
          }
          final groups = _groupByDate(state.entries);
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: groups.length,
            itemBuilder: (context, i) => _NotificationGroup(
              label: groups[i].label,
              entries: groups[i].entries,
              onTap: (entry) {
                context.read<NotificationCubit>().markRead(entry.id);
                widget.onEntryTap?.call(entry);
              },
              onDismiss: (entry) =>
                  context.read<NotificationCubit>().remove(entry.id),
            ),
          );
        },
      ),
    );
  }

  Future<void> _confirmClear(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear notifications'),
        content: const Text(
            'All notifications will be removed from this device.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<NotificationCubit>().clearAll();
    }
  }

  List<_DateGroup> _groupByDate(List<NotificationEntry> entries) {
    final now = DateTime.now();
    final today = DateUtils.dateOnly(now);
    final yesterday = today.subtract(const Duration(days: 1));
    final grouped = <String, List<NotificationEntry>>{};

    for (final entry in entries) {
      final date = DateUtils.dateOnly(entry.receivedAt);
      final String label;
      if (date == today) {
        label = 'Today';
      } else if (date == yesterday) {
        label = 'Yesterday';
      } else if (now.difference(entry.receivedAt).inDays < 7) {
        label = DateFormat('EEEE').format(entry.receivedAt);
      } else {
        label = DateFormat('d MMM y').format(entry.receivedAt);
      }
      grouped.putIfAbsent(label, () => []).add(entry);
    }

    return grouped.entries
        .map((e) => _DateGroup(label: e.key, entries: e.value))
        .toList();
  }
}

class _DateGroup {
  final String label;
  final List<NotificationEntry> entries;
  _DateGroup({required this.label, required this.entries});
}

class _NotificationGroup extends StatelessWidget {
  final String label;
  final List<NotificationEntry> entries;
  final void Function(NotificationEntry) onTap;
  final void Function(NotificationEntry) onDismiss;

  const _NotificationGroup({
    required this.label,
    required this.entries,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        ...entries.map((e) => _DismissibleEntry(
              entry: e,
              onTap: () => onTap(e),
              onDismiss: () => onDismiss(e),
            )),
      ],
    );
  }
}

class _DismissibleEntry extends StatelessWidget {
  final NotificationEntry entry;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _DismissibleEntry({
    required this.entry,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dismissible(
      key: Key(entry.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: theme.colorScheme.errorContainer,
        child: Icon(Icons.delete_outline,
            color: theme.colorScheme.onErrorContainer),
      ),
      onDismissed: (_) => onDismiss(),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: entry.isRead
                ? Colors.transparent
                : theme.colorScheme.primaryContainer.withOpacity(0.25),
            border: Border(
              bottom: BorderSide(
                color: theme.colorScheme.outlineVariant.withOpacity(0.5),
              ),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Unread dot
              Padding(
                padding: const EdgeInsets.only(top: 6, right: 10),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: entry.isRead
                        ? Colors.transparent
                        : theme.colorScheme.primary,
                  ),
                ),
              ),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (entry.title != null)
                      Text(
                        entry.title!,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: entry.isRead
                              ? FontWeight.normal
                              : FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (entry.body != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        entry.body!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 6),
                    Text(
                      _relativeTime(entry.receivedAt),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant
                            .withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _relativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return DateFormat('h:mm a').format(dt);
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none_outlined,
            size: 72,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Order updates, messages and\npromotions will appear here.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant
                      .withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}
