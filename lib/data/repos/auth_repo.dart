import 'package:dio/dio.dart';
import '../../util/api_end_points.dart';
import '../data_sources/dio/dio_client.dart';
import '../data_sources/exception/api_error_handler.dart';
import '../model/response/base/api_response.dart';

class AuthRepo {
  final DioClient dioClient = DioClient.instance;


  /// Register a new user
  Future<ApiResponse> register({
    required String username,
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      print('🚀 Registering user: $email with username: $username');
      
      Response response = await dioClient.post(
        ApiEndPoints.register,
        data: {
          "username": username,
          "email": email,
          "password": password,
          "firstName": firstName,
          "lastName": lastName,
        },
      );
      
      print('✅ Registration successful: ${response.statusCode}');
      print('📄 Response data: ${response.data}');
      
      return ApiResponse.withSuccess(response);
    } catch (e) {
      print('❌ Registration failed: $e');
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  /// Login user
  Future<ApiResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      print('🚀 Logging in user: $email');
      
      Response response = await dioClient.post(
        ApiEndPoints.login,
        data: {
          "email": email,
          "password": password,
        },
      );
      
      print('✅ Login successful: ${response.statusCode}');
      print('📄 Response data: ${response.data}');
      
      return ApiResponse.withSuccess(response);
    } catch (e) {
      print('❌ Login failed: $e');
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  /// Logout user
  Future<ApiResponse> logout() async {
    try {
      print('🚀 Logging out user');
      
      Response response = await dioClient.post(
        ApiEndPoints.logout,
      );
      
      print('✅ Logout successful: ${response.statusCode}');
      
      return ApiResponse.withSuccess(response);
    } catch (e) {
      print('❌ Logout failed: $e');
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  /// Send email verification OTP
  Future<ApiResponse> sendEmailVerificationOTP({
    required String email,
  }) async {
    try {
      print('🚀 Sending email verification OTP to: $email');
      
      Response response = await dioClient.post(
        ApiEndPoints.sendEmailVerificationOTP,
        data: {
          "email": email,
        },
      );
      
      print('✅ Email verification OTP sent: ${response.statusCode}');
      
      return ApiResponse.withSuccess(response);
    } catch (e) {
      print('❌ Send email verification OTP failed: $e');
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  /// Verify email with OTP
  Future<ApiResponse> verifyEmail({
    required String email,
    required String otp,
  }) async {
    try {
      print('🚀 Verifying email: $email with OTP');
      
      Response response = await dioClient.post(
        ApiEndPoints.verifyEmail,
        data: {
          "email": email,
          "otp": otp,
        },
      );
      
      print('✅ Email verification successful: ${response.statusCode}');
      
      return ApiResponse.withSuccess(response);
    } catch (e) {
      print('❌ Email verification failed: $e');
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  /// Send password reset OTP
  Future<ApiResponse> sendPasswordResetOTP({
    required String email,
  }) async {
    try {
      print('🚀 Sending password reset OTP to: $email');
      
      Response response = await dioClient.post(
        ApiEndPoints.forgotPassword,
        data: {
          "email": email,
        },
      );
      
      print('✅ Password reset OTP sent: ${response.statusCode}');
      
      return ApiResponse.withSuccess(response);
    } catch (e) {
      print('❌ Send password reset OTP failed: $e');
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  /// Reset password with OTP
  Future<ApiResponse> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      print('🚀 Resetting password for: $email');
      
      Response response = await dioClient.post(
        ApiEndPoints.resetPassword,
        data: {
          "email": email,
          "otp": otp,
          "newPassword": newPassword,
        },
      );
      
      print('✅ Password reset successful: ${response.statusCode}');
      
      return ApiResponse.withSuccess(response);
    } catch (e) {
      print('❌ Password reset failed: $e');
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  /// Get current user profile
  Future<ApiResponse> getUserProfile() async {
    try {
      print('🚀 Getting user profile...');
      
      Response response = await dioClient.get(
        ApiEndPoints.getUserProfile,
      );
      
      print('✅ User profile retrieved: ${response.statusCode}');
      print('📄 Response data: ${response.data}');
      
      return ApiResponse.withSuccess(response);
    } catch (e) {
      print('❌ Get user profile failed: $e');
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  /// Update user profile
  Future<ApiResponse> updateUserProfile({
    String? username,
    String? firstName,
    String? lastName,
  }) async {
    try {
      print('🚀 Updating user profile...');
      
      // Build request data with only provided fields
      Map<String, dynamic> requestData = {};
      if (username != null) requestData['username'] = username;
      if (firstName != null) requestData['firstName'] = firstName;
      if (lastName != null) requestData['lastName'] = lastName;
      
      Response response = await dioClient.put(
        ApiEndPoints.updateUserProfile,
        data: requestData,
      );
      
      print('✅ User profile updated: ${response.statusCode}');
      print('📄 Response data: ${response.data}');
      
      return ApiResponse.withSuccess(response);
    } catch (e) {
      print('❌ Update user profile failed: $e');
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  /// Change user password
  Future<ApiResponse> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      print('🚀 Changing user password...');
      
      Response response = await dioClient.put(
        ApiEndPoints.changePassword,
        data: {
          "currentPassword": currentPassword,
          "newPassword": newPassword,
        },
      );
      
      print('✅ Password changed successfully: ${response.statusCode}');
      print('📄 Response data: ${response.data}');
      
      return ApiResponse.withSuccess(response);
    } catch (e) {
      print('❌ Change password failed: $e');
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  /// Setup wallet PIN (first time setup)
  Future<ApiResponse> setupWalletPin({required String walletPin}) async {
    try {
      print('🚀 Setting up wallet PIN...');
      
      Response response = await dioClient.post(
        ApiEndPoints.setupWalletPin,
        data: {
          "walletPin": walletPin,
        },
      );
      
      print('✅ Wallet PIN setup successful: ${response.statusCode}');
      print('📄 Response data: ${response.data}');
      
      return ApiResponse.withSuccess(response);
    } catch (e) {
      print('❌ Wallet PIN setup failed: $e');
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  /// Change wallet PIN (update existing PIN)
  Future<ApiResponse> changeWalletPin({
    required String currentPin,
    required String newPin,
  }) async {
    try {
      print('🚀 Changing wallet PIN...');
      
      Response response = await dioClient.post(
        ApiEndPoints.changeWalletPin,
        data: {
          "currentPin": currentPin,
          "newPin": newPin,
        },
      );
      
      print('✅ Wallet PIN change successful: ${response.statusCode}');
      print('📄 Response data: ${response.data}');
      
      return ApiResponse.withSuccess(response);
    } catch (e) {
      print('❌ Wallet PIN change failed: $e');
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }
}
