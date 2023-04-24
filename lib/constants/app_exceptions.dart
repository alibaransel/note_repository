import 'package:note_repository/constants/app_strings.dart';
import 'package:note_repository/models/exception_model.dart';

class AppExceptions {
  const AppExceptions._();

  static const ExceptionModel error = ExceptionModel(AppStrings.error);
  static const ExceptionModel noInternet = ExceptionModel(AppStrings.noInternetError);
  static const ExceptionModel noPermission = ExceptionModel('');
  static const ExceptionModel noCamera = ExceptionModel('');
}
