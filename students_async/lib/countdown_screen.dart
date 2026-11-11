import 'dart:async';

import 'package:flutter/material.dart';

import 'api/countdown.dart';

/// Level 4: a countdown two ways.
class CountdownScreen extends StatefulWidget {
  const CountdownScreen({super.key});

  @override
  State<CountdownScreen> createState() => _CountdownScreenState();
}

class _CountdownScreenState extends State<CountdownScreen> {
  bool _versionA = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Countdown')),
      body: Column(
        children: [
          const SizedBox(height: 16),
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: true, label: Text('A: StreamBuilder')),
              ButtonSegment(value: false, label: Text('B: listen')),
            ],
            selected: {_versionA},
            onSelectionChanged: (s) => setState(() => _versionA = s.first),
          ),
          Expanded(
            child: Center(
              // Each version is its own widget, so switching restarts it
              // (a single-subscription stream cannot be listened to twice).
              child: _versionA ? const _CountdownA() : const _CountdownB(),
            ),
          ),
        ],
      ),
    );
  }
}

/// Version A: StreamBuilder subscribes and cancels for us.
class _CountdownA extends StatefulWidget {
  const _CountdownA();

  @override
  State<_CountdownA> createState() => _CountdownAState();
}

class _CountdownAState extends State<_CountdownA> {
  late final Stream<int> _stream = countdown(10);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: _stream,
      builder: (context, snapshot) {
        return Text(
          '${snapshot.data ?? 10}',
          style: Theme.of(context).textTheme.displayLarge,
        );
      },
    );
  }
}

/// Version B: manual listen(), so we must cancel in dispose.
class _CountdownB extends StatefulWidget {
  const _CountdownB();

  @override
  State<_CountdownB> createState() => _CountdownBState();
}

class _CountdownBState extends State<_CountdownB> {
  int _left = 10;
  late StreamSubscription<int> _sub;

  @override
  void initState() {
    super.initState();
    _sub = countdown(10).listen((i) => setState(() => _left = i));
  }

  @override
  void dispose() {
    // Without this line the generator keeps ticking for a dead screen
    // and setState() is called after dispose().
    _sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      '$_left',
      style: Theme.of(context).textTheme.displayLarge,
    );
  }
}
