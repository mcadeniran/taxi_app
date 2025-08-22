import 'package:flutter/material.dart';

class ErrorMessageWidget extends StatelessWidget {
  final String localErrorMessage;
  const ErrorMessageWidget({super.key, required this.localErrorMessage});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.red[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              localErrorMessage,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      ),
    );
  }
}
