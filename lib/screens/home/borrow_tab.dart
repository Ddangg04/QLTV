import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quanlythuvienck/providers/book_provider.dart';
import 'package:quanlythuvienck/providers/auth_provider.dart';

class BorrowTab extends StatefulWidget {
  @override
  _BorrowTabState createState() => _BorrowTabState();
}

class _BorrowTabState extends State<BorrowTab>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // Hàm helper để lấy tên admin từ ID
  String _getAdminName(String adminId, AuthProvider authProvider) {
    try {
      final adminUser = authProvider.users.firstWhere(
            (user) => user['uid'] == adminId,
        orElse: () => <String, dynamic>{},
      );

      if (adminUser.isNotEmpty && adminUser['name'] != null && adminUser['name'].toString().isNotEmpty) {
        return adminUser['name'];
      } else if (adminUser.isNotEmpty && adminUser['email'] != null) {
        return adminUser['email'];
      } else {
        return 'Admin: $adminId';
      }
    } catch (e) {
      return 'Admin: $adminId';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookProvider = Provider.of<BookProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    final borrowedHistory = bookProvider.borrowHistory
        .where((history) => history.returnDate == null)
        .toList();
    final returnedHistory = bookProvider.borrowHistory
        .where((history) => history.returnDate != null)
        .toList();

    final borrowedBooks = bookProvider.books
        .where((book) => borrowedHistory.any((history) => history.bookId == book.id))
        .toList();
    final returnedBooks = bookProvider.books
        .where((book) => returnedHistory.any((history) => history.bookId == book.id))
        .toList();

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          // Header với gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.history,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Lịch sử mượn sách',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Theo dõi các sách bạn đã mượn',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Statistics Cards
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Đang mượn',
                          borrowedBooks.length.toString(),
                          Icons.book,
                          Color(0xFFff6b6b),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          'Đã trả',
                          returnedBooks.length.toString(),
                          Icons.check_circle,
                          Color(0xFF4ecdc4),
                        ),
                      ),
                    ],
                  ),
                ),
                // Tab Bar
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    labelColor: Color(0xFF667eea),
                    unselectedLabelColor: Colors.white,
                    tabs: [
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.book, size: 20),
                            SizedBox(width: 8),
                            Text('Đang mượn'),
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.history, size: 20),
                            SizedBox(width: 8),
                            Text('Đã trả'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
          // Tab View Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildBorrowedBooksTab(borrowedBooks, borrowedHistory, authProvider),
                _buildReturnedBooksTab(returnedBooks, returnedHistory, authProvider),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBorrowedBooksTab(List borrowedBooks, List borrowedHistory, AuthProvider authProvider) {
    if (borrowedBooks.isEmpty) {
      return _buildEmptyState(
        'Không có sách đang mượn',
        'Bạn chưa mượn sách nào hoặc đã trả hết.',
        Icons.book_outlined,
        Color(0xFF667eea),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(20),
      itemCount: borrowedBooks.length,
      itemBuilder: (context, index) {
        final book = borrowedBooks[index];
        final history = borrowedHistory.firstWhere((h) => h.bookId == book.id);

        return TweenAnimationBuilder(
          duration: Duration(milliseconds: 600 + (index * 100)),
          tween: Tween<double>(begin: 0, end: 1),
          builder: (context, double value, child) {
            return Transform.translate(
              offset: Offset(0, 50 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: _buildBookCard(
                  book: book,
                  history: history,
                  isReturned: false,
                  index: index,
                  authProvider: authProvider,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildReturnedBooksTab(List returnedBooks, List returnedHistory, AuthProvider authProvider) {
    if (returnedBooks.isEmpty) {
      return _buildEmptyState(
        'Chưa có sách đã trả',
        'Lịch sử trả sách sẽ hiển thị ở đây.',
        Icons.history,
        Color(0xFF4ecdc4),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(20),
      itemCount: returnedBooks.length,
      itemBuilder: (context, index) {
        final book = returnedBooks[index];
        final history = returnedHistory.firstWhere((h) => h.bookId == book.id);

        return TweenAnimationBuilder(
          duration: Duration(milliseconds: 600 + (index * 100)),
          tween: Tween<double>(begin: 0, end: 1),
          builder: (context, double value, child) {
            return Transform.translate(
              offset: Offset(0, 50 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: _buildBookCard(
                  book: book,
                  history: history,
                  isReturned: true,
                  index: index,
                  authProvider: authProvider,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBookCard({
    required dynamic book,
    required dynamic history,
    required bool isReturned,
    required int index,
    required AuthProvider authProvider,
  }) {
    final gradientColors = isReturned
        ? [Color(0xFF4ecdc4), Color(0xFF44a08d)]
        : [Color(0xFFff6b6b), Color(0xFFee5a52)];

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _showBookDetails(book, history, isReturned, authProvider),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                // Book Icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    isReturned ? Icons.check_circle : Icons.schedule,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                SizedBox(width: 16),
                // Book Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.name,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: Colors.white.withOpacity(0.8),
                            size: 16,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Kệ ${book.shelfId}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.person,
                            color: Colors.white.withOpacity(0.8),
                            size: 16,
                          ),
                          SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              _getAdminName(history.adminId, authProvider),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Status Badge
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isReturned ? 'Đã trả' : 'Đang mượn',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon, Color color) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder(
            duration: Duration(milliseconds: 1000),
            tween: Tween<double>(begin: 0, end: 1),
            builder: (context, double value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(60),
                  ),
                  child: Icon(
                    icon,
                    size: 60,
                    color: color,
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 24),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  void _showBookDetails(dynamic book, dynamic history, bool isReturned, AuthProvider authProvider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 5,
              margin: EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isReturned ? Color(0xFF4ecdc4) : Color(0xFFff6b6b),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.book,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              book.name,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Chi tiết sách',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  _buildDetailRow('Vị trí', 'Kệ ${book.shelfId}', Icons.location_on),
                  _buildDetailRow('Quản lý bởi', _getAdminName(history.adminId, authProvider), Icons.person),
                  _buildDetailRow('Trạng thái', isReturned ? 'Đã trả' : 'Đang mượn',
                      isReturned ? Icons.check_circle : Icons.schedule),
                  if (history.borrowDate != null)
                    _buildDetailRow('Ngày mượn', history.borrowDate.toString(), Icons.calendar_today),
                  if (history.returnDate != null)
                    _buildDetailRow('Ngày trả', history.returnDate.toString(), Icons.event_available),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          SizedBox(width: 12),
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }
}