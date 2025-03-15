import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/book.dart';
import '../controllers/book_controller.dart';

class BookForm extends StatefulWidget {
  final Book? book;
  final bool isEditing;

  const BookForm({Key? key, this.book, this.isEditing = false})
    : super(key: key);

  @override
  State<BookForm> createState() => _BookFormState();
}

class _BookFormState extends State<BookForm> {
  final _formKey = GlobalKey<FormState>();
  final BookController bookController = Get.find<BookController>();

  late TextEditingController _titleController;
  late TextEditingController _authorController;
  late TextEditingController _genreController;
  late TextEditingController _yearController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(text: widget.book?.title ?? '');
    _authorController = TextEditingController(text: widget.book?.author ?? '');
    _genreController = TextEditingController(text: widget.book?.genre ?? '');
    _yearController = TextEditingController(
      text: widget.book?.publicationYear?.toString() ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.book?.description ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _genreController.dispose();
    _yearController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      int? year;
      if (_yearController.text.isNotEmpty) {
        year = int.tryParse(_yearController.text);
      }

      if (widget.isEditing && widget.book != null) {
        final updatedBook = widget.book!.copyWith(
          title: _titleController.text,
          author: _authorController.text,
          genre: _genreController.text.isEmpty ? null : _genreController.text,
          publicationYear: year,
          description:
              _descriptionController.text.isEmpty
                  ? null
                  : _descriptionController.text,
        );

        bookController.updateBook(updatedBook);
      } else {
        final newBook = Book(
          // Don't send ID for new books, let the server generate it
          title: _titleController.text,
          author: _authorController.text,
          genre: _genreController.text.isEmpty ? null : _genreController.text,
          publicationYear: year,
          description:
              _descriptionController.text.isEmpty
                  ? null
                  : _descriptionController.text,
        );

        bookController.createBook(newBook);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.isEditing ? 'Edit Book' : 'Add New Book',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _authorController,
                decoration: const InputDecoration(
                  labelText: 'Author',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an author';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _genreController,
                decoration: const InputDecoration(
                  labelText: 'Genre',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _yearController,
                decoration: const InputDecoration(
                  labelText: 'Publication Year',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final year = int.tryParse(value);
                    if (year == null) {
                      return 'Please enter a valid year';
                    }
                    if (year < 0 || year > DateTime.now().year) {
                      return 'Please enter a valid year';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 16),
                  Obx(
                    () => ElevatedButton(
                      onPressed:
                          bookController.isLoading.value ? null : _submitForm,
                      child: Text(widget.isEditing ? 'Update' : 'Create'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
