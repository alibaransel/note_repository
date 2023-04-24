import 'package:flutter/foundation.dart';

@immutable
class ExceptionModel implements Exception {
  const ExceptionModel(
    this.message,
  );

  final String message;

  @override
  bool operator ==(Object other) => other is ExceptionModel && other.message == message;

  @override
  int get hashCode => message.hashCode;
}
