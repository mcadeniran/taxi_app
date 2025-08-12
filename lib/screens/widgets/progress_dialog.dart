import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taxi_app/controllers/theme_provider.dart';
import 'package:taxi_app/utils/colors.dart';

class ProgressDialog extends StatelessWidget {
  final String message;
  const ProgressDialog({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    bool isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    return Dialog(
      // backgroundColor: Colors.black54,
      backgroundColor: isDark ? AppColors.darkLayer : AppColors.lightLayer,
      child: Container(
        margin: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkLayer : AppColors.lightLayer,
          // borderRadius: BorderRadius.circular(2),
        ),
        child: Row(
          children: [
            SizedBox(width: 6),
            CircularProgressIndicator.adaptive(
              backgroundColor: isDark ? Colors.white : Colors.black,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),
            SizedBox(width: 26),
            Text(
              message,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
