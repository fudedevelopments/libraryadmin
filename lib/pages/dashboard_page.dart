import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/book_controller.dart';
import '../components/book_search.dart';
import '../components/book_list.dart';
import '../components/book_form.dart';
import '../models/book.dart';

class DashboardPage extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();
  final BookController bookController = Get.find<BookController>();
  final RxInt _selectedIndex = 0.obs;

  DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NEC Library Admin'),
        backgroundColor: Colors.grey.shade300,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authController.logout(),
          ),
        ],
      ),
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 250,
            color: Colors.blue.shade900,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.blue.shade800,
                  child: Row(
                    children: [
                      const CircleAvatar(child: Icon(Icons.person)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Obx(
                              () => Text(
                                authController.userData['username'] ?? '',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Obx(
                              () => Text(
                                authController.userData['role'] ?? '',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Obx(
                  () => ListTile(
                    leading: const Icon(Icons.dashboard, color: Colors.white),
                    title: const Text(
                      'Dashboard',
                      style: TextStyle(color: Colors.white),
                    ),
                    selected: _selectedIndex.value == 0,
                    selectedTileColor: Colors.blue.shade800,
                    onTap: () => _selectedIndex.value = 0,
                  ),
                ),
                Obx(
                  () => ListTile(
                    leading: const Icon(Icons.settings, color: Colors.white),
                    title: const Text(
                      'Settings',
                      style: TextStyle(color: Colors.white),
                    ),
                    selected: _selectedIndex.value == 1,
                    selectedTileColor: Colors.blue.shade800,
                    onTap: () => _selectedIndex.value = 1,
                  ),
                ),
              ],
            ),
          ),
          // Main Content
          Expanded(
            child: Obx(() {
              if (_selectedIndex.value == 0) {
                return _buildDashboardContent();
              } else {
                return _buildSettingsContent();
              }
            }),
          ),
        ],
      ),
      // Observer for selected book to show edit dialog
      floatingActionButton: Obx(() {
        final Book? selectedBook = bookController.selectedBook.value;
        if (selectedBook != null) {
          // Use Future.microtask to show dialog after the build is complete
          Future.microtask(() {
            Get.dialog(
              BookForm(book: selectedBook, isEditing: true),
            ).then((_) => bookController.clearSelectedBook());
          });
        }
        return const SizedBox.shrink();
      }),
    );
  }

  Widget _buildDashboardContent() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Book Management',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add Book'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onPressed: () => Get.dialog(const BookForm()),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  BookSearch(),
                  const SizedBox(height: 24),
                  BookList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsContent() {
    return Center(child: Text("settings"));
  }
}
