import 'package:flutter/material.dart';
import 'package:note_repository/constants/design/app_colors.dart';
import 'package:note_repository/constants/design/app_sizes.dart';

class CommonTextField extends StatelessWidget {
  final bool autoFocus;
  final bool centerText;
  final String? hintText;
  final TextEditingController? controller;
  final void Function(String text)? onChanged;
  final void Function()? onEditingComplete;

  const CommonTextField({
    super.key,
    this.autoFocus = false,
    this.centerText = false,
    this.hintText,
    this.controller,
    this.onChanged,
    this.onEditingComplete,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSizes.inputHeight,
      child: TextField(
        autofocus: autoFocus,
        textAlign: centerText ? TextAlign.center : TextAlign.start,
        cursorColor: AppColors.black,
        decoration: InputDecoration(
          hintText: hintText,
          contentPadding: const EdgeInsets.symmetric(horizontal: AppSizes.spacingL),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.inputHeight / 2),
          ),
        ),
        controller: controller,
        onChanged: onChanged,
        onEditingComplete: onEditingComplete,
      ),
    );
  }
}
