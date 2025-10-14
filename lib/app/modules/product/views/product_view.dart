import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:myapp/app/cores/bases/base_view.dart';
import 'package:myapp/app/cores/widgets/appbar.dart';
import 'package:myapp/app/modules/product/controllers/product_controller.dart';
import 'package:shimmer/shimmer.dart';

import '../../../cores/values/app_colors.dart';
import '../models/cart_item.dart';
import '../responses/product_response.dart';

class ProductView extends BaseView<ProductController> {
  ProductView({super.key});

  @override
  PreferredSizeWidget? appBar(BuildContext context) {
    return MyAppbar.stepProgressAppBar(totalSteps: 5, currentStep: 4);
  }

  @override
  Widget body(BuildContext context) {
    return Obx(() {
      // Row 바깥을 Obx로 감싸서 로딩 상태에 따라 전체 UI를 교체합니다.
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            // 로딩 중이면 Shimmer 효과를, 아니면 실제 상품 그리드를 보여줍니다.
            child: controller.isLoading.value
                ? _buildShimmerEffect()
                : _buildProductGrid(),
          ),
          // 영수증 부분은 로딩과 관계없이 cartItems에 따라 표시됩니다.
          _buildReceipt()
        ],
      );
    });
  }

  Widget _buildShimmerEffect() {
    return Shimmer.fromColors(
      // Shimmer 효과의 색상을 정의합니다.
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: ListView.builder(
        itemCount: 3, // 보통 2~3개의 카테고리 뼈대를 미리 보여줍니다.
        itemBuilder: (context, index) => _buildShimmerCategorySection(),
      ),
    );
  }

  /// 카테고리 섹션의 Shimmer 버전
  Widget _buildShimmerCategorySection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 카테고리 제목 뼈대
          Container(
            width: 100,
            height: 22,
            margin: const EdgeInsets.symmetric(horizontal: 24.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 12),
          // 상품 아이템 그리드 뼈대
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 150.0,
              childAspectRatio: 140 / 200,
              crossAxisSpacing: 8,
              mainAxisSpacing: 12,
            ),
            itemCount: 4,
            // 각 카테고리마다 4개의 아이템 뼈대를 보여줍니다.
            itemBuilder: (context, index) => _buildShimmerProductItem(),
          ),
        ],
      ),
    );
  }

  /// 개별 상품 아이템의 Shimmer 버전
  Widget _buildShimmerProductItem() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 이미지 뼈대
        AspectRatio(
          aspectRatio: 1.0,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 8),
        // 텍스트 라인 뼈대
        Container(
          width: double.infinity,
          height: 16,
          margin: const EdgeInsets.only(left: 8, right: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 80, // 두 번째 라인은 조금 더 짧게
          height: 16,
          margin: const EdgeInsets.only(left: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ],
    );
  }

  // 카테고리별 상품 리스트 위젯
  Widget _buildProductGrid() {
    return ListView.builder(
      // 컨트롤러에 있는 카테고리 키의 개수만큼 아이템을 생성합니다.
      itemCount: controller.productsByCategory.keys.length,
      itemBuilder: (context, index) {
        String category = controller.productsByCategory.keys.elementAt(index);
        List<Product> products = controller.productsByCategory[category]!;
        return _buildCategorySection(category, products);
      },
    );
  }

  // 개별 카테고리 섹션 위젯
  Widget _buildCategorySection(String category, List<Product> products) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(category,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 12),
          // [수정!] GridView.builder로 변경
          GridView.builder(
            // 1. GridView가 자식의 크기만큼만 높이를 차지하도록 설정 (ListView 내부에서 필수)
            shrinkWrap: true,
            // 2. GridView 자체의 스크롤은 비활성화 (바깥의 ListView가 스크롤 담당)
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            // 3. 그리드 레이아웃을 정의하는 부분
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              // 4. 각 아이템의 최대 가로 너비. 이 값 기준으로 화면에 몇개가 들어갈지 자동 계산됨.
              maxCrossAxisExtent: 150.0,
              // 5. 아이템의 (가로 너비 / 세로 높이) 비율. 아이템 위젯의 크기에 맞춰 조절 필요.
              childAspectRatio: 140 / 200,
              // 아이템 간의 가로/세로 간격
              crossAxisSpacing: 8,
              mainAxisSpacing: 12,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return _buildProductItem(product);
            },
          ),
        ],
      ),
    );
  }

  // 개별 상품 아이템 위젯
  Widget _buildProductItem(Product product) {
    return GestureDetector(
        onTap: () {
          controller.selectProduct(product);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1.0,
              // [수정!] AnimatedContainer -> Container로 변경하여 애니메이션 제거
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    product.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.broken_image_rounded,
                        size: 50,
                        color: Colors.grey),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(
                product.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ));
  }

  Widget _buildReceipt() {
    // Obx로 cartItems 리스트의 변화를 감지
    return Obx(() {
      // 장바구니가 비어있으면 아무것도 표시하지 않음
      if (controller.cartItems.isEmpty) {
        return const SizedBox.shrink();
      }
      // 장바구니에 상품이 있으면 영수증 UI 표시
      return Container(
        width: 350,
        height: double.infinity,
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F8F8),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 5),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 영수증 아이템 리스트
            Expanded(
              child: ListView.separated(
                itemCount: controller.cartItems.length,
                itemBuilder: (context, index) {
                  return _buildReceiptItem(
                      controller.cartItems[index], index + 1);
                },
                separatorBuilder: (context, index) => const Divider(height: 24),
              ),
            ),
            const Divider(height: 30),
            // 총 가격 및 버튼
            _buildReceiptFooter(),
          ],
        ),
      );
    });
  }

  // 영수증에 표시될 개별 아이템 위젯
  Widget _buildReceiptItem(CartItem item, int index) {
    final formatter = NumberFormat('#,###');
    return Row(
      // [수정] crossAxisAlignment.start 추가하여 아이템들을 위쪽으로 정렬
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 인덱스 번호
        Container(
          height: 24,
          width: 24,
          margin: const EdgeInsets.only(right: 7),
          decoration: BoxDecoration(
            color: AppColors.divider,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: Text('$index',
                textAlign: TextAlign.left,
                style: const TextStyle(fontSize: 15, color: AppColors.black)),
          ),
        ),
        // [수정] Expanded를 추가하여 흰색 박스가 남은 공간을 모두 차지하도록 함
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(16), // 패딩 값 조정
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  // 양쪽 끝으로 정렬
                  children: [
                    // [수정] '제품명' 텍스트를 고정된 텍스트로 변경
                    const Text('제품명',
                        style: TextStyle(fontSize: 20, color: AppColors.black)),
                    // [수정] 상품 이름이 너무 길 경우를 대비해 Flexible로 감싸기
                    Flexible(
                      child: Text(
                        item.product.name,
                        textAlign: TextAlign.right, // 오른쪽 정렬
                        overflow: TextOverflow.ellipsis, // 글자가 넘치면 ... 처리
                        style: const TextStyle(
                            fontSize: 20, color: AppColors.black),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('1g 당 가격',
                        style: TextStyle(fontSize: 15, color: AppColors.black)),
                    RichText(
                        text: TextSpan(children: [
                      TextSpan(
                        text: '${formatter.format(item.product.unitPrice)} 원',
                        // formatter 적용
                        style: const TextStyle(
                            fontSize: 20, color: AppColors.black),
                      ),
                      const TextSpan(
                          text: ' /1g',
                          style:
                              TextStyle(fontSize: 10, color: AppColors.black))
                    ])),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('무게',
                        style: TextStyle(fontSize: 20, color: AppColors.black)),
                    Text('x ${item.weight.toStringAsFixed(0)} g',
                        style: const TextStyle(fontSize: 20)),
                  ],
                ),
                const Divider(height: 16, thickness: 1),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('가격',
                        style: TextStyle(fontSize: 20, color: AppColors.black)),
                    Text('${formatter.format(item.price)} 원',
                        style: const TextStyle(
                            fontSize: 20,
                            color: AppColors.black,
                            fontWeight: FontWeight.bold)), // 가격에 bold체 적용
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 영수증 하단 (총액, 버튼) 위젯
  Widget _buildReceiptFooter() {
    final formatter = NumberFormat('#,###');
    return Column(
      children: [
        const SizedBox(height: 16),
        // [수정 1] IntrinsicHeight 위젯으로 Row를 감싸줍니다.
        IntrinsicHeight(
          child: Row(
            // [수정 2] 자식들이 세로 방향으로 꽉 차도록 stretch 속성 추가
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // '다른 병에도 리필하기' 버튼
              Expanded(
                child: ElevatedButton(
                  onPressed: () => controller.developFeature(),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: const Color(0xFF6A6A6A),
                    // shape을 추가하여 모서리를 둥글게 만듭니다.
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.start, // 세로 중앙 정렬
                    children: [
                      Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 39,
                      ),
                      SizedBox(height: 4), // 아이콘과 텍스트 사이 간격
                      Expanded(
                        child: Center(
                          child: Text(
                            '다른 병에도\n리필하기',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // '완료' 버튼
              Expanded(
                child: ElevatedButton(
                  onPressed: () => controller.completePurchase(),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: const Color(0xFF6A91DB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center, // 세로 중앙 정렬
                    children: [
                      Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 39,
                      ),
                      SizedBox(height: 4),
                      Expanded(
                        child: Center(
                          child: Text(
                            '완료',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  @override
  Widget? bottomNavigationBar(BuildContext context) {
    return null;
  }
}
