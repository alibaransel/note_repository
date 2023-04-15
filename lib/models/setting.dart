import 'package:flutter/material.dart';

class Setting<T> {
  const Setting({
    required this.key,
    required this.icon,
    required this.title,
    required this.options,
  });
  final String key;
  final IconData icon;
  final String title;
  final List<Option<T>> options;
}

class Option<T> {
  const Option({
    required this.value,
    required this.icon,
    required this.name,
  });
  final T value;
  final IconData icon;
  final String name;
}
