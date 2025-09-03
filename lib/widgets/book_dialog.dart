import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quanlythuvienck/models/book.dart';
import 'package:quanlythuvienck/providers/book_provider.dart';
import 'package:uuid/uuid.dart';

class BookDialog extends StatefulWidget {
  final Book? book;

  const BookDialog({this.book});

  @override
  _BookDialogState createState() => _BookDialogState();
}

class _BookDialogState extends State<BookDialog> {
  final _nameController = TextEditingController();
  String _selectedShelf = 'A';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.book != null) {
      _nameController.text = widget.book!.name;
      _selectedShelf = widget.book!.shelfId;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveBook() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _showSnackBar('Vui lòng nhập tên sách!', Colors.red);
      return;
    }

    if (name.length > 30) {
      _showSnackBar(
        'Tên sách vượt quá 30 ký tự! Vui lòng rút ngắn.',
        Colors.orange,
        action: SnackBarAction(
          label: 'Tiếp tục',
          textColor: Colors.white,
          onPressed: () => _proceedSave(),
        ),
      );
      return;
    }

    await _proceedSave();
  }

  Future<void> _proceedSave() async {
    setState(() => _isLoading = true);
    try {
      final bookProvider = Provider.of<BookProvider>(context, listen: false);
      final book = Book(
        id: widget.book?.id ?? Uuid().v4(),
        name: _nameController.text.trim(),
        shelfId: _selectedShelf,
        isBorrowed: widget.book?.isBorrowed ?? false,
      );

      if (widget.book == null) {
        // Provide the required second argument for addBook, e.g., context or another parameter as defined in BookProvider
        await bookProvider.addBook(book, book.name);
        _showSnackBar('Thêm sách thành công!', Colors.green);
      } else {
        await bookProvider.updateBook(book);
        _showSnackBar('Cập nhật sách thành công!', Colors.green);
      }
      Navigator.of(context).pop(true);
    } catch (e) {
      _showSnackBar(e.toString().replaceAll('Exception: ', ''), Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, Color color, {SnackBarAction? action}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: Duration(seconds: 3),
        action: action,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.book == null ? 'Thêm sách' : 'Sửa sách'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Tên sách (tối đa 30 ký tự)',
              border: OutlineInputBorder(),
              counterText: '${_nameController.text.length}/30',
              helperText: 'Nhập tên sách, thông báo nếu vượt 30 ký tự',
            ),
            onChanged: (value) => setState(() {}),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Text('Kệ sách: '),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButton<String>(
                  value: _selectedShelf,
                  isExpanded: true,
                  items: ['A', 'B', 'C'].map((shelf) {
                    return DropdownMenuItem<String>(
                      value: shelf,
                      child: Text('Kệ $shelf'),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedShelf = value!),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Hủy'),
        ),
        TextButton(
          onPressed: _isLoading ? null : _saveBook,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.book == null ? 'Thêm' : 'Lưu'),
        ),
      ],
    );
  }
}
