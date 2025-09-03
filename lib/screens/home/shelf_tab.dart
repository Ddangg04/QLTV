import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quanlythuvienck/models/book.dart';
import 'package:quanlythuvienck/providers/auth_provider.dart';
import 'package:quanlythuvienck/providers/book_provider.dart';
import 'package:quanlythuvienck/widgets/book_dialog.dart';

class ShelfTab extends StatefulWidget {
  @override
  _ShelfTabState createState() => _ShelfTabState();
}

class _ShelfTabState extends State<ShelfTab> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
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
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final books = Provider.of<BookProvider>(context).books;

    // Gom nhóm sách theo kệ với màu sắc tùy chỉnh
    Map<String, Map<String, dynamic>> shelves = {
      'A': {
        'books': <Book>[],
        'color': Colors.purple,
        'gradient': [Colors.purple.shade400, Colors.purple.shade600],
        'icon': Icons.auto_stories,
      },
      'B': {
        'books': <Book>[],
        'color': Colors.teal,
        'gradient': [Colors.teal.shade400, Colors.teal.shade600],
        'icon': Icons.library_books,
      },
      'C': {
        'books': <Book>[],
        'color': Colors.orange,
        'gradient': [Colors.orange.shade400, Colors.orange.shade600],
        'icon': Icons.menu_book,
      },
    };

    for (var book in books) {
      shelves[book.shelfId]?['books']?.add(book);
    }

    bool isEmpty = shelves.values.every((shelf) => (shelf['books'] as List).isEmpty);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.grey.shade50,
            Colors.grey.shade100,
          ],
        ),
      ),
      child: isEmpty
          ? _buildEmptyState()
          : FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    String shelfId = shelves.keys.elementAt(index);
                    Map<String, dynamic> shelfData = shelves[shelfId]!;
                    List<Book> booksInShelf = shelfData['books'];

                    return TweenAnimationBuilder<double>(
                      duration: Duration(milliseconds: 600 + (index * 200)),
                      tween: Tween(begin: 0.0, end: 1.0),
                      curve: Curves.elasticOut,
                      builder: (context, value, child) {
                        return Transform.translate(
                          offset: Offset(0, 50 * (1 - value)),
                          child: Opacity(
                            opacity: value,
                            child: _buildShelfCard(
                              context,
                              shelfId,
                              booksInShelf,
                              shelfData,
                            ),
                          ),
                        );
                      },
                    );
                  },
                  childCount: shelves.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            duration: Duration(seconds: 2),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.scale(
                scale: 0.8 + (0.2 * value),
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.purple.shade300, Colors.purple.shade500],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.auto_stories,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 30),
          Text(
            'Thư viện trống',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: 10),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Sử dụng các chức năng ở phía dưới màn hình để thêm sách vào thư viện.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShelfCard(BuildContext context, String shelfId, List<Book> books, Map<String, dynamic> shelfData) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(20),
        shadowColor: (shelfData['color'] as Color).withOpacity(0.3),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: shelfData['gradient'],
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => ShelfDetailPage(
                    shelfId: shelfId,
                    books: books,
                    shelfColor: shelfData['color'],
                    shelfIcon: shelfData['icon'],
                  ),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: Offset(1.0, 0.0),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeInOut,
                      )),
                      child: child,
                    );
                  },
                ),
              );
            },
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  Hero(
                    tag: 'shelf_$shelfId',
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        shelfData['icon'],
                        size: 35,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kệ $shelfId',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.book,
                              size: 16,
                              color: Colors.white.withOpacity(0.8),
                            ),
                            SizedBox(width: 5),
                            Text(
                              '${books.length} quyển sách',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 5),
                        Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 16,
                              color: Colors.green.shade200,
                            ),
                            SizedBox(width: 5),
                            Text(
                              '${books.where((b) => !b.isBorrowed).length} có sẵn',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Trang chi tiết kệ sách được cải tiến
class ShelfDetailPage extends StatefulWidget {
  final String shelfId;
  final List<Book> books;
  final Color shelfColor;
  final IconData shelfIcon;

  const ShelfDetailPage({
    Key? key,
    required this.shelfId,
    required this.books,
    required this.shelfColor,
    required this.shelfIcon,
  }) : super(key: key);

  @override
  _ShelfDetailPageState createState() => _ShelfDetailPageState();
}

class _ShelfDetailPageState extends State<ShelfDetailPage> with TickerProviderStateMixin {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedUserId;
  late AnimationController _listAnimationController;

  @override
  void initState() {
    super.initState();
    _listAnimationController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    _listAnimationController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _listAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookProvider = Provider.of<BookProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    final filteredBooks = _searchQuery.isEmpty
        ? widget.books
        : widget.books
        .where((book) => book.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(child: _buildSearchBar()),
          if (authProvider.role == 'admin')
            SliverToBoxAdapter(child: _buildUserSelector(authProvider, bookProvider)),
          _buildBookList(filteredBooks, authProvider),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      backgroundColor: widget.shelfColor,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Kệ ${widget.shelfId}',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.shelfColor.withOpacity(0.8),
                widget.shelfColor,
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -50,
                top: -50,
                child: Hero(
                  tag: 'shelf_${widget.shelfId}',
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      widget.shelfIcon,
                      size: 100,
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 20,
                bottom: 60,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.books.length} quyển sách',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '${widget.books.where((b) => !b.isBorrowed).length} có sẵn',
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
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          labelText: 'Tìm kiếm sách trong kệ ${widget.shelfId}',
          prefixIcon: Icon(Icons.search, color: widget.shelfColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildUserSelector(AuthProvider authProvider, BookProvider bookProvider) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person, color: widget.shelfColor),
              SizedBox(width: 8),
              Text(
                'Chọn người dùng để mượn sách:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(10),
            ),
            child: DropdownButton<String>(
              value: _selectedUserId,
              hint: Text('Chọn người dùng'),
              isExpanded: true,
              underline: SizedBox(),
              items: authProvider.users
                  .where((user) => user['role'] == 'user')
                  .map((user) {
                return DropdownMenuItem<String>(
                  value: user['uid'],
                  child: Text(user['email']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedUserId = value;
                  bookProvider.setUserId(value);
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookList(List<Book> filteredBooks, AuthProvider authProvider) {
    if (filteredBooks.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: widget.shelfColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.book_outlined,
                  size: 50,
                  color: widget.shelfColor,
                ),
              ),
              SizedBox(height: 20),
              Text(
                _searchQuery.isEmpty
                    ? 'Kệ ${widget.shelfId} không có sách nào'
                    : 'Không tìm thấy sách phù hợp',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
              (context, index) {
            final book = filteredBooks[index];
            return AnimatedBuilder(
              animation: _listAnimationController,
              builder: (context, child) {
                final itemAnimation = Tween<double>(
                  begin: 0.0,
                  end: 1.0,
                ).animate(CurvedAnimation(
                  parent: _listAnimationController,
                  curve: Interval(
                    (index * 0.1).clamp(0.0, 1.0),
                    ((index * 0.1) + 0.3).clamp(0.0, 1.0),
                    curve: Curves.easeOut,
                  ),
                ));

                return Transform.translate(
                  offset: Offset(0, 50 * (1 - itemAnimation.value)),
                  child: Opacity(
                    opacity: itemAnimation.value,
                    child: _buildBookCard(book, authProvider, index),
                  ),
                );
              },
            );
          },
          childCount: filteredBooks.length,
        ),
      ),
    );
  }

  Widget _buildBookCard(Book book, AuthProvider authProvider, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(15),
        shadowColor: Colors.grey.withOpacity(0.2),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Colors.grey.shade50,
              ],
            ),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.all(16),
            leading: Hero(
              tag: 'book_${book.id}',
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      widget.shelfColor.withOpacity(0.7),
                      widget.shelfColor,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: widget.shelfColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.book,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
            title: Text(
              book.name,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            subtitle: Container(
              margin: EdgeInsets.only(top: 8),
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: book.isBorrowed ? Colors.red.shade50 : Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: book.isBorrowed ? Colors.red.shade200 : Colors.green.shade200,
                ),
              ),
              child: Text(
                book.isBorrowed ? 'Đã được mượn' : 'Có sẵn',
                style: TextStyle(
                  color: book.isBorrowed ? Colors.red.shade700 : Colors.green.shade700,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
            trailing: _buildActionMenu(book, authProvider),
          ),
        ),
      ),
    );
  }

  Widget _buildActionMenu(Book book, AuthProvider authProvider) {
    return Container(
      decoration: BoxDecoration(
        color: widget.shelfColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: PopupMenuButton<String>(
        icon: Icon(Icons.more_vert, color: widget.shelfColor),
        onSelected: (value) async {
          if (value == 'edit' && authProvider.role == 'admin') {
            showDialog(
              context: context,
              builder: (context) => BookDialog(book: book),
            );
          } else if (value == 'delete' && authProvider.role == 'admin') {
            _showDeleteConfirmation(book);
          } else if (value == 'borrow' && authProvider.role == 'admin') {
            _borrowBook(book);
          } else if (value == 'return' && authProvider.role == 'admin') {
            _returnBook(book);
          }
        },
        itemBuilder: (context) {
          List<PopupMenuItem<String>> items = [];
          if (authProvider.role == 'admin') {
            items.addAll([
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 20, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Sửa', style: TextStyle(color: Colors.blue)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 20, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Xóa', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ]);
          }
          if (authProvider.role == 'admin' && !book.isBorrowed) {
            items.add(PopupMenuItem(
              value: 'borrow',
              child: Row(
                children: [
                  Icon(Icons.person_add, size: 20, color: Colors.green),
                  SizedBox(width: 8),
                  Text('Mượn', style: TextStyle(color: Colors.green)),
                ],
              ),
            ));
          }
          if (authProvider.role == 'admin' && book.isBorrowed) {
            items.add(PopupMenuItem(
              value: 'return',
              child: Row(
                children: [
                  Icon(Icons.assignment_return, size: 20, color: Colors.orange),
                  SizedBox(width: 8),
                  Text('Trả', style: TextStyle(color: Colors.orange)),
                ],
              ),
            ));
          }
          return items;
        },
      ),
    );
  }

  void _showDeleteConfirmation(Book book) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 8),
            Text('Xác nhận xóa'),
          ],
        ),
        content: Text('Bạn có chắc chắn muốn xóa sách "${book.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await Provider.of<BookProvider>(context, listen: false)
                    .deleteBook(book.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Xóa sách thành công!'),
                      ],
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.error, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Lỗi khi xóa sách: $e'),
                      ],
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _borrowBook(Book book) async {
    if (_selectedUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning, color: Colors.white),
              SizedBox(width: 8),
              Text('Vui lòng chọn người dùng để mượn sách'),
            ],
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await Provider.of<BookProvider>(context, listen: false)
          .borrowBook(book.id, authProvider.user!.uid);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Mượn sách thành công!'),
            ],
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 8),
              Text('Lỗi khi mượn sách: $e'),
            ],
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _returnBook(Book book) async {
    try {
      await Provider.of<BookProvider>(context, listen: false)
          .returnBook(book.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Trả sách thành công!'),
            ],
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 8),
              Text('Lỗi khi trả sách: $e'),
            ],
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}