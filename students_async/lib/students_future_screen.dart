import 'package:flutter/material.dart';

import 'api/fake_api.dart';
import 'widgets/empty_view.dart';
import 'widgets/error_view.dart';
import 'widgets/loading_view.dart';
import 'widgets/student_list.dart';

/// Level 3: the same screen with FutureBuilder.
class StudentsFutureScreen extends StatefulWidget {
  const StudentsFutureScreen({super.key});

  @override
  State<StudentsFutureScreen> createState() => _StudentsFutureScreenState();
}

class _StudentsFutureScreenState extends State<StudentsFutureScreen> {
  final _api = FakeApi();

  // Stored once in initState and NEVER created in build. Not `final`,
  // because _retry is the one place that is allowed to replace it.
  late Future<List<Student>> _future;

  bool _compact = false;

  @override
  void initState() {
    super.initState();
    _future = _api.fetchStudents();
  }

  // The only place a new Future may be created: the user asked for a
  // new request. Everywhere else the build must reuse the stored field.
  void _retry() {
    setState(() => _future = _api.fetchStudents());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FutureBuilder'),
        actions: [
          Switch(
            value: _compact,
            onChanged: (v) => setState(() => _compact = v),
          ),
        ],
      ),
      body: FutureBuilder<List<Student>>(
        future: _future, // the field, never a call
        builder: (context, snapshot) {
          // Order matters: error first, otherwise an error shows a
          // spinner forever.
          if (snapshot.hasError) {
            return ErrorView(onRetry: _retry);
          }
          if (snapshot.connectionState != ConnectionState.done) {
            return const LoadingView();
          }
          final list = snapshot.data ?? const [];
          if (list.isEmpty) {
            return const EmptyView();
          }
          return StudentList(list, compact: _compact);
        },
      ),
    );
  }
}
