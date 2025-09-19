import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studio_wiz/view_models/daw_view_model.dart';

class AIToolButton extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onPressed;

  const AIToolButton({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<DawViewModel>(
      builder: (context, viewModel, child) {
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Icon(icon, color: Colors.white),
          ),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(description),
          trailing: ElevatedButton(
            onPressed: viewModel.isProcessing ? null : onPressed,
            child: viewModel.isProcessing
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Apply'),
          ),
        );
      },
    );
  }
}
