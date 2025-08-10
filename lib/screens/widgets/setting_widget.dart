import 'package:flutter/material.dart';

class SettingWidget extends StatelessWidget {
  final String title;
  final IconData icon;

  const SettingWidget({super.key, required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 12),
            Text(title, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
        IconButton(onPressed: () {}, icon: Icon(Icons.chevron_right)),
      ],
    );
  }
}
