import 'package:firebase_auth/firebase_auth.dart';
import 'package:note_repository/constants/app_keys.dart';
import 'package:note_repository/constants/app_paths.dart';
import 'package:note_repository/models/account.dart';
import 'package:note_repository/models/service.dart';
import 'package:note_repository/services/firebase_service.dart';
import 'package:note_repository/services/network_service.dart';
import 'package:note_repository/services/setting_service.dart';
import 'package:note_repository/services/storage_service.dart';

class AccountService extends Service with Initable {
  factory AccountService() => _instance;
  AccountService._();
  static final AccountService _instance = AccountService._();

  late Account _account;

  Account get account => _account;
  bool get isLoggedIn => FirebaseService.isLoggedIn();

  @override
  Future<void> init() async {
    await _fetch();
    super.init();
  }

  Future<void> login() async {
    final User user = await FirebaseService.loginWithGoogle();
    await NetworkService.saveImageFromURL(
      path: AppPaths.userImage,
      imageURL: user.photoURL!,
    );
    await AccountService().set(
      Account(
        uid: user.uid,
        name: user.displayName!,
        email: user.email!,
        image: await StorageService.file.getImage(AppPaths.userImage),
        loginType: AppKeys.google,
      ),
    );
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

  Future<void> logOut() async {
    await Future.wait([
      FirebaseService.logOut(),
      _delete(),
      SettingService().setToDefaults(),
    ]);
  }

  Future<void> _fetch() async {
    if (!isLoggedIn) return;
    final Map<String, dynamic> accountData = await StorageService.file.getData(AppPaths.account);
    await set(
      Account(
        uid: accountData[AppKeys.uid]! as String,
        name: accountData[AppKeys.name]! as String,
        email: accountData[AppKeys.email]! as String,
        image: await StorageService.file.getImage(AppPaths.userImage),
        loginType: accountData[AppKeys.loginType]! as String,
      ),
    );
  }

  Future<void> _delete() async {
    await Future.wait([
      StorageService.file.emptyData(AppPaths.account),
      StorageService.file.delete(AppPaths.userImage),
    ]);
  }
}
