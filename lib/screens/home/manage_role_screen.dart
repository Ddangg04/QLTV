import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quanlythuvienck/providers/auth_provider.dart';

class ManageRoleScreen extends StatefulWidget {
  @override
  _ManageRoleScreenState createState() => _ManageRoleScreenState();
}

class _ManageRoleScreenState extends State<ManageRoleScreen> {
  final _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _users = [];
  String? _selectedUserId;
  String _selectedRole = 'user';

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    final snapshot = await _firestore.collection('users').get();
    setState(() {
      _users = snapshot.docs.map((doc) => {
        'uid': doc.id,
        'email': doc['email'],
        'role': doc['role'],
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Quản lý vai trò'),
        backgroundColor: Colors.teal[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<String>(
              value: _selectedUserId,
              hint: Text('Chọn người dùng'),
              items: _users.map((user) {
                return DropdownMenuItem<String>(
                  value: user['uid'],
                  child: Text('${user['email']} (Hiện tại: ${user['role']})'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedUserId = value;
                  final user = _users.firstWhere((u) => u['uid'] == value);
                  _selectedRole = user['role'] ?? 'user';
                });
              },
            ),
            SizedBox(height: 20),
            DropdownButton<String>(
              value: _selectedRole,
              items: <String>['user', 'admin'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedRole = newValue;
                  });
                }
              },
              hint: Text('Chọn vai trò mới'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _selectedUserId == null
                  ? null
                  : () async {
                try {
                  await authProvider.changeUserRole(_selectedUserId!, _selectedRole);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Đã cập nhật vai trò thành công')),
                  );
                  _fetchUsers();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lỗi: $e')),
                  );
                }
              },
              child: Text('Cập nhật vai trò'),
            ),
          ],
        ),
      ),
    );
  }
}