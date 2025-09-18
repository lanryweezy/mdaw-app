import 'package:flutter/material.dart';

/// Widget to show processing status for audio operations
class ProcessingIndicator extends StatelessWidget {
  final bool isProcessing;
  final String? operation;
  final double? progress;

  const ProcessingIndicator({
    super.key,
    required this.isProcessing,
    this.operation,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    if (!isProcessing) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(178),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
          const SizedBox(height: 12),
          Text(
            operation ?? 'Processing...',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (progress != null) ...[
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[800],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ],
        ],
      ),
    );
  }
}

/// Dialog for showing processing status with dismiss option
class ProcessingDialog extends StatelessWidget {
  final String operation;
  final double? progress;
  final VoidCallback? onCancel;

  const ProcessingDialog({
    super.key,
    required this.operation,
    this.progress,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.grey[900],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
          const SizedBox(height: 20),
          Text(
            operation,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          if (progress != null) ...[
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[800],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ],
          const SizedBox(height: 20),
          if (onCancel != null)
            TextButton(
              onPressed: onCancel,
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.red),
              ),
            ),
        ],
      ),
    );
  }
}

/// Snackbar for showing operation results
class ProcessingSnackbar {
  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green[800],
        duration: const Duration(seconds: 2),
      ),
    );
  }

  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.red),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.red[800],
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static void showInfo(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info, color: Colors.blue),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.blue[800],
        duration: const Duration(seconds: 2),
      ),
    );
  }

  static void show(BuildContext context, String message, {Duration? duration}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration ?? const Duration(seconds: 2),
      ),
    );
  }
}
