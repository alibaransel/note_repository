import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:note_repository/constants/app_error_messages.dart';
import 'package:note_repository/constants/app_keys.dart';
import 'package:note_repository/models/service.dart';
import 'package:note_repository/services/network_service.dart';
import 'package:note_repository/services/time_service.dart';

class FirebaseService extends Service {
  FirebaseService._();

  static bool isLoggedIn() => FirebaseAuth.instance.currentUser != null;

  static Future<User> loginWithGoogle() async {
    if (!await NetworkService.hasInternet()) {
      return Future.error(AppErrorMessages.noInternet);
    }

    UserCredential userCredential = await _loginWithGoogle();
    if (userCredential.user == null) return Future.error(AppErrorMessages.error);
    final User user = userCredential.user!;
    if (userCredential.additionalUserInfo == null) {
      return Future.error(AppErrorMessages.error);
    } //TODO
    if (userCredential.additionalUserInfo!.isNewUser) _createNewUserData(user);
    await _saveLoginInfo(user.uid);
    return user;
  }

  static Future<void> logOut() async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
  }

  static Future<UserCredential> _loginWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );
    UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
    return userCredential;
  }

  static Future<void> _createNewUserData(User user) async {
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

  static Future<void> _saveLoginInfo(String uid) async {
    DocumentSnapshot<Map<String, dynamic>> accountSnapshot = await FirebaseFirestore.instance
        .collection(AppKeys.users)
        .doc(uid)
        .collection(AppKeys.user)
        .doc(AppKeys.account)
        .get();

    Map<String, dynamic>? accountData = accountSnapshot.data();

    if (accountData == null) return Future.error(AppErrorMessages.error);

    List<dynamic> loginHistory = accountData[AppKeys.loginHistory];

    loginHistory.add(TimeService.encode(DateTime.now()));

    await FirebaseFirestore.instance
        .collection(AppKeys.users)
        .doc(uid)
        .collection(AppKeys.user)
        .doc(AppKeys.account)
        .update({
      AppKeys.loginHistory: loginHistory,
    });
  }
}
