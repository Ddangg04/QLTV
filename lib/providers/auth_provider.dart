import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  Map<String, dynamic>? _userData;
  List<Map<String, dynamic>> _users = []; // Danh sách tất cả người dùng

  User? get user => _user;
  Map<String, dynamic>? get userData => _userData;
  String? get role => _userData?['role'];
  List<Map<String, dynamic>> get users => _users; // Getter cho danh sách người dùng

  AuthProvider() {
    _auth.authStateChanges().listen((user) async {
      _user = user;
      print('Auth state changed, user: $_user, uid: ${user?.uid}');
      if (user != null) {
        DocumentSnapshot doc =
        await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          _userData = doc.data() as Map<String, dynamic>;
        } else {
          _userData = {
            'uid': user.uid,
            'email': user.email,
            'name': '',
            'phone': '',
            'role': 'user',
            'createdAt': DateTime.now().toIso8601String(),
          };
          await _firestore
              .collection('users')
              .doc(user.uid)
              .set(_userData!);
        }
        // Lấy danh sách người dùng nếu là admin
        if (_userData?['role'] == 'admin') {
          fetchUsers(); // Sử dụng fetchUsers() thay vì _fetchUsers()
        }
      } else {
        _userData = null;
        _users = [];
      }
      notifyListeners();
    });
  }

  // Đăng ký người dùng mới, role mặc định là 'user'
  Future<void> signUp(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      _userData = {
        'uid': userCredential.user?.uid,
        'email': email,
        'name': '',
        'phone': '',
        'role': 'user', // Role luôn là 'user'
        'createdAt': DateTime.now().toIso8601String(),
      };

      await _firestore
          .collection('users')
          .doc(userCredential.user?.uid)
          .set(_userData!);
      notifyListeners();
    } catch (e) {
      throw e.toString();
    }
  }

  // Đăng nhập người dùng
  Future<void> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      throw e.toString();
    }
  }

  // Đăng xuất
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _user = null;
      _userData = null;
      _users = [];
      print('Signed out, user: $_user');
      notifyListeners();
    } catch (e) {
      print('Error signing out: $e');
      throw e.toString();
    }
  }

  // Cập nhật thông tin người dùng
  Future<void> updateUserProfile(String name, String phone, {String? role}) async {
    if (_user != null) {
      Map<String, dynamic> updates = {
        'name': name,
        'phone': phone,
      };
      if (role != null) updates['role'] = role;
      await _firestore.collection('users').doc(_user!.uid).update(updates);
      _userData!['name'] = name;
      _userData!['phone'] = phone;
      if (role != null) _userData!['role'] = role;
      notifyListeners();
    }
  }

  // Cập nhật danh sách người dùng cho admin
  Future<void> fetchUsers() async {
    try {
      final snapshot = await _firestore.collection('users').get();
      _users = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'uid': doc.id,
          'email': data['email'],
          'role': data['role'],
        };
      }).toList();
      notifyListeners();
    } catch (e) {
      print('Error fetching users: $e');
    }
  }

  // Thay đổi vai trò người dùng
  Future<void> changeUserRole(String uid, String newRole) async {
    if (_user != null && role == 'admin') {
      await _firestore.collection('users').doc(uid).update({'role': newRole});
      if (uid == _user!.uid) {
        _userData!['role'] = newRole;
      }
      // Cập nhật danh sách người dùng
      await fetchUsers(); // Sử dụng fetchUsers() thay vì _fetchUsers()
      notifyListeners();
    } else {
      throw Exception('Chỉ admin mới có quyền thay đổi vai trò');
    }
  }

  // Đổi mật khẩu
  Future<void> changePassword(String currentPassword, String newPassword) async {
    if (_user == null) {
      throw Exception('Người dùng chưa đăng nhập');
    }

    try {
      // Xác thực lại người dùng với mật khẩu hiện tại
      final credential = EmailAuthProvider.credential(
        email: _user!.email!,
        password: currentPassword,
      );

      await _user!.reauthenticateWithCredential(credential);

      // Đổi mật khẩu
      await _user!.updatePassword(newPassword);

      print('Password changed successfully');
    } catch (e) {
      print('Error changing password: $e');
      if (e.toString().contains('wrong-password')) {
        throw Exception('Mật khẩu hiện tại không đúng');
      } else if (e.toString().contains('weak-password')) {
        throw Exception('Mật khẩu mới quá yếu');
      } else if (e.toString().contains('requires-recent-login')) {
        throw Exception('Vui lòng đăng nhập lại để đổi mật khẩu');
      } else {
        throw Exception('Lỗi khi đổi mật khẩu: ${e.toString()}');
      }
    }
  }
}
