import 'package:flutter/material.dart';
import 'package:note_repository/constants/design/app_colors.dart';
import 'package:note_repository/constants/design/app_durations.dart';
import 'package:note_repository/constants/design/app_sizes.dart';

class CommonLoadingIndicator extends StatefulWidget {
  const CommonLoadingIndicator({
    this.size,
    super.key,
  });
  final double? size;

  @override
  State<CommonLoadingIndicator> createState() => _CommonLoadingIndicatorState();
}

class _CommonLoadingIndicatorState extends State<CommonLoadingIndicator> {
  bool isWaiting = true;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(AppDurations.loadingIndicatorWait).then((_) {
      if (!mounted) return;
      setState(() {
        isWaiting = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedSwitcher(
        duration: AppDurations.m,
        child: SizedBox(
          height: widget.size,
          width: widget.size,
          child: isWaiting
              ? null
              : const CircularProgressIndicator(
                  strokeWidth: AppSizes.loadingIndicatorThickness,
                  color: AppColors.mainColor,
                ),
        ),
      ),
    );
  }
}
