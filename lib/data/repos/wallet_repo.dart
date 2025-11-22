import 'package:dio/dio.dart';
import '../../util/api_end_points.dart';
import '../data_sources/dio/dio_client.dart';
import '../data_sources/exception/api_error_handler.dart';
import '../model/response/base/api_response.dart';

class WalletRepo {
  final DioClient dioClient = DioClient.instance;

  /// Create Wallet - Generate a new crypto wallet
  Future<ApiResponse> createWallet({
    String walletType = "personal",
    required String walletPin,
  }) async {
    try {
      print('🚀 Creating wallet with type: $walletType');
      
      Response response = await dioClient.post(
        ApiEndPoints.generate,
        data: {
          "walletType": walletType,
          "walletPin": walletPin,
        },
      );
      
      print('✅ Wallet creation successful: ${response.statusCode}');
      print('📄 Response data: ${response.data}');
      
      return ApiResponse.withSuccess(response);
    } catch (e) {
      print('❌ Wallet creation failed: $e');
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  /// Get User's Wallet List
  Future<ApiResponse> getWalletList() async {
    try {
      print('📋 Getting user wallet list...');
      
      Response response = await dioClient.get(
        ApiEndPoints.walletList,
      );
      
      print('✅ Wallet list retrieved successfully: ${response.statusCode}');
      print('📄 Response data: ${response.data}');
      
      return ApiResponse.withSuccess(response);
    } catch (e) {
      print('❌ Failed to get wallet list: $e');
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  /// Retrieve Wallet Data by Address
  Future<ApiResponse> retrieveWallet({
    required String address,
    required String walletPin,
  }) async {
    try {
      print('🔍 Retrieving wallet data for address: $address');
      
      Response response = await dioClient.post(
        ApiEndPoints.retrieveWallet(address),
        data: {
          "walletPin": walletPin,
        },
      );
      
      print('✅ Wallet data retrieved successfully: ${response.statusCode}');
      print('📄 Response data: ${response.data}');
      
      return ApiResponse.withSuccess(response);
    } catch (e) {
      print('❌ Failed to retrieve wallet data: $e');
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

}