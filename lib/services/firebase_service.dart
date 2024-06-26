import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:note_repository/constants/app_exceptions.dart';
import 'package:note_repository/constants/app_keys.dart';
import 'package:note_repository/models/service.dart';
import 'package:note_repository/services/network_service.dart';
import 'package:note_repository/services/time_service.dart';

// TODO: Move paths and it's operations to AppPaths and PathService
// TODO: Separete storage and authentication operations

class FirebaseService extends Service {
  FirebaseService._();

  static bool isLoggedIn() => FirebaseAuth.instance.currentUser != null;

  static Future<User> loginWithGoogle() async {
    if (!await NetworkService.hasInternet()) throw AppExceptions.noInternet;
    final UserCredential userCredential = await _loginWithGoogle();
    if (userCredential.user == null) throw AppExceptions.error;
    final User user = userCredential.user!;
    if (userCredential.additionalUserInfo == null) throw AppExceptions.error; //TODO
    if (await _isUserNew(userCredential, user)) await _createNewUserData(user);
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
    final UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);
    return userCredential;
  }

  static Future<bool> _isUserNew(UserCredential userCredential, User user) async {
    final AdditionalUserInfo? additionalUserInfo = userCredential.additionalUserInfo;
    if (additionalUserInfo != null) return additionalUserInfo.isNewUser;
    return !(await FirebaseFirestore.instance.collection(AppKeys.users).doc(user.uid).get()).exists;
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
    final DocumentSnapshot<Map<String, dynamic>> accountSnapshot = await FirebaseFirestore.instance
        .collection(AppKeys.users)
        .doc(uid)
        .collection(AppKeys.user)
        .doc(AppKeys.account)
        .get();

    final Map<String, dynamic>? accountData = accountSnapshot.data();

    if (accountData == null) throw AppExceptions.error;

    final List<String> loginHistory = (accountData[AppKeys.loginHistory] as List).cast()
      ..add(TimeService.encode(DateTime.now()));

    await FirebaseFirestore.instance
        .collection(AppKeys.users)
        .doc(uid)
        .collection(AppKeys.user)
        .doc(AppKeys.account) //TODO: Use set with set options
        .update({
      AppKeys.loginHistory: loginHistory,
    });
  }
}
