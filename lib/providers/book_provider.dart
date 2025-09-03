import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quanlythuvienck/models/book.dart';
import 'package:quanlythuvienck/models/borrow_history.dart';
import 'package:quanlythuvienck/services/notification_service.dart';
import 'package:uuid/uuid.dart';

class BookProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Book> _books = [];
  List<BorrowHistory> _borrowHistory = [];
  String? _userId;

  List<Book> get books => _books;
  List<BorrowHistory> get borrowHistory => _borrowHistory;
  String? get userId => _userId;

  BookProvider() {
    _fetchBooks();
    _fetchBorrowHistory();
  }

  void setUserId(String? userId) {
    if (_userId == userId) return;
    _userId = userId;
    print('User ID updated to: $_userId');
    _fetchBorrowHistory();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void _fetchBooks() {
    _firestore.collection('books').snapshots().listen((snapshot) {
      _books =
          snapshot.docs.map((doc) => Book.fromMap(doc.data(), doc.id)).toList();
      notifyListeners();
    }, onError: (error) {
      print('Error fetching books: $error');
    });
  }

  void _fetchBorrowHistory() {
    if (_userId == null) {
      _borrowHistory = [];
      notifyListeners();
      return;
    }
    _firestore
        .collection('borrow_history')
        .where('userId', isEqualTo: _userId)
        .snapshots()
        .listen((snapshot) {
      _borrowHistory = snapshot.docs
          .map((doc) => BorrowHistory.fromMap(doc.data(), doc.id))
          .toList();
      print(
          'Borrow history updated for user $_userId: ${_borrowHistory.length}');
      notifyListeners();
    }, onError: (error) {
      print('Error fetching borrow history: $error');
    });
  }

  Future<void> addBook(Book book, String s) async {
    try {
      if (book.name.length > 30) {
        throw Exception('Tên sách vượt quá 30 ký tự!');
      }
      await _firestore.collection('books').doc(book.id).set(book.toMap());
      print('Book added successfully: ${book.name}');
    } catch (e) {
      print('Error adding book: $e');
      rethrow;
    }
  }

  Future<void> updateBook(Book book) async {
    try {
      if (book.name.length > 30) {
        throw Exception('Tên sách vượt quá 30 ký tự!');
      }
      await _firestore.collection('books').doc(book.id).update(book.toMap());
      print('Book updated successfully: ${book.name}');
    } catch (e) {
      print('Error updating book: $e');
      rethrow;
    }
  }

  Future<void> deleteBook(String id) async {
    try {
      await _firestore.collection('books').doc(id).delete();
      print('Book deleted successfully: $id');
    } catch (e) {
      print('Error deleting book: $e');
      rethrow;
    }
  }

  Future<void> borrowBook(String bookId, String adminId) async {
    if (_userId == null) {
      throw Exception('No user ID set');
    }
    try {
      await _firestore.collection('books').doc(bookId).update({
        'isBorrowed': true,
      });

      final history = BorrowHistory(
        id: Uuid().v4(),
        bookId: bookId,
        userId: _userId!,
        adminId: adminId,
        borrowDate: DateTime.now(),
      );
      await _firestore
          .collection('borrow_history')
          .doc(history.id)
          .set(history.toMap());

      final book = _books.firstWhere((b) => b.id == bookId);
      await NotificationService.showNotification(
        'Sách đã được mượn',
        'Bạn vừa mượn sách: ${book.name}',
      );
      print(
          'Book borrowed successfully: ${book.name} by user $_userId, admin $adminId');
    } catch (e) {
      print('Error borrowing book: $e');
      rethrow;
    }
  }

  Future<void> returnBook(String bookId) async {
    try {
      await _firestore.collection('books').doc(bookId).update({
        'isBorrowed': false,
      });

      final history = _borrowHistory
          .firstWhere((h) => h.bookId == bookId && h.returnDate == null);
      await _firestore.collection('borrow_history').doc(history.id).update({
        'returnDate': DateTime.now().toIso8601String(),
      });

      final book = _books.firstWhere((b) => b.id == bookId);
      await NotificationService.showNotification(
        'Sách đã được trả',
        'Bạn vừa trả sách: ${book.name}',
      );
      print('Book returned successfully: ${book.name}');
    } catch (e) {
      print('Error returning book: $e');
      rethrow;
    }
  }

  List<Book> searchBooks(String query) {
    return _books
        .where((book) => book.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}
