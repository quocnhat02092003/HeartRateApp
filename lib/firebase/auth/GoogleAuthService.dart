import 'package:google_sign_in/google_sign_in.dart';

/// GoogleAuthService
class GoogleAuthService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  static GoogleSignInAccount? currentUser;

  /// Login
  static Future<GoogleSignInAccount?> signIn() async {
    try {
      final GoogleSignInAccount? user = await _googleSignIn.signIn();
      currentUser = user;
      return user;
    } catch (error) {
      print('❌ Lỗi đăng nhập Google: $error');
      return null;
    }
  }

  /// Auto login (nếu token còn hợp lệ)
  static Future<GoogleSignInAccount?> signInSilently() async {
    try {
      final GoogleSignInAccount? user = await _googleSignIn.signInSilently();
      if (user != null) {
        print('✅ Đăng nhập lại thành công: ${user.email}');
      } else {
        print('ℹ️ Không tìm thấy phiên đăng nhập hợp lệ.');
      }
      currentUser = user;
      return user;
    } catch (error) {
      print('❌ Lỗi khi signInSilently: $error');
      return null;
    }
  }

  /// Get data user
  static GoogleSignInAccount? getCurrentUser() {
    currentUser = _googleSignIn.currentUser;
    return currentUser;
  }

  /// Logout
  static Future<void> signOut() async {
    try {
      await _googleSignIn.disconnect();
      currentUser = null;
    } catch (error) {
      print('❌ Lỗi đăng xuất Google: $error');
    }
  }
}
