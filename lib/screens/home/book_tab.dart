import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import 'package:quanlythuvienck/models/book.dart';
import 'package:quanlythuvienck/providers/auth_provider.dart';
import 'package:quanlythuvienck/providers/book_provider.dart';
import 'package:quanlythuvienck/widgets/book_dialog.dart';

class BookTab extends StatefulWidget {
  const BookTab({Key? key}) : super(key: key);

  @override
  _BookTabState createState() => _BookTabState();
}

class _BookTabState extends State<BookTab> with TickerProviderStateMixin {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;

  String _searchQuery = '';
  String? _selectedUserId;
  bool _isGridView = true;
  String _sortBy = 'name'; // name, shelf, status
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _fetchInitialData();
  }

  void _initializeControllers() {
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fabAnimationController, curve: Curves.easeInOut),
    );
    _fabAnimationController.forward();

    _scrollController.addListener(_onScroll);
  }

  void _fetchInitialData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.role == 'admin') {
      authProvider.fetchUsers();
    }
  }

  void _onScroll() {
    if (_scrollController.offset > 100 && _fabAnimationController.status == AnimationStatus.completed) {
      _fabAnimationController.reverse();
    } else if (_scrollController.offset <= 100 && _fabAnimationController.status == AnimationStatus.dismissed) {
      _fabAnimationController.forward();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  List<Book> _getSortedAndFilteredBooks(BookProvider bookProvider) {
    List<Book> filteredBooks = _searchQuery.isEmpty
        ? bookProvider.books
        : bookProvider.searchBooks(_searchQuery);

    // Sort books
    filteredBooks.sort((a, b) {
      int comparison;
      switch (_sortBy) {
        case 'shelf':
          comparison = a.shelfId.compareTo(b.shelfId);
          break;
        case 'status':
          comparison = a.isBorrowed.toString().compareTo(b.isBorrowed.toString());
          break;
        default: // name
          comparison = a.name.compareTo(b.name);
      }
      return _sortAscending ? comparison : -comparison;
    });

    return filteredBooks;
  }

  @override
  Widget build(BuildContext context) {
    final bookProvider = Provider.of<BookProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final books = _getSortedAndFilteredBooks(bookProvider);

    return Scaffold(
      body: Column(
        children: [
          _buildHeader(authProvider),
          _buildSearchAndFilters(authProvider),
          if (authProvider.role == 'admin') _buildUserSelector(authProvider),
          _buildBooksSection(books, authProvider, bookProvider),
        ],
      ),
      floatingActionButton: authProvider.role == 'admin'
          ? _buildFloatingActionButton()
          : null,
    );
  }

  Widget _buildHeader(AuthProvider authProvider) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.shade600, Colors.teal.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Icon(Icons.library_books, color: Colors.white, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Thư Viện Sách',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    authProvider.role == 'admin' ? 'Quản trị viên' : 'Người dùng',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            _buildViewToggle(),
          ],
        ),
      ),
    );
  }

  Widget _buildViewToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleButton(Icons.grid_view, _isGridView, () {
            setState(() => _isGridView = true);
          }),
          _buildToggleButton(Icons.list, !_isGridView, () {
            setState(() => _isGridView = false);
          }),
        ],
      ),
    );
  }

  Widget _buildToggleButton(IconData icon, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.teal : Colors.white,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildSearchAndFilters(AuthProvider authProvider) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Search bar
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Tìm kiếm sách hoặc kệ...',
                prefixIcon: Icon(Icons.search, color: Colors.teal),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                  icon: Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),
          const SizedBox(height: 12),
          // Sort options
          Row(
            children: [
              Expanded(
                child: _buildSortChip('Tên', 'name'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSortChip('Kệ', 'shelf'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSortChip('Trạng thái', 'status'),
              ),
              const SizedBox(width: 8),
              _buildSortOrderButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSortChip(String label, String value) {
    final isSelected = _sortBy == value;
    return GestureDetector(
      onTap: () => setState(() => _sortBy = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.teal : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildSortOrderButton() {
    return GestureDetector(
      onTap: () => setState(() => _sortAscending = !_sortAscending),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.teal.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
          color: Colors.teal,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildUserSelector(AuthProvider authProvider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person_add, color: Colors.blue.shade600, size: 20),
              const SizedBox(width: 8),
              Text(
                'Chọn người dùng để mượn sách:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: DropdownButton<String>(
              value: _selectedUserId,
              hint: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text('Chọn người dùng'),
              ),
              isExpanded: true,
              underline: const SizedBox(),
              items: authProvider.users
                  .where((user) => user['role'] == 'user')
                  .map((user) {
                return DropdownMenuItem<String>(
                  value: user['uid'],
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.teal.shade100,
                          child: Icon(Icons.person, size: 16, color: Colors.teal),
                        ),
                        const SizedBox(width: 8),
                        Text(user['email']),
                      ],
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedUserId = value;
                  Provider.of<BookProvider>(context, listen: false).setUserId(value);
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBooksSection(List<Book> books, AuthProvider authProvider, BookProvider bookProvider) {
    return Expanded(
      child: books.isEmpty
          ? _buildEmptyState(authProvider)
          : _isGridView
          ? _buildGridView(books, authProvider, bookProvider)
          : _buildListView(books, authProvider, bookProvider),
    );
  }

  Widget _buildEmptyState(AuthProvider authProvider) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.menu_book_outlined,
              size: 60,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _searchQuery.isNotEmpty
                ? 'Không tìm thấy sách nào'
                : 'Chưa có sách nào trong thư viện',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? 'Hãy thử tìm kiếm với từ khóa khác'
                : authProvider.role == 'admin'
                ? 'Nhấn nút + để thêm sách mới'
                : 'Liên hệ quản trị viên để thêm sách',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridView(List<Book> books, AuthProvider authProvider, BookProvider bookProvider) {
    return RefreshIndicator(
      onRefresh: () async {
        // Refresh logic - you can implement this in BookProvider if needed
        await Future.delayed(Duration(milliseconds: 500));
      },
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverMasonryGrid.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childCount: books.length,
              itemBuilder: (context, index) {
                return _buildBookCard(books[index], authProvider, bookProvider);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListView(List<Book> books, AuthProvider authProvider, BookProvider bookProvider) {
    return RefreshIndicator(
      onRefresh: () async {
        // Refresh logic - you can implement this in BookProvider if needed
        await Future.delayed(Duration(milliseconds: 500));
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: books.length,
        itemBuilder: (context, index) {
          return _buildBookListTile(books[index], authProvider, bookProvider);
        },
      ),
    );
  }

  Widget _buildBookCard(Book book, AuthProvider authProvider, BookProvider bookProvider) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.grey.shade50,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.menu_book,
                      color: Colors.teal.shade700,
                      size: 24,
                    ),
                  ),
                  const Spacer(),
                  _buildStatusChip(book.isBorrowed),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                book.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Kệ ${book.shelfId}',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _buildActionButtons(book, authProvider, bookProvider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookListTile(Book book, AuthProvider authProvider, BookProvider bookProvider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.teal.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.menu_book,
            color: Colors.teal.shade700,
            size: 24,
          ),
        ),
        title: Text(
          book.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Kệ ${book.shelfId}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _buildStatusChip(book.isBorrowed),
              ],
            ),
          ],
        ),
        trailing: authProvider.role == 'admin'
            ? _buildPopupMenu(book, authProvider, bookProvider)
            : null,
      ),
    );
  }

  Widget _buildStatusChip(bool isBorrowed) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isBorrowed ? Colors.red.shade100 : Colors.green.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isBorrowed ? 'Đã mượn' : 'Có sẵn',
        style: TextStyle(
          color: isBorrowed ? Colors.red.shade700 : Colors.green.shade700,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildActionButtons(Book book, AuthProvider authProvider, BookProvider bookProvider) {
    if (authProvider.role != 'admin') return const SizedBox();

    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            icon: Icons.edit,
            label: 'Sửa',
            color: Colors.blue,
            onPressed: () => _showBookDialog(book),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildActionButton(
            icon: book.isBorrowed ? Icons.keyboard_return : Icons.book,
            label: book.isBorrowed ? 'Trả' : 'Mượn',
            color: book.isBorrowed ? Colors.orange : Colors.green,
            onPressed: () => _handleBorrowReturn(book, bookProvider),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildPopupMenu(Book book, AuthProvider authProvider, BookProvider bookProvider) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, color: Colors.grey.shade600),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onSelected: (value) => _handlePopupMenuAction(value, book, authProvider, bookProvider),
      itemBuilder: (context) => _buildPopupMenuItems(book, authProvider),
    );
  }

  List<PopupMenuEntry<String>> _buildPopupMenuItems(Book book, AuthProvider authProvider) {
    List<PopupMenuEntry<String>> items = [];

    if (authProvider.role == 'admin') {
      items.addAll([
        _buildPopupMenuItem(Icons.edit, 'Sửa', 'edit', Colors.blue),
        _buildPopupMenuItem(Icons.delete, 'Xóa', 'delete', Colors.red),
      ]);

      if (!book.isBorrowed) {
        items.add(_buildPopupMenuItem(Icons.book, 'Mượn', 'borrow', Colors.green));
      } else {
        items.add(_buildPopupMenuItem(Icons.keyboard_return, 'Trả', 'return', Colors.orange));
      }
    }

    return items;
  }

  PopupMenuItem<String> _buildPopupMenuItem(IconData icon, String text, String value, Color color) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(color: color, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  void _handlePopupMenuAction(String action, Book book, AuthProvider authProvider, BookProvider bookProvider) {
    switch (action) {
      case 'edit':
        _showBookDialog(book);
        break;
      case 'delete':
        _showDeleteConfirmation(book, bookProvider);
        break;
      case 'borrow':
      case 'return':
        _handleBorrowReturn(book, bookProvider);
        break;
    }
  }

  void _showBookDialog(Book? book) {
    showDialog(
      context: context,
      builder: (context) => BookDialog(book: book),
    );
  }

  void _showDeleteConfirmation(Book book, BookProvider bookProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            const SizedBox(width: 8),
            const Text('Xác nhận xóa'),
          ],
        ),
        content: Text('Bạn có chắc chắn muốn xóa sách "${book.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              bookProvider.deleteBook(book.id);
              Navigator.pop(context);
              _showSnackBar('Đã xóa sách thành công', Colors.green);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _handleBorrowReturn(Book book, BookProvider bookProvider) async {
    if (!book.isBorrowed) {
      // Borrow book
      if (_selectedUserId == null) {
        _showSnackBar('Vui lòng chọn người dùng để mượn sách', Colors.orange);
        return;
      }

      try {
        await bookProvider.borrowBook(book.id, _selectedUserId!);
        _showSnackBar('Đã cho mượn sách thành công', Colors.green);
      } catch (e) {
        _showSnackBar('Lỗi khi mượn sách: $e', Colors.red);
      }
    } else {
      // Return book
      try {
        await bookProvider.returnBook(book.id);
        _showSnackBar('Đã trả sách thành công', Colors.green);
      } catch (e) {
        _showSnackBar('Lỗi khi trả sách: $e', Colors.red);
      }
    }
  }

  Widget _buildFloatingActionButton() {
    return ScaleTransition(
      scale: _fabAnimation,
      child: FloatingActionButton.extended(
        onPressed: () => _showBookDialog(null),
        backgroundColor: Colors.teal,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Thêm sách',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}