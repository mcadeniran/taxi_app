import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:provider/provider.dart';
import 'package:taxi_app/controllers/theme_provider.dart';
import 'package:taxi_app/utils/colors.dart';

InputDecoration inputDecoration({
  String? hint,
  String? prefixIcon,
  bool useTheme = true,
  required BuildContext context,
}) {
  final bool isDark = useTheme
      ? Provider.of<ThemeProvider>(context).isDarkMode
      : false; // Force light theme when useTheme is false

  return InputDecoration(
    hintText: hint,
    prefixIcon: prefixIcon != null
        ? Padding(
            padding: const EdgeInsets.all(14.0),
            child: Iconify(
              prefixIcon,
              size: 14,
              color: isDark ? Colors.white : AppColors.primary,
            ),
          )
        : null,
    labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
    hintStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
    floatingLabelStyle: TextStyle(
      color: useTheme
          ? (isDark ? Colors.white.withValues(alpha: 0.85) : AppColors.primary)
          : Colors.black,
    ),
    prefixIconColor: AppColors.primary,
    border: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: const BorderRadius.all(Radius.circular(8)),
      borderSide: BorderSide(
        color: isDark ? AppColors.border : AppColors.primary,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: const BorderRadius.all(Radius.circular(8)),
      borderSide: BorderSide(
        color: isDark ? AppColors.border : AppColors.primary,
        width: 2,
      ),
    ),
  );
}
