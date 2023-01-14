import 'package:flutter/material.dart';
import 'package:note_repository/constants/design/app_colors.dart';
import 'package:note_repository/constants/design/app_durations.dart';
import 'package:note_repository/constants/design/app_sizes.dart';

class CommonLoadingIndicator extends StatefulWidget {
  final double? size;

  const CommonLoadingIndicator({
    this.size,
    super.key,
  });

  @override
  State<CommonLoadingIndicator> createState() => _CommonLoadingIndicatorState();
}

class _CommonLoadingIndicatorState extends State<CommonLoadingIndicator> {
  bool isWaiting = true;

  @override
  void initState() {
    Future.delayed(AppDurations.loadingIndicatorWait).then((_) {
      if (!mounted) return;
      //TODO: Fix (Not true solution, it must wait more and try again or run when mounted is true)
      setState(() {
        isWaiting = false;
      });
    });
    super.initState();
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
