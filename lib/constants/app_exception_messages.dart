import 'package:note_repository/constants/app_strings.dart';
import 'package:note_repository/models/message.dart';

class AppExceptionMessages {
  const AppExceptionMessages._();

  static const ExceptionMessage error = ExceptionMessage(AppStrings.error);
  static const ExceptionMessage noInternet = ExceptionMessage(AppStrings.noInternetError);
  static const ExceptionMessage noPermission = ExceptionMessage();
  static const ExceptionMessage noCamera = ExceptionMessage();
}
