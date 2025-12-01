import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

// Storage Service Provider
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService(const FlutterSecureStorage());
});

// API Service Provider
final apiServiceProvider = Provider<ApiService>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  return ApiService(storageService);
});

