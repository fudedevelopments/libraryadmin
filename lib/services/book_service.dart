import 'package:dio/dio.dart';
import '../models/book.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://libarybackend.fudedevelopments.workers.dev',
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 3),
    ),
  );
  static const String _tokenKey = 'auth_token';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<Map<String, dynamic>> getBooks({int page = 1}) async {
    try {
      final response = await _dio.get(
        '/books',
        queryParameters: {'page': page},
      );

      if (response.statusCode == 200) {
        final List<Book> books =
            (response.data['data'] as List)
                .map((bookJson) => Book.fromJson(bookJson))
                .toList();

        return {'books': books, 'pagination': response.data['pagination']};
      }
      throw Exception('Failed to fetch books');
    } catch (e) {
      throw Exception('Failed to fetch books: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> searchBooks({
    String? title,
    String? author,
    String? genre,
    String? year,
    int page = 1,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {'page': page};

      if (title != null && title.isNotEmpty) queryParams['title'] = title;
      if (author != null && author.isNotEmpty) queryParams['author'] = author;
      if (genre != null && genre.isNotEmpty) queryParams['genre'] = genre;
      if (year != null && year.isNotEmpty) queryParams['year'] = year;

      final response = await _dio.get(
        '/books/search',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final List<Book> books =
            (response.data['data'] as List)
                .map((bookJson) => Book.fromJson(bookJson))
                .toList();

        return {'books': books, 'pagination': response.data['pagination']};
      }
      throw Exception('Failed to search books');
    } catch (e) {
      throw Exception('Failed to search books: ${e.toString()}');
    }
  }

  Future<Book> getBookById(String id) async {
    try {
      final response = await _dio.get('/books/$id');

      if (response.statusCode == 200) {
        return Book.fromJson(response.data);
      }
      throw Exception('Failed to fetch book');
    } catch (e) {
      throw Exception('Failed to fetch book: ${e.toString()}');
    }
  }

  Future<void> createBook(Book book) async {
    try {
      final token = await _getToken();

      // Log the request data for debugging
      print('Creating book with data: ${book.toJson()}');

      final response = await _dio.post(
        '/books',
        data: book.toJson(),
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          validateStatus:
              (status) => status! < 500, 
        ),
      );

      // Log the response for debugging
      print('Create book response: ${response.statusCode} - ${response.data}');

      if (response.statusCode != 201) {
        throw Exception(
          'Failed to create book: ${response.statusCode} - ${response.data}',
        );
      }
    } catch (e) {
      print('Create book error: $e');
      throw Exception('Failed to create book: ${e.toString()}');
    }
  }

  Future<void> updateBook(Book book) async {
    if (book.id == null) {
      throw Exception('Cannot update book: ID is null');
    }

    try {
      final token = await _getToken();

      final response = await _dio.put(
        '/books/${book.id}',
        data: book.toJson(),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update book');
      }
    } catch (e) {
      throw Exception('Failed to update book: ${e.toString()}');
    }
  }

  Future<void> deleteBook(String? id) async {
    if (id == null) {
      throw Exception('Cannot delete book: ID is null');
    }

    try {
      final token = await _getToken();

      final response = await _dio.delete(
        '/books/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete book');
      }
    } catch (e) {
      throw Exception('Failed to delete book: ${e.toString()}');
    }
  }
}
