import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' hide Response;
import 'package:dio/dio.dart';
import 'package:myapp/app/cores/models/tag_logger.dart';
import 'package:myapp/app/services/inactivity_service.dart';

import '../../../routes/app_pages.dart';
import '../../../services/backend_service.dart';
import '../../../services/device_service.dart';
import '../models/cart_item.dart';
import '../responses/product_response.dart';

class ProductController extends GetxController {
  final _log = TagLogger("ProductController");

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
      if (kDebugMode) {
        _log.e('상품 조회 에러: $error');
      } else {
        _log.e('상품 조회 실패');
      }
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

  Future<void> completePurchase() async {
    try {
      // 모든 API 요청을 병렬로 실행하고 완료를 기다림
      List<Future<Response>> requests = [];
      for (var item in cartItems) {
        requests.add(
          backendService.sendScaleData(
            phoneSuffix: inactivityService.id,
            productId: item.product.id,
            weightGram: item.weight,
          ),
        );
      }

      // 모든 요청이 성공할 때까지 대기
      await Future.wait(requests);

      // 모든 요청 성공 시에만 성공 다이얼로그 표시
      Get.dialog(CupertinoAlertDialog(
        title: const Text('전송 완료'),
        content: const Text('5초 뒤 홈으로 돌아갑니다.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('확인'),
            onPressed: () {},
          ),
        ],
      ));

      Future.delayed(const Duration(seconds: 5), () {
        cartItems.clear();
        inactivityService.reset();
      });
    } catch (error) {
      // 에러 발생 시 사용자에게 알림
      Get.dialog(CupertinoAlertDialog(
        title: const Text('전송 실패'),
        content: const Text('네트워크 오류가 발생했습니다.\n다시 시도해주세요.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('확인'),
            onPressed: () {
              Get.back();
            },
          ),
        ],
      ));

      // 에러 로깅
      if (kDebugMode) {
        _log.e('구매 완료 실패: $error');
      } else {
        _log.e('구매 처리 중 오류 발생');
      }
    }
  }

  void developFeature() {
    Get.snackbar('개발 중', '현재 개발 중인 기능입니다.');
  }
}
