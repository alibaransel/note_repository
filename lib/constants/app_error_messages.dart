import 'package:note_repository/constants/app_strings.dart';
import 'package:note_repository/models/message.dart';

class AppErrorMessages {
  const AppErrorMessages._();

  static const ErrorMessage error = ErrorMessage(AppStrings.error);
  static const ErrorMessage noInternet = ErrorMessage(AppStrings.noInternetError);
  static const ErrorMessage noPermission = ErrorMessage();
  static const ErrorMessage noCamera = ErrorMessage();
}
