import 'package:get/get.dart' hide Response;
import 'package:dio/dio.dart';
import 'package:myapp/app/services/inactivity_service.dart';

import '../../../routes/app_pages.dart';
import '../../../services/backend_service.dart';
import '../../../services/device_service.dart';
import '../models/cart_item.dart';
import '../responses/product_response.dart';

class ProductController extends GetxController {
  // 1. 서비스 인스턴스를 가져오는 게터
  BackendService get backendService => Get.find<BackendService>();

  InactivityService get inactivityService => Get.find<InactivityService>();

  DeviceService get deviceService => Get.find<DeviceService>();

  // 2. 상태 변수들을 Rx 타입으로 명시적 선언
  RxBool isLoading = true.obs;
  RxList<Product> allProducts = RxList<Product>();
  RxMap<String, List<Product>> productsByCategory =
      RxMap<String, List<Product>>();
  final RxList<CartItem> cartItems = RxList<CartItem>();

  // 3. onInit에서 데이터 요청 시작
  @override
  void onInit() {
    super.onInit();
    fetchProducts();
  }

  // 4. 데이터 로딩 함수 (.then 사용)
  void fetchProducts() {
    isLoading(true);
    backendService.getProducts().then((response) {
      // 성공 시 응답 처리 함수 호출
      handleResponse(response);
    }).catchError((error) {
      // 에러 처리
      print('상품 조회 에러: $error');
    }).whenComplete(() {
      // 성공/실패 여부와 관계없이 항상 실행
      isLoading(false);
    });
  }

  // 5. 응답 데이터를 가공하고 상태를 업데이트하는 함수
  void handleResponse(Response response) {
    final productResponse = ProductResponse.fromJson(response.data);
    // assignAll: RxList의 모든 아이템을 새로운 리스트로 교체
    allProducts.assignAll(productResponse.products);
    _groupProductsByCategory();
  }

  // 상품 리스트를 카테고리별로 묶어주는 내부 함수
  void _groupProductsByCategory() {
    final groupedProducts = <String, List<Product>>{};
    for (var product in allProducts) {
      if (groupedProducts.containsKey(product.category)) {
        groupedProducts[product.category]!.add(product);
      } else {
        groupedProducts[product.category] = [product];
      }
    }
    // RxMap의 모든 데이터를 새로운 맵으로 교체
    productsByCategory.value = groupedProducts;
  }

  // 사용자가 상품을 선택했을 때 호출될 함수
  void selectProduct(Product product) {
    Get.toNamed(Routes.PRICE, arguments: {'product': product})?.then((data) {
      if (data == null) return;
      final product = data['product'] as Product;
      final weight = data['weight'];
      final price = data['price'] as int;
      addItemToCart(product, weight, price);
    });
  }

  void addItemToCart(Product product, int weight, int price) {
    final newItem = CartItem(product: product, weight: weight, price: price);
    cartItems.add(newItem);
  }

  int get totalCartPrice {
    return cartItems.fold(0, (sum, item) => sum + item.price);
  }

  void completePurchase() {
    for (var item in cartItems) {
      backendService.sendScaleData(
          phoneSuffix: inactivityService.id,
          productId: item.product.id,
          weightGram: item.weight);
    }
    cartItems.clear();
    deviceService.resetWeights();
    inactivityService.reset();
    Get.offAllNamed(Routes.DEFAULT_ROUTE);
  }

  void developFeature() {
    Get.snackbar('개발 중', '현재 개발 중인 기능입니다.');
  }
}
