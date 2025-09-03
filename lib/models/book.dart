class Book {
  String id;
  String name;
  String shelfId;
  bool isBorrowed;

  Book({
    required this.id,
    required this.name,
    required this.shelfId,
    this.isBorrowed = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'shelfId': shelfId,
      'isBorrowed': isBorrowed,
    };
  }

  factory Book.fromMap(Map<String, dynamic> map, String id) {
    return Book(
      id: id,
      name: map['name'] ?? '',
      shelfId: map['shelfId'] ?? '',
      isBorrowed: map['isBorrowed'] ?? false,
    );
  }
}