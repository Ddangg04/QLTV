import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quanlythuvienck/models/book.dart';
import 'package:provider/provider.dart';
import 'package:quanlythuvienck/models/borrow_history.dart';
import 'package:quanlythuvienck/providers/auth_provider.dart';
import 'package:quanlythuvienck/providers/book_provider.dart';
import 'package:collection/collection.dart';

class CardTab extends StatefulWidget {
  @override
  _CardTabState createState() => _CardTabState();
}

class _CardTabState extends State<CardTab> with TickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  bool isValidPhoneNumber(String phone) {
    final phoneRegex = RegExp(r'^0[0-9]{9}$');
    return phoneRegex.hasMatch(phone);
  }

  bool isValidPassword(String password) {
    return password.length >= 6;
  }

  // Thêm hàm kiểm tra tên hợp lệ
  bool isValidName(String name) {
    // Kiểm tra độ dài (1-50 ký tự)
    if (name.trim().isEmpty || name.trim().length > 50) {
      return false;
    }

    // Kiểm tra không chứa chữ số
    final hasDigit = RegExp(r'\d').hasMatch(name);
    return !hasDigit;
  }

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.elasticOut));
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.bounceOut),
    );

    // Start animations
    _fadeController.forward();
    _slideController.forward();
    _scaleController.forward();

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.userData != null) {
      _nameController.text = authProvider.userData!['name'] ?? '';
      _phoneController.text = authProvider.userData!['phone'] ?? '';
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Widget _buildGradientCard({
    required Widget child,
    required List<Color> colors,
    double elevation = 8,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colors.first.withOpacity(0.3),
            blurRadius: elevation,
            offset: Offset(0, elevation / 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildAnimatedTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
    bool showToggle = false,
  }) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.95 + (0.05 * value),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: TextField(
              controller: controller,
              obscureText: obscureText,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              decoration: InputDecoration(
                labelText: label,
                prefixIcon: Icon(icon, color: Colors.teal.shade600),
                suffixIcon: showToggle
                    ? IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility : Icons.visibility_off,
                    color: Colors.teal.shade400,
                  ),
                  onPressed: onToggleVisibility,
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.transparent,
                labelStyle: TextStyle(color: Colors.teal.shade700),
                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGradientButton({
    required String text,
    required VoidCallback onPressed,
    required List<Color> colors,
    IconData? icon,
    double borderRadius = 15,
  }) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 200),
      tween: Tween(begin: 1.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: colors,
              ),
              borderRadius: BorderRadius.circular(borderRadius),
              boxShadow: [
                BoxShadow(
                  color: colors.first.withOpacity(0.4),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(borderRadius),
                onTap: onPressed,
                onTapDown: (_) {
                  // Animation when pressed
                },
                child: Container(
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                      ],
                      Text(
                        text,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showChangePasswordDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: Duration(milliseconds: 300),
      pageBuilder: (context, animation1, animation2) {
        return Container();
      },
      transitionBuilder: (context, animation1, animation2, widget) {
        return Transform.scale(
          scale: animation1.value,
          child: Opacity(
            opacity: animation1.value,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: Colors.transparent,
              contentPadding: EdgeInsets.zero,
              content: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.teal.shade50, Colors.white],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.orange.shade400, Colors.orange.shade600],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.lock_reset, color: Colors.white, size: 30),
                      ),
                      SizedBox(height: 15),
                      Text(
                        'Đổi mật khẩu',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal.shade700,
                        ),
                      ),
                      SizedBox(height: 20),
                      _buildAnimatedTextField(
                        controller: _currentPasswordController,
                        label: 'Mật khẩu hiện tại',
                        icon: Icons.lock_outline,
                        obscureText: _obscureCurrentPassword,
                        showToggle: true,
                        onToggleVisibility: () {
                          setState(() {
                            _obscureCurrentPassword = !_obscureCurrentPassword;
                          });
                        },
                      ),
                      SizedBox(height: 15),
                      _buildAnimatedTextField(
                        controller: _newPasswordController,
                        label: 'Mật khẩu mới (tối thiểu 6 ký tự)',
                        icon: Icons.lock,
                        obscureText: _obscureNewPassword,
                        showToggle: true,
                        onToggleVisibility: () {
                          setState(() {
                            _obscureNewPassword = !_obscureNewPassword;
                          });
                        },
                      ),
                      SizedBox(height: 15),
                      _buildAnimatedTextField(
                        controller: _confirmPasswordController,
                        label: 'Xác nhận mật khẩu mới',
                        icon: Icons.lock_reset,
                        obscureText: _obscureConfirmPassword,
                        showToggle: true,
                        onToggleVisibility: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                      SizedBox(height: 25),
                      Row(
                        children: [
                          Expanded(
                            child: _buildGradientButton(
                              text: 'Hủy',
                              onPressed: () {
                                _currentPasswordController.clear();
                                _newPasswordController.clear();
                                _confirmPasswordController.clear();
                                Navigator.of(context).pop();
                              },
                              colors: [Colors.grey.shade400, Colors.grey.shade600],
                            ),
                          ),
                          SizedBox(width: 15),
                          Expanded(
                            child: _buildGradientButton(
                              text: 'Đổi mật khẩu',
                              icon: Icons.check,
                              onPressed: () async {
                                if (_currentPasswordController.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Vui lòng nhập mật khẩu hiện tại'),
                                      backgroundColor: Colors.red.shade400,
                                    ),
                                  );
                                  return;
                                }

                                if (!isValidPassword(_newPasswordController.text)) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Mật khẩu mới phải có ít nhất 6 ký tự'),
                                      backgroundColor: Colors.red.shade400,
                                    ),
                                  );
                                  return;
                                }

                                if (_newPasswordController.text != _confirmPasswordController.text) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Mật khẩu xác nhận không khớp'),
                                      backgroundColor: Colors.red.shade400,
                                    ),
                                  );
                                  return;
                                }

                                if (_currentPasswordController.text == _newPasswordController.text) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Mật khẩu mới phải khác mật khẩu hiện tại'),
                                      backgroundColor: Colors.red.shade400,
                                    ),
                                  );
                                  return;
                                }

                                try {
                                  final authProvider = Provider.of<AuthProvider>(context, listen: false);
                                  await authProvider.changePassword(
                                    _currentPasswordController.text,
                                    _newPasswordController.text,
                                  );

                                  _currentPasswordController.clear();
                                  _newPasswordController.clear();
                                  _confirmPasswordController.clear();

                                  Navigator.of(context).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        children: [
                                          Icon(Icons.check_circle, color: Colors.white),
                                          SizedBox(width: 10),
                                          Text('Đổi mật khẩu thành công'),
                                        ],
                                      ),
                                      backgroundColor: Colors.green.shade400,
                                    ),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        children: [
                                          Icon(Icons.error, color: Colors.white),
                                          SizedBox(width: 10),
                                          Expanded(child: Text('$e')),
                                        ],
                                      ),
                                      backgroundColor: Colors.red.shade400,
                                    ),
                                  );
                                }
                              },
                              colors: [Colors.orange.shade400, Colors.orange.shade600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final bookProvider = Provider.of<BookProvider>(context);
    final userId = authProvider.user?.uid ?? '';

    final userHistory = bookProvider.borrowHistory
        .where((history) => history.userId == userId)
        .toList();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.teal.shade50,
            Colors.white,
            Colors.blue.shade50,
          ],
        ),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Info Card
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: _buildGradientCard(
                      colors: [Colors.teal.shade400, Colors.teal.shade600],
                      child: Container(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Icon(Icons.person, color: Colors.white, size: 24),
                                ),
                                SizedBox(width: 15),
                                Text(
                                  'Thông tin người dùng',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            _buildAnimatedTextField(
                              controller: _nameController,
                              label: 'Tên (tối đa 50 ký tự, không chứa số)',
                              icon: Icons.person_outline,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(50),
                                FilteringTextInputFormatter.deny(RegExp(r'\d')), // Loại bỏ chữ số
                              ],
                            ),
                            SizedBox(height: 15),
                            _buildAnimatedTextField(
                              controller: _phoneController,
                              label: 'Số điện thoại (10 số)',
                              icon: Icons.phone_outlined,
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(10),
                              ],
                            ),
                            SizedBox(height: 25),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildGradientButton(
                                    text: 'Cập nhật',
                                    icon: Icons.save,
                                    onPressed: () async {
                                      // Cập nhật validation cho tên
                                      if (!isValidName(_nameController.text)) {
                                        String errorMessage = '';
                                        if (_nameController.text.trim().isEmpty) {
                                          errorMessage = 'Tên không được để trống';
                                        } else if (_nameController.text.trim().length > 50) {
                                          errorMessage = 'Tên không được vượt quá 50 ký tự';
                                        } else if (RegExp(r'\d').hasMatch(_nameController.text)) {
                                          errorMessage = 'Tên không được chứa chữ số';
                                        }

                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(errorMessage),
                                            backgroundColor: Colors.red.shade400,
                                          ),
                                        );
                                        return;
                                      }

                                      if (!isValidPhoneNumber(_phoneController.text)) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Số điện thoại phải đúng 10 chữ số và bắt đầu bằng 0'),
                                            backgroundColor: Colors.red.shade400,
                                          ),
                                        );
                                        return;
                                      }

                                      try {
                                        await authProvider.updateUserProfile(
                                          _nameController.text.trim(), // Trim để loại bỏ khoảng trắng thừa
                                          _phoneController.text,
                                        );
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Row(
                                              children: [
                                                Icon(Icons.check_circle, color: Colors.white),
                                                SizedBox(width: 10),
                                                Text('Cập nhật thông tin thành công'),
                                              ],
                                            ),
                                            backgroundColor: Colors.green.shade400,
                                          ),
                                        );
                                      } catch (e) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Lỗi khi cập nhật: $e'),
                                            backgroundColor: Colors.red.shade400,
                                          ),
                                        );
                                      }
                                    },
                                    colors: [Colors.green.shade400, Colors.green.shade600],
                                  ),
                                ),
                                SizedBox(width: 15),
                                Expanded(
                                  child: _buildGradientButton(
                                    text: 'Đổi mật khẩu',
                                    icon: Icons.lock_reset,
                                    onPressed: _showChangePasswordDialog,
                                    colors: [Colors.orange.shade400, Colors.orange.shade600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 30),

              // History Section
              TweenAnimationBuilder<double>(
                duration: Duration(milliseconds: 800),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, 50 * (1 - value)),
                    child: Opacity(
                      opacity: value,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Colors.purple.shade400, Colors.purple.shade600],
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Icon(Icons.history, color: Colors.white, size: 24),
                              ),
                              SizedBox(width: 15),
                              Text(
                                'Lịch sử mượn sách',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.purple.shade700,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 15),

                          userHistory.isEmpty
                              ? Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(40),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.grey.shade100, Colors.grey.shade200],
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              children: [
                                Icon(Icons.library_books_outlined,
                                    size: 60, color: Colors.grey.shade400),
                                SizedBox(height: 15),
                                Text(
                                  'Chưa có lịch sử mượn sách',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          )
                              : ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: userHistory.length,
                            itemBuilder: (context, index) {
                              final history = userHistory[index];
                              final Book? book = bookProvider.books.firstWhereOrNull(
                                    (b) => b.id == history.bookId,
                              );

                              return TweenAnimationBuilder<double>(
                                duration: Duration(milliseconds: 600 + (index * 100)),
                                tween: Tween(begin: 0.0, end: 1.0),
                                builder: (context, animValue, child) {
                                  return Transform.translate(
                                    offset: Offset(100 * (1 - animValue), 0),
                                    child: Opacity(
                                      opacity: animValue,
                                      child: Container(
                                        margin: EdgeInsets.symmetric(vertical: 8),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                            colors: [
                                              Colors.blue.shade50,
                                              Colors.white,
                                              Colors.purple.shade50,
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(15),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.1),
                                              blurRadius: 10,
                                              offset: Offset(0, 5),
                                            ),
                                          ],
                                        ),
                                        child: ListTile(
                                          contentPadding: EdgeInsets.all(15),
                                          leading: Container(
                                            padding: EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: history.returnDate != null
                                                    ? [Colors.green.shade400, Colors.green.shade600]
                                                    : [Colors.orange.shade400, Colors.orange.shade600],
                                              ),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Icon(
                                              history.returnDate != null
                                                  ? Icons.check_circle
                                                  : Icons.access_time,
                                              color: Colors.white,
                                              size: 24,
                                            ),
                                          ),
                                          title: Text(
                                            book?.name ?? 'Không tìm thấy thông tin sách',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Colors.grey.shade800,
                                            ),
                                          ),
                                          subtitle: Container(
                                            margin: EdgeInsets.only(top: 8),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Icon(Icons.calendar_today,
                                                        size: 16, color: Colors.blue.shade600),
                                                    SizedBox(width: 5),
                                                    Text(
                                                      'Mượn: ${history.borrowDate.toString().substring(0, 10)}',
                                                      style: TextStyle(color: Colors.blue.shade600),
                                                    ),
                                                  ],
                                                ),
                                                if (history.returnDate != null) ...[
                                                  SizedBox(height: 4),
                                                  Row(
                                                    children: [
                                                      Icon(Icons.assignment_return,
                                                          size: 16, color: Colors.green.shade600),
                                                      SizedBox(width: 5),
                                                      Text(
                                                        'Trả: ${history.returnDate.toString().substring(0, 10)}',
                                                        style: TextStyle(color: Colors.green.shade600),
                                                      ),
                                                    ],
                                                  ),
                                                ] else ...[
                                                  SizedBox(height: 4),
                                                  Row(
                                                    children: [
                                                      Icon(Icons.pending,
                                                          size: 16, color: Colors.orange.shade600),
                                                      SizedBox(width: 5),
                                                      Text(
                                                        'Chưa trả',
                                                        style: TextStyle(
                                                          color: Colors.orange.shade600,
                                                          fontWeight: FontWeight.w500,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}