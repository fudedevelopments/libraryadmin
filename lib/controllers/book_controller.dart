import 'package:get/get.dart';
import '../models/book.dart';
import '../services/book_service.dart';

class BookController extends GetxController {
  final BookService _bookService = BookService();

  final RxList<Book> books = <Book>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSearching = false.obs;
  final RxString errorMessage = ''.obs;

  // Pagination
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;
  final RxInt totalBooks = 0.obs;

  // Search filters
  final RxString searchTitle = ''.obs;
  final RxString searchAuthor = ''.obs;
  final RxString searchGenre = ''.obs;
  final RxString searchYear = ''.obs;

  // Selected book for editing
  final Rx<Book?> selectedBook = Rx<Book?>(null);

  @override
  void onInit() {
    super.onInit();
    fetchBooks();
  }

  Future<void> fetchBooks() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await _bookService.getBooks(page: currentPage.value);

      books.value = result['books'] as List<Book>;

      final pagination = result['pagination'] as Map<String, dynamic>;
      totalPages.value = pagination['pages'] as int;
      totalBooks.value = pagination['total'] as int;

      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = e.toString();
    }
  }

  Future<void> searchBooks() async {
    try {
      isLoading.value = true;
      isSearching.value = true;
      errorMessage.value = '';

      final result = await _bookService.searchBooks(
        title: searchTitle.value,
        author: searchAuthor.value,
        genre: searchGenre.value,
        year: searchYear.value,
        page: currentPage.value,
      );

      books.value = result['books'] as List<Book>;

      final pagination = result['pagination'] as Map<String, dynamic>;
      totalPages.value = pagination['pages'] as int;
      totalBooks.value = pagination['total'] as int;

      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = e.toString();
    }
  }

  void clearSearch() {
    searchTitle.value = '';
    searchAuthor.value = '';
    searchGenre.value = '';
    searchYear.value = '';
    isSearching.value = false;
    currentPage.value = 1;
    fetchBooks();
  }

  void goToPage(int page) {
    if (page < 1 || page > totalPages.value) return;

    currentPage.value = page;

    if (isSearching.value) {
      searchBooks();
    } else {
      fetchBooks();
    }
  }

  Future<void> createBook(Book book) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _bookService.createBook(book);

      // Refresh the book list
      fetchBooks();

      Get.back(); // Close dialog/form
      Get.snackbar('Success', 'Book created successfully');
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = e.toString();
      Get.snackbar('Error', 'Failed to create book: ${e.toString()}');
    }
  }

  Future<void> updateBook(Book book) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _bookService.updateBook(book);

      // Refresh the book list
      if (isSearching.value) {
        searchBooks();
      } else {
        fetchBooks();
      }

      selectedBook.value = null;
      Get.back(); // Close dialog/form
      Get.snackbar('Success', 'Book updated successfully');
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = e.toString();
      Get.snackbar('Error', 'Failed to update book: ${e.toString()}');
    }
  }

  Future<void> deleteBook(String? id) async {
    if (id == null) {
      errorMessage.value = 'Cannot delete book: ID is null';
      Get.snackbar('Error', 'Cannot delete book: ID is null');
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _bookService.deleteBook(id);

      // Refresh the book list
      if (isSearching.value) {
        searchBooks();
      } else {
        fetchBooks();
      }

      Get.snackbar('Success', 'Book deleted successfully');
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = e.toString();
      Get.snackbar('Error', 'Failed to delete book: ${e.toString()}');
    }
  }

  void selectBook(Book book) {
    selectedBook.value = book;
  }

  void clearSelectedBook() {
    selectedBook.value = null;
  }
}
