class BorrowHistory {
  final String id;
  final String bookId;
  final String userId;
  final String adminId;
  final DateTime borrowDate;
  final DateTime? returnDate;

  BorrowHistory({
    required this.id,
    required this.bookId,
    required this.userId,
    required this.adminId,
    required this.borrowDate,
    this.returnDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bookId': bookId,
      'userId': userId,
      'adminId': adminId,
      'borrowDate': borrowDate.toIso8601String(),
      'returnDate': returnDate?.toIso8601String(),
    };
  }

  factory BorrowHistory.fromMap(Map<String, dynamic> map, String id) {
    return BorrowHistory(
      id: id,
      bookId: map['bookId'] ?? '',
      userId: map['userId'] ?? '',
      adminId: map['adminId'] ?? '',
      borrowDate: DateTime.parse(map['borrowDate']),
      returnDate: map['returnDate'] != null ? DateTime.parse(map['returnDate']) : null,
    );
  }
}