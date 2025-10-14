// 개별 제품의 구조를 나타내는 클래스
class Product {
  final String id;
  final String name;
  final String type;
  final int unitPrice;
  final String category;
  final String imageUrl;
  final bool isFavorite;

  Product({
    required this.id,
    required this.name,
    required this.type,
    required this.unitPrice,
    required this.category,
    required this.imageUrl,
    required this.isFavorite,
  });

  // JSON(Map 형태)에서 Product 객체로 변환하는 로직
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      unitPrice: json['unit_price'], // JSON의 snake_case를 camelCase로 매핑
      category: json['category'],
      imageUrl: json['image_url'],
      isFavorite: json['is_favorite'],
    );
  }
}

// API 응답 전체의 구조를 나타내는 클래스
class ProductResponse {
  final bool ok;
  final int count;
  final List<Product> products;

  ProductResponse({
    required this.ok,
    required this.count,
    required this.products,
  });

  // JSON(Map 형태)에서 ProductResponse 객체로 변환하는 로직
  factory ProductResponse.fromJson(Map<String, dynamic> json) {
    // JSON의 'products' 리스트를 Product 객체의 리스트로 변환
    var productList = (json['products'] as List)
        .map((item) => Product.fromJson(item))
        .toList();

    return ProductResponse(
      ok: json['ok'],
      count: json['count'],
      products: productList,
    );
  }
}