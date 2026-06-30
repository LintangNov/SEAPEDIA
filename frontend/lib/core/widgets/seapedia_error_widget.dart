import 'package:flutter/material.dart';

class SeapediaErrorWidget extends StatelessWidget {
  final Object error;
  final VoidCallback? onRetry;
  final String? title;

  const SeapediaErrorWidget({
    super.key,
    required this.error,
    this.onRetry,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    String displayMessage = error.toString().replaceAll('Exception: ', '').trim();
    if (displayMessage.toLowerCase().contains('connection') ||
        displayMessage.toLowerCase().contains('timeout') ||
        displayMessage.toLowerCase().contains('socketexception') ||
        displayMessage.toLowerCase().contains('failed host lookup')) {
      displayMessage = 'Please check your internet connection and try again.';
    } else if (displayMessage.toLowerCase().contains('401') ||
        displayMessage.toLowerCase().contains('unauthorized')) {
      displayMessage = 'Your session has expired. Please log in again.';
    } else if (displayMessage.isEmpty) {
      displayMessage = 'An unexpected error occurred. Please try again later.';
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: Colors.redAccent,
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title ?? 'Something Went Wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              displayMessage,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
