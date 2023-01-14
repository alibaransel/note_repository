import 'package:flutter/material.dart';

class CommonText extends StatelessWidget {
  final String data;
  final TextStyle? style;

  const CommonText(
    this.data, {
    this.style,
    super.key,
  });

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
