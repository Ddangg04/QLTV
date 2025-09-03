import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quanlythuvienck/providers/auth_provider.dart';
import 'package:quanlythuvienck/screens/auth/login_screen.dart';
import 'package:quanlythuvienck/screens/home/book_tab.dart';
import 'package:quanlythuvienck/screens/home/borrow_tab.dart';
import 'package:quanlythuvienck/screens/home/card_tab.dart';
import 'package:quanlythuvienck/screens/home/shelf_tab.dart';
import 'package:quanlythuvienck/screens/home/manage_role_screen.dart';

class HomeScreen extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const HomeScreen({
    Key? key,
    this.selectedIndex = 0,
    required this.onItemTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.user == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen()),
            );
          });
          return Container();
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Thư viện',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
            backgroundColor: Colors.teal[800],
            actions: [
              if (authProvider.role == 'admin')
                IconButton(
                  icon: Icon(Icons.manage_accounts, color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ManageRoleScreen()),
                    );
                  },
                  tooltip: 'Quản lý vai trò',
                ),
              IconButton(
                icon: Icon(Icons.logout, color: Colors.white),
                onPressed: () async {
                  try {
                    await Provider.of<AuthProvider>(context, listen: false).signOut();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Lỗi đăng xuất: $e')),
                    );
                  }
                },
              ),
            ],
          ),
          body: IndexedStack(
            index: selectedIndex,
            children: [
              ShelfTab(),
              BookTab(),
              BorrowTab(),
              CardTab(),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.shelves),
                label: 'Kệ sách',
                backgroundColor: Colors.teal,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.book),
                label: 'Sách',
                backgroundColor: Colors.teal,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.library_books),
                label: 'Mượn',
                backgroundColor: Colors.teal,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.credit_card),
                label: 'Thẻ',
                backgroundColor: Colors.teal,
              ),
            ],
            currentIndex: selectedIndex,
            selectedItemColor: Colors.teal[800],
            unselectedItemColor: Colors.grey,
            onTap: onItemTapped,
            backgroundColor: Colors.white,
            type: BottomNavigationBarType.shifting,
          ),
        );
      },
    );
  }
}

class HomeScreenManager extends StatefulWidget {
  @override
  _HomeScreenManagerState createState() => _HomeScreenManagerState();
}

class _HomeScreenManagerState extends State<HomeScreenManager> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return HomeScreen(
      selectedIndex: _selectedIndex,
      onItemTapped: _onItemTapped,
    );
  }
}