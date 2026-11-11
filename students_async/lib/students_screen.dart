import 'package:flutter/material.dart';

import 'api/fake_api.dart';
import 'widgets/empty_view.dart';
import 'widgets/error_view.dart';
import 'widgets/loading_view.dart';
import 'widgets/student_list.dart';

/// Level 2: the four states by hand (loading, error, empty, data).
/// Level 5: the Save button.
class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  List<Student>? _students; // null = not loaded yet
  Object? _error; // non-null = failed
  // Use FakeApi(empty: true) once to see the empty state.
  final _api = FakeApi();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    // initState is synchronous: the framework will not wait, so we do not
    // await. _load() reports its result through setState.
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _students = null;
      _error = null;
    });
    try {
      final list = await _api.fetchStudents();
      // The line after await runs LATER: the screen may be gone.
      if (!mounted) return;
      setState(() => _students = list);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget body;
    if (_error != null) {
      body = ErrorView(onRetry: _load);
    } else if (_students == null) {
      body = const LoadingView();
    } else if (_students!.isEmpty) {
      body = const EmptyView();
    } else {
      body = StudentList(_students!);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('By hand')),
      body: body,
      floatingActionButton: FloatingActionButton(
        // Disabled while loading and while a save is in flight.
        // Level 5, the honest version: this is a callback, not a State
        // method, so we guard with context.mounted after every await.
        // Pop only on success, show the message only on failure.
        onPressed: (_students == null || _saving)
            ? null
            : () async {
          final n = _students!.length;
          setState(() => _saving = true);
          try {
            await _api.save(n);
            if (!context.mounted) return;
            Navigator.pop(context);
          } on StateError catch (e) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(e.message)),
            );
          } finally {
            if (mounted) setState(() => _saving = false);
          }
        },
        child: _saving
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        )
            : const Icon(Icons.save),
      ),
    );
  }
}