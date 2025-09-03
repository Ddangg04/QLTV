import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quanlythuvienck/providers/book_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MockFirestore extends Mock implements FirebaseFirestore {}

class MockCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

class MockDocumentReference extends Mock implements DocumentReference<Map<String, dynamic>> {}

void main() {
  late MockFirestore mockFirestore;
  late MockCollectionReference mockCollection;
  late BookProvider bookProvider;
  late MockDocumentReference mockDocumentReference;

  setUp(() {
    mockFirestore = MockFirestore();
    mockCollection = MockCollectionReference();
    mockDocumentReference = MockDocumentReference();
    bookProvider = BookProvider();

    when(mockFirestore.collection('books')).thenReturn(mockCollection);
    when(mockCollection.add(any)).thenAnswer((_) async => mockDocumentReference);
  });

  test('addBook should call Firestore add', () async {
    await bookProvider.addBook('Test Book', 'A');
    verify(mockCollection.add({
      'name': 'Test Book',
      'shelfId': 'A',
      'isBorrowed': false,
    })).called(1);
  });
}
