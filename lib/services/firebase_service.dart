import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:note_repository/constants/app_keys.dart';
import 'package:note_repository/constants/app_paths.dart';
import 'package:note_repository/models/account.dart';
import 'package:note_repository/services/network_service.dart';
import 'package:note_repository/services/account_service.dart';
import 'package:note_repository/services/storage_service.dart';
import 'package:note_repository/services/time_service.dart';

class FirebaseService {
  Future<UserCredential> _loginWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );
    UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
    return userCredential;
  }

  Future<void> _prepareUser(UserCredential userCredential) async {
    User? user = userCredential.user;
    AdditionalUserInfo? additionalUserInfo = userCredential.additionalUserInfo;
    if (user == null) throw AppKeys.error;
    if (additionalUserInfo == null) throw AppKeys.error;
    if (additionalUserInfo.isNewUser) await _saveNewUserData(user);
    await _saveUserDataToDevice(user);
    await _saveLoginInfo(user.uid);
  }

  Future<void> _saveNewUserData(User user) async {
    await FirebaseFirestore.instance
        .collection(AppKeys.users)
        .doc(user.uid)
        .collection(AppKeys.user)
        .doc(AppKeys.account)
        .set({
      AppKeys.name: user.displayName,
      AppKeys.email: user.email,
      AppKeys.imageURL: user.photoURL,
      AppKeys.loginType: AppKeys.google,
      AppKeys.loginHistory: <String>[],
    });
  }

  Future<void> _saveUserDataToDevice(User user) async {
    await NetworkService().saveImageFromURL(
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

  Future<void> _saveLoginInfo(String uid) async {
    DocumentSnapshot<Map<String, dynamic>> accountSnapshot = await FirebaseFirestore.instance
        .collection(AppKeys.users)
        .doc(uid)
        .collection(AppKeys.user)
        .doc(AppKeys.account)
        .get();

    Map<String, dynamic>? accountData = accountSnapshot.data();

    if (accountData == null) throw AppKeys.error;

    List<dynamic> loginHistory = accountData[AppKeys.loginHistory];

    loginHistory.add(TimeService().encode(DateTime.now()));

    await FirebaseFirestore.instance
        .collection(AppKeys.users)
        .doc(uid)
        .collection(AppKeys.user)
        .doc(AppKeys.account)
        .update({
      AppKeys.loginHistory: loginHistory,
    });
  }

  Future<String> tryLoginWithGoogle() async {
    if (!await NetworkService().hasInternet()) {
      return AppKeys.internetError;
    }

    try {
      UserCredential userCredential = await _loginWithGoogle();
      await _prepareUser(userCredential);
      return AppKeys.done;
    } catch (_) {
      return AppKeys.error;
    }
  }

  bool isLoggedIn() => FirebaseAuth.instance.currentUser != null;

  Future<void> logOut() async {
    await GoogleSignIn().disconnect();
    await FirebaseAuth.instance.signOut();
  }
}
