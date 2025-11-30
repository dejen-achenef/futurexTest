import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../models/user.dart';
import '../models/video.dart';
import '../models/auth_response.dart';
import 'storage_service.dart';

class ApiService {
  final StorageService _storageService;
  late final Dio _dio;
  
  // Auto-detect platform and set appropriate base URL
  static String get baseUrl {
    if (kIsWeb) {
      // Web uses localhost
      return 'http://localhost:3000/api';
    }
    
    // For Android emulator, use 10.0.2.2 to access host machine's localhost
    // For iOS simulator, use localhost
    // For physical devices, you'll need to use your computer's IP address
    // 
    // TODO: Update this based on your setup:
    // - Android Emulator: 'http://10.0.2.2:3000/api'
    // - iOS Simulator: 'http://localhost:3000/api'
    // - Physical Device: 'http://YOUR_COMPUTER_IP:3000/api' (e.g., 'http://192.168.1.100:3000/api')
    
    // Default: Try Android emulator first, then fallback to localhost
    // You can change this to match your setup
    return 'http://10.0.2.2:3000/api'; // Android emulator
    // return 'http://localhost:3000/api'; // iOS simulator or if Android emulator doesn't work
  }

  ApiService(this._storageService) {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
    
    // Add logging interceptor for debugging
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
      logPrint: (object) {
        print('[API] $object');
      },
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storageService.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          // Token expired or invalid
          await _storageService.deleteToken();
        }
        return handler.next(error);
      },
    ));
  }

  Future<bool> checkConnectivity() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      final hasConnection = connectivityResult != ConnectivityResult.none;
      print('[API] Connectivity check: $hasConnection ($connectivityResult)');
      return hasConnection;
    } catch (e) {
      print('[API] Connectivity check error: $e');
      // Assume connected if check fails
      return true;
    }
  }
  
  // Test if backend is reachable
  Future<bool> testConnection() async {
    try {
      print('[API] Testing connection to: $baseUrl');
      final response = await _dio.get('/health', options: Options(
        receiveTimeout: const Duration(seconds: 5),
      ));
      print('[API] Connection test successful: ${response.data}');
      return true;
    } catch (e) {
      print('[API] Connection test failed: $e');
      return false;
    }
  }

  Future<AuthResponse> login(String email, String password) async {
    print('[API] Attempting login for: $email');
    print('[API] Base URL: $baseUrl');
    
    // First test connection
    final canConnect = await testConnection();
    if (!canConnect) {
      throw Exception('Cannot reach server at $baseUrl. Make sure:\n1. Backend is running\n2. Correct IP address for your device');
    }
    
    if (!await checkConnectivity()) {
      throw Exception('No internet connection detected');
    }

    try {
      print('[API] Sending login request...');
      final response = await _dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      print('[API] Login response received: ${response.statusCode}');
      print('[API] Login response data: ${response.data}');
      
      if (response.data == null) {
        throw Exception('Server returned empty response');
      }
      
      final authResponse = AuthResponse.fromJson(response.data as Map<String, dynamic>);
      print('[API] Login successful, saving token...');
      await _storageService.saveToken(authResponse.token);
      await _storageService.saveUser(jsonEncode(authResponse.user.toJson()));

      return authResponse;
    } on DioException catch (e) {
      print('[API] Login DioException: ${e.type}');
      print('[API] Login error message: ${e.message}');
      print('[API] Login error response: ${e.response?.data}');
      print('[API] Login status code: ${e.response?.statusCode}');
      
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Connection timeout. Server may be slow or unreachable.\n\nBase URL: $baseUrl');
      }
      if (e.type == DioExceptionType.connectionError) {
        throw Exception('Cannot connect to server at $baseUrl.\n\nPlease check:\n1. Backend is running (npm run dev)\n2. Correct IP for your device\n3. Firewall settings');
      }
      
      // Extract error message from response
      String errorMessage = 'Login failed';
      if (e.response?.data != null) {
        if (e.response!.data is Map) {
          errorMessage = e.response!.data['error'] ?? 
                        e.response!.data['message'] ?? 
                        'Login failed';
        } else {
          errorMessage = e.response!.data.toString();
        }
      } else {
        errorMessage = e.message ?? 'Login failed - ${e.type}';
      }
      
      throw Exception(errorMessage);
    } catch (e) {
      print('[API] Login general exception: ${e.toString()}');
      print('[API] Exception type: ${e.runtimeType}');
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  Future<AuthResponse> register(String name, String email, String password) async {
    print('[API] Attempting registration for: $email');
    print('[API] Base URL: $baseUrl');
    
    // First test connection
    final canConnect = await testConnection();
    if (!canConnect) {
      throw Exception('Cannot reach server at $baseUrl. Make sure:\n1. Backend is running\n2. Correct IP address for your device');
    }
    
    if (!await checkConnectivity()) {
      throw Exception('No internet connection detected');
    }

    try {
      print('[API] Sending registration request...');
      final response = await _dio.post(
        '/auth/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
        },
      );

      print('[API] Register response received: ${response.statusCode}');
      print('[API] Register response data: ${response.data}');
      
      if (response.data == null) {
        throw Exception('Server returned empty response');
      }
      
      final authResponse = AuthResponse.fromJson(response.data as Map<String, dynamic>);
      print('[API] Registration successful, saving token...');
      await _storageService.saveToken(authResponse.token);
      await _storageService.saveUser(jsonEncode(authResponse.user.toJson()));

      return authResponse;
    } on DioException catch (e) {
      print('[API] Register DioException: ${e.type}');
      print('[API] Register error message: ${e.message}');
      print('[API] Register error response: ${e.response?.data}');
      print('[API] Register status code: ${e.response?.statusCode}');
      
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Connection timeout. Server may be slow or unreachable.\n\nBase URL: $baseUrl');
      }
      if (e.type == DioExceptionType.connectionError) {
        throw Exception('Cannot connect to server at $baseUrl.\n\nPlease check:\n1. Backend is running (npm run dev)\n2. Correct IP for your device\n3. Firewall settings');
      }
      
      // Extract error message from response
      String errorMessage = 'Registration failed';
      if (e.response?.data != null) {
        if (e.response!.data is Map) {
          errorMessage = e.response!.data['error'] ?? 
                        e.response!.data['message'] ?? 
                        'Registration failed';
        } else {
          errorMessage = e.response!.data.toString();
        }
      } else {
        errorMessage = e.message ?? 'Registration failed - ${e.type}';
      }
      
      throw Exception(errorMessage);
    } catch (e) {
      print('[API] Register general exception: ${e.toString()}');
      print('[API] Exception type: ${e.runtimeType}');
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  Future<List<Video>> getVideos({String? search, String? category}) async {
    if (!await checkConnectivity()) {
      throw Exception('No internet connection');
    }

    try {
      final queryParams = <String, dynamic>{};
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (category != null && category.isNotEmpty) {
        queryParams['category'] = category;
      }

      final response = await _dio.get(
        '/videos',
        queryParameters: queryParams,
      );

      if (response.data is List) {
        return (response.data as List)
            .map((json) => Video.fromJson(json as Map<String, dynamic>))
            .toList();
      } else if (response.data['videos'] != null) {
        return (response.data['videos'] as List)
            .map((json) => Video.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Connection timeout. Please check your internet.');
      }
      throw Exception(e.response?.data['error'] ?? 'Failed to fetch videos');
    } catch (e) {
      throw Exception('Failed to fetch videos: ${e.toString()}');
    }
  }

  Future<Video> getVideoById(int id) async {
    if (!await checkConnectivity()) {
      throw Exception('No internet connection');
    }

    try {
      final response = await _dio.get('/videos/$id');
      return Video.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Connection timeout. Please check your internet.');
      }
      throw Exception(e.response?.data['error'] ?? 'Failed to fetch video');
    } catch (e) {
      throw Exception('Failed to fetch video: ${e.toString()}');
    }
  }

  Future<User> getUserById(int id) async {
    if (!await checkConnectivity()) {
      throw Exception('No internet connection');
    }

    try {
      final response = await _dio.get('/users/$id');
      return User.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Connection timeout. Please check your internet.');
      }
      throw Exception(e.response?.data['error'] ?? 'Failed to fetch user');
    } catch (e) {
      throw Exception('Failed to fetch user: ${e.toString()}');
    }
  }

  Future<User> updateUser(int id, {String? name, String? email}) async {
    if (!await checkConnectivity()) {
      throw Exception('No internet connection');
    }

    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (email != null) data['email'] = email;

      final response = await _dio.put(
        '/users/$id',
        data: data,
      );

      final updatedUser = User.fromJson(response.data as Map<String, dynamic>);
      await _storageService.saveUser(jsonEncode(updatedUser.toJson()));

      return updatedUser;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Connection timeout. Please check your internet.');
      }
      throw Exception(e.response?.data['error'] ?? 'Failed to update user');
    } catch (e) {
      throw Exception('Failed to update user: ${e.toString()}');
    }
  }

  Future<void> deleteVideo(int id) async {
    if (!await checkConnectivity()) {
      throw Exception('No internet connection');
    }

    try {
      await _dio.delete('/videos/$id');
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Connection timeout. Please check your internet.');
      }
      throw Exception(e.response?.data['error'] ?? 'Failed to delete video');
    } catch (e) {
      throw Exception('Failed to delete video: ${e.toString()}');
    }
  }

  Future<void> hideVideo(int id) async {
    if (!await checkConnectivity()) {
      throw Exception('No internet connection');
    }

    try {
      await _dio.post('/videos/$id/hide');
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Connection timeout. Please check your internet.');
      }
      throw Exception(e.response?.data['error'] ?? 'Failed to hide video');
    } catch (e) {
      throw Exception('Failed to hide video: ${e.toString()}');
    }
  }

  Future<void> unhideVideo(int id) async {
    if (!await checkConnectivity()) {
      throw Exception('No internet connection');
    }

    try {
      await _dio.delete('/videos/$id/hide');
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Connection timeout. Please check your internet.');
      }
      throw Exception(e.response?.data['error'] ?? 'Failed to unhide video');
    } catch (e) {
      throw Exception('Failed to unhide video: ${e.toString()}');
    }
  }

  Future<void> logout() async {
    await _storageService.clearAll();
  }
}

