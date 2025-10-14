import '../responses/product_response.dart';

class CartItem {
  final Product product;
  final int weight;
  final int price;

  CartItem({required this.product, required this.weight, required this.price});
}