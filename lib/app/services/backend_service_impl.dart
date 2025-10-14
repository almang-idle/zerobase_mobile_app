import 'package:dio/dio.dart';
import 'backend_service.dart';

// BackendService의 실제 구현부
class BackendServiceImpl extends BackendService {
  // Dio 인스턴스 생성 및 BaseURL 설정
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://zerobase-pos.vercel.app', // API Base URL [cite: 4]
  ));

  BackendServiceImpl() {
    // API 요청/응답을 로그로 확인하기 위해 LogInterceptor 추가
    _dio.interceptors.add(LogInterceptor(responseBody: true));
  }

  /// 1. 등록된 제품 정보 조회
  @override
  Future<Response> getProducts({String? type}) {
    // type 파라미터가 있으면 queryParameters에 추가
    final Map<String, dynamic> queryParameters = {};
    if (type != null) {
      queryParameters['type'] = type;
    }

    return _dio.get(
      '/api/products', // GET /api/products Endpoint [cite: 10]
      queryParameters: queryParameters,
    );
  }

  /// 2. 리필 상품 무게 데이터 전송
  @override
  Future<Response> sendScaleData({
    required String phoneSuffix,
    required String productId,
    required int weightGram,
  }) {
    final data = {
      'phone_suffix': phoneSuffix,   // 전화번호 뒷 4자리 [cite: 72]
      'product_id': productId,       // 제품 ID [cite: 73]
      'weight_gram': weightGram,     // 무게(그램) [cite: 75]
    };

    return _dio.post(
     '/api/ingest-scale', // POST /api/ingest-scale Endpoint [cite: 67]
      data: data,
    );
  }
}