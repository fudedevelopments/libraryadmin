import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/book.dart';
import '../controllers/book_controller.dart';
import 'book_details.dart';

class BookList extends StatelessWidget {
  final BookController bookController = Get.find<BookController>();

  BookList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Book List',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Obx(
                  () => Text(
                    'Total: ${bookController.totalBooks.value} books',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Obx(() {
              if (bookController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (bookController.books.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text(
                      'No books found',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                );
              }

              return Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            'Title',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Author',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            'Genre',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            'Year',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 80),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: bookController.books.length,
                    separatorBuilder:
                        (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final book = bookController.books[index];
                      return _buildBookItem(book);
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildPagination(),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildBookItem(Book book) {
    return InkWell(
      onTap: () => Get.dialog(BookDetails(book: book)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(
                book.title,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            Expanded(flex: 2, child: Text(book.author)),
            Expanded(flex: 1, child: Text(book.genre ?? '-')),
            Expanded(
              flex: 1,
              child: Text(book.publicationYear?.toString() ?? '-'),
            ),
            SizedBox(
              width: 80,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: () {
                      bookController.selectBook(book);
                    },
                    tooltip: 'Edit',
                    color: Colors.blue,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 20),
                    onPressed: () => _showDeleteConfirmation(book),
                    tooltip: 'Delete',
                    color: Colors.red,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPagination() {
    return Obx(() {
      final totalPages = bookController.totalPages.value;
      final currentPage = bookController.currentPage.value;

      if (totalPages <= 1) {
        return const SizedBox.shrink();
      }

      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed:
                currentPage > 1
                    ? () => bookController.goToPage(currentPage - 1)
                    : null,
          ),
          for (int i = 1; i <= totalPages; i++)
            if (i == 1 ||
                i == totalPages ||
                (i >= currentPage - 1 && i <= currentPage + 1))
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: ElevatedButton(
                  onPressed:
                      i != currentPage
                          ? () => bookController.goToPage(i)
                          : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        i == currentPage ? Colors.blue : Colors.grey.shade200,
                    foregroundColor:
                        i == currentPage ? Colors.white : Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    minimumSize: const Size(40, 40),
                  ),
                  child: Text('$i'),
                ),
              )
            else if (i == 2 || i == totalPages - 1)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  '...',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed:
                currentPage < totalPages
                    ? () => bookController.goToPage(currentPage + 1)
                    : null,
          ),
        ],
      );
    });
  }

  void _showDeleteConfirmation(Book book) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Book'),
        content: Text('Are you sure you want to delete "${book.title}"?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Get.back();
              bookController.deleteBook(book.id);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
