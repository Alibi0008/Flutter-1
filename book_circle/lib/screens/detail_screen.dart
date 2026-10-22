import 'dart:async';

import 'package:flutter/material.dart';

import '../models/book.dart';
import '../models/profile.dart';
import '../utils/countdown.dart';
import '../utils/format.dart';
import '../widgets/empty_state.dart';

class DetailArgs {
  const DetailArgs({
    required this.book,
    required this.profile,
    required this.onChange,
    required this.onDelete,
    required this.onEdit,
    required this.onSwitchToProfile,
  });

  final Book book;
  final Profile profile;
  final ValueChanged<Book> onChange;
  final ValueChanged<String> onDelete;
  final Future<Book?> Function(Book book) onEdit;
  final VoidCallback onSwitchToProfile;
}

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key, required this.args});

  final DetailArgs args;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Book _book;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _book = widget.args.book;
    // R13: countdown updates from a one-minute Timer.periodic cancelled in dispose
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    // R13: cancelled in dispose; leaving the screen prints nothing
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _handlePrimaryAction() async {
    // R15: with an empty profile name shows SnackBar whose action switches to profile tab
    if (widget.args.profile.name.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Add your name in Profile first.'),
          action: SnackBarAction(
            label: 'Profile',
            onPressed: () {
              Navigator.pop(context);
              widget.args.onSwitchToProfile();
            },
          ),
        ),
      );
      return;
    }

    final isRegistered = _book.contains(widget.args.profile.name);
    final actionName = isRegistered ? 'Return' : 'Borrow';

    // R15: asks with showDialog<bool> and acts on true
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('$actionName book?'),
        content: Text(
          isRegistered
              ? 'Do you want to return "${_book.title}"?'
              : 'Do you want to borrow a copy of "${_book.title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(actionName),
          ),
        ],
      ),
    );

    // R14: check mounted after await before setState / callbacks
    if (confirmed == true && mounted) {
      final names = [..._book.borrowerNames];
      if (isRegistered) {
        names.remove(widget.args.profile.name);
      } else {
        names.add(widget.args.profile.name);
      }
      final updated = _book.copyWith(borrowerNames: names);
      setState(() => _book = updated);
      widget.args.onChange(updated);
    }
  }

  Future<void> _handleDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete book?'),
        content: Text('Are you sure you want to delete "${_book.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    // R14: check mounted before Navigator.pop
    if (confirmed == true && mounted) {
      widget.args.onDelete(_book.id);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // R5: Destructuring record getter places
    final (:taken, :free) = _book.places;
    final colorScheme = Theme.of(context).colorScheme;
    final isRegistered =
        widget.args.profile.name.isNotEmpty &&
        _book.contains(widget.args.profile.name);

    // R16: Buttons that cannot act use onPressed: null
    final canAct = !_book.isPast && (isRegistered || !_book.isFull);

    // R29: DefaultTabController + TabBar + TabBarView
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        // R31: Nobody writes a back arrow: no BackButton, no leading: anywhere.
        appBar: AppBar(
          title: Text(_book.title),
          actions: [
            PopupMenuButton<String>(
              onSelected: (action) async {
                if (action == 'edit') {
                  final updated = await widget.args.onEdit(_book);
                  if (updated != null && mounted) {
                    setState(() => _book = updated);
                  }
                } else if (action == 'delete') {
                  _handleDelete();
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'edit', child: Text('Edit')),
                PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ],
          bottom: TabBar(
            tabs: [
              const Tab(text: 'About'),
              // R29: the count in the tab label is live
              Tab(text: 'Readers (${_book.count})'),
            ],
          ),
        ),
        body: Column(
          children: [
            // R24: Stack header with image from assets/, icon, category chip and countdown chip
            SizedBox(
              height: 170,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset('assets/book_cover.png', fit: BoxFit.cover),
                  Container(color: colorScheme.scrim.withValues(alpha: 0.35)),
                  Center(
                    child: CircleAvatar(
                      radius: 34,
                      backgroundColor: _book.category.colorOf(colorScheme),
                      foregroundColor: colorScheme.onPrimary,
                      child: Icon(_book.category.icon, size: 36),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Chip(
                      avatar: Icon(_book.category.icon, size: 16),
                      label: Text(_book.category.label),
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Chip(
                      label: Text(
                        // R9: countdown sealed class rendered by exhaustive switch
                        countdownLabel(
                          countdownFor(_book.meetingAt, DateTime.now()),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // Tab 1: About (date, place, places, optional text)
                  ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Text(
                        _book.title,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 12),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.event),
                        title: Text(formatDate(_book.meetingAt)),
                        subtitle: const Text('Meeting schedule'),
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          _book.isDigital ? Icons.link : Icons.place,
                        ),
                        title: Text(_book.location),
                        subtitle: Text(
                          _book.isDigital ? 'Online link' : 'Location / Shelf',
                        ),
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.people_outline),
                        // R5: destructured places used here
                        title: Text('$taken borrowed, $free available'),
                        subtitle: Text('Capacity: ${_book.copyLimit} copies'),
                      ),
                      // R6: Optional text shown with collection if
                      if (_book.description case final desc?) ...[
                        const Divider(height: 24),
                        Text(
                          desc,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ],
                  ),
                  // Tab 2: Readers list with "You" highlighted
                  _book.borrowerNames.isEmpty
                      ? const EmptyState(
                          icon: Icons.people_outline,
                          message: 'Nobody borrowed this book yet',
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: _book.borrowerNames.length,
                          itemBuilder: (context, index) {
                            final name = _book.borrowerNames[index];
                            final isYou =
                                widget.args.profile.name.isNotEmpty &&
                                name == widget.args.profile.name;

                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: isYou
                                    ? colorScheme.primary
                                    : colorScheme.surfaceContainerHighest,
                                foregroundColor: isYou
                                    ? colorScheme.onPrimary
                                    : colorScheme.onSurfaceVariant,
                                child: const Icon(Icons.person),
                              ),
                              title: Text(
                                isYou ? '$name (You)' : name,
                                style: isYou
                                    ? Theme.of(context).textTheme.titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: colorScheme.primary,
                                          )
                                    : null,
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton(
              onPressed: canAct ? _handlePrimaryAction : null,
              child: Text(isRegistered ? 'Return book' : 'Borrow book'),
            ),
          ),
        ),
      ),
    );
  }
}
