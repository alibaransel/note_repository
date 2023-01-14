import 'package:note_repository/constants/app_keys.dart';
import 'package:note_repository/constants/app_paths.dart';
import 'package:note_repository/models/account.dart';
import 'package:note_repository/services/firebase_service.dart';
import 'package:note_repository/services/setting_service.dart';
import 'package:note_repository/services/storage_service.dart';

class AccountService {
  factory AccountService() => _instance;
  static final AccountService _instance = AccountService._();
  AccountService._();

  late Account _account;

  Account get account => _account;
  bool get isLoggedIn => FirebaseService().isLoggedIn();

  Future<void> _delete() async {
    await Future.wait([
      StorageService.file.emptyData(AppPaths.account),
      StorageService.file.delete(AppPaths.userImage),
    ]);
  }

  Future<void> fetch() async {
    if (!isLoggedIn) return;
    final Map<String, dynamic> accountData = await StorageService.file.getData(AppPaths.account);
    await set(
      Account(
        uid: accountData[AppKeys.uid]!,
        name: accountData[AppKeys.name]!,
        email: accountData[AppKeys.email]!,
        image: await StorageService.file.getImage(AppPaths.userImage),
        loginType: accountData[AppKeys.loginType]!,
      ),
    );
  }

  Future<String> tryLogin() async => await FirebaseService().tryLoginWithGoogle(); //TODO

  Future<void> logOut() async {
    await Future.wait([
      FirebaseService().logOut(),
      _delete(),
      SettingService().setToDefaults(),
    ]);
  }

  Future<void> set(Account newAccount) async {
    _account = newAccount;
    await StorageService.file.updateData(
      path: AppPaths.account,
      newData: {
        AppKeys.uid: newAccount.uid,
        AppKeys.name: newAccount.name,
        AppKeys.email: newAccount.email,
        AppKeys.loginType: newAccount.loginType,
      },
    );
  }
}
