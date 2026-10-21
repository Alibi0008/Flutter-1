sealed class Countdown {
  const Countdown();
}

final class Upcoming extends Countdown {
  const Upcoming(this.duration);
  final Duration duration;
}

final class Started extends Countdown {
  const Started(this.duration);
  final Duration duration;
}

final class Ended extends Countdown {
  const Ended();
}

Countdown countdownFor(DateTime when, DateTime now) {
  final diff = when.difference(now);
  if (diff.isNegative) {
    final elapsed = now.difference(when);
    if (elapsed < const Duration(hours: 2)) {
      return Started(elapsed);
    }
    return const Ended();
  }
  return Upcoming(diff);
}

String countdownLabel(Countdown countdown) => switch (countdown) {
  Upcoming(:final duration) =>
    duration.inDays > 0
        ? 'In ${duration.inDays}d'
        : duration.inHours > 0
        ? 'In ${duration.inHours}h'
        : 'In ${duration.inMinutes}m',
  Started(:final duration) => 'Started ${duration.inMinutes}m ago',
  Ended() => 'Ended',
};
