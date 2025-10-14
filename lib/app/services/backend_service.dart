import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;

abstract class BackendService extends GetxService {
  Future<Response> getProducts({String? type});

  Future<Response> sendScaleData({
    required String phoneSuffix,
    required String productId,
    required int weightGram,
  });
}
