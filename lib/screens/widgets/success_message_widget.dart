import 'package:flutter/material.dart';

class SuccessMessageWidget extends StatelessWidget {
  final String successMessage;
  const SuccessMessageWidget({super.key, required this.successMessage});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.green),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              successMessage,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: Colors.green,
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
