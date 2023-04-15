import 'package:flutter/material.dart';

class CommonText extends StatelessWidget {
  const CommonText(
    this.data, {
    this.style,
    super.key,
  });
  final String data;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Text(
      data,
      maxLines: 1,
      softWrap: false,
      overflow: TextOverflow.fade,
      style: style,
    );
  }
}
