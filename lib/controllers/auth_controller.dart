import 'package:get/get.dart';
import '../services/auth_service.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();
  final RxBool isLoading = false.obs;
  final RxBool isAuthenticated = false.obs;
  final RxMap<String, dynamic> userData = RxMap<String, dynamic>();

  @override
  void onInit() {
    super.onInit();
    initializeServices();
  }

  Future<void> initializeServices() async {
    try {
      await _authService.init();
      await checkAuthStatus();
    } catch (e) {
      print('Error initializing services: $e');
    }
  }

  Future<void> login(String username, String password) async {
    try {
      isLoading.value = true;
      final response = await _authService.login(username, password);
      userData.value = response['user'];
      isAuthenticated.value = true;
      Get.offAllNamed('/dashboard');
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      await _authService.logout();
      isAuthenticated.value = false;
      userData.clear();
      Get.offAllNamed('/login');
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to logout',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> checkAuthStatus() async {
    final token = await _authService.getToken();
    isAuthenticated.value = token != null;

    if (isAuthenticated.value) {
      Get.offAllNamed('/dashboard');
    }
  }
}
