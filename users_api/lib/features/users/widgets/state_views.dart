import 'package:flutter/material.dart';

import '../../../core/api/api_exception.dart';

String errorText(ApiException e) => switch (e) {
  NoConnectionException() => 'No connection. Check the network.',
  NotFoundException() => 'Not found.',
  UnauthorizedException() => 'Not authorized.',
  ServerException(:final status) => 'Server error ($status).',
  BadResponseException() => 'The server sent something we cannot read.',
};

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator());
}

class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.text, this.onRetry});

  final IconData icon;
  final String text;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 56),
          const SizedBox(height: 12),
          Text(text, textAlign: TextAlign.center),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ],
      ),
    ),
  );
}

class Offline extends StatelessWidget {
  const Offline({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) =>
      _Message(icon: Icons.wifi_off, text: 'No connection', onRetry: onRetry);
}

class ServerError extends StatelessWidget {
  const ServerError(this.status, {super.key, required this.onRetry});

  final int status;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => _Message(
    icon: Icons.cloud_off,
    text: 'Server error ($status)',
    onRetry: onRetry,
  );
}

class RequestError extends StatelessWidget {
  const RequestError(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) =>
      _Message(icon: Icons.error_outline, text: text);
}

class GenericError extends StatelessWidget {
  const GenericError({super.key});

  @override
  Widget build(BuildContext context) => const _Message(
    icon: Icons.bug_report_outlined,
    text: 'We could not read the server response.',
  );
}
