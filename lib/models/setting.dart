import 'package:flutter/material.dart';

class Setting<T> {
  final String key;
  final IconData icon;
  final String title;
  final List<Option<T>> options;

  const Setting({
    required this.key,
    required this.icon,
    required this.title,
    required this.options,
  });
}

class Option<T> {
  final T value;
  final IconData icon;
  final String name;

  const Option({
    required this.value,
    required this.icon,
    required this.name,
  });
}
