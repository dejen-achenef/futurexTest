import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import 'services_provider.dart';

// Auth State
class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  bool get isAuthenticated => user != null;
  bool get isUnauthenticated => user == null && !isLoading && error == null;

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthState &&
        other.user?.id == user?.id &&
        other.isLoading == isLoading &&
        other.error == error;
  }

  @override
  int get hashCode => Object.hash(user?.id, isLoading, error);
}

// Auth Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final ApiService _apiService;
  final StorageService _storageService;

  AuthNotifier(this._apiService, this._storageService) : super(const AuthState()) {
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final token = await _storageService.getToken();
      final userJson = await _storageService.getUser();

      if (token != null && userJson != null) {
        final userMap = jsonDecode(userJson) as Map<String, dynamic>;
        final user = User.fromJson(userMap);
        state = state.copyWith(user: user, isLoading: false);
      } else {
        state = state.copyWith(user: null, isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(user: null, isLoading: false);
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final authResponse = await _apiService.login(email, password);
      state = state.copyWith(
        user: authResponse.user, 
        isLoading: false,
        clearError: true,
      );
    } catch (e) {
      // Extract clean error message
      String errorMessage = e.toString().replaceAll('Exception: ', '');
      
      // Clean up common error message patterns
      if (errorMessage.contains('401') || 
          errorMessage.contains('Unauthorized') ||
          errorMessage.toLowerCase().contains('invalid') && 
          errorMessage.toLowerCase().contains('password')) {
        errorMessage = 'Invalid email or password. Please check your credentials.';
      } else if (errorMessage.contains('404') || errorMessage.contains('Not found')) {
        errorMessage = 'User not found. Please check your email address.';
      } else if (errorMessage.contains('Connection timeout') || 
                 errorMessage.contains('Cannot connect')) {
        errorMessage = 'Connection failed. Please check your internet connection.';
      } else if (errorMessage.contains('No internet')) {
        errorMessage = 'No internet connection detected.';
      }
      
      state = state.copyWith(
        isLoading: false,
        error: errorMessage,
      );
    }
  }

  Future<void> register(String name, String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final authResponse = await _apiService.register(name, email, password);
      state = state.copyWith(
        user: authResponse.user, 
        isLoading: false,
        clearError: true,
      );
    } catch (e) {
      // Extract clean error message
      String errorMessage = e.toString().replaceAll('Exception: ', '');
      
      // Clean up common error message patterns
      if (errorMessage.contains('409') || 
          errorMessage.contains('already exists') ||
          errorMessage.toLowerCase().contains('email') && 
          errorMessage.toLowerCase().contains('already')) {
        errorMessage = 'This email is already registered. Please use a different email or try logging in.';
      } else if (errorMessage.contains('400') || errorMessage.contains('Bad Request')) {
        if (errorMessage.toLowerCase().contains('password')) {
          errorMessage = 'Password does not meet requirements. Please use a stronger password.';
        } else if (errorMessage.toLowerCase().contains('email')) {
          errorMessage = 'Invalid email format. Please enter a valid email address.';
        } else {
          errorMessage = 'Invalid registration data. Please check all fields.';
        }
      } else if (errorMessage.contains('Connection timeout') || 
                 errorMessage.contains('Cannot connect')) {
        errorMessage = 'Connection failed. Please check your internet connection.';
      } else if (errorMessage.contains('No internet')) {
        errorMessage = 'No internet connection detected.';
      }
      
      state = state.copyWith(
        isLoading: false,
        error: errorMessage,
      );
    }
  }

  Future<void> logout() async {
    // Clear storage first (this should always work)
    try {
      await _apiService.logout();
    } catch (e) {
      // Even if logout fails, we should still clear local state
      // Log error but continue with logout
    }
    
    // Always clear user state regardless of API call result
    // This ensures the user is logged out even if the API call fails
    // Use clearUser flag to explicitly set user to null
    state = state.copyWith(
      clearUser: true,
      isLoading: false,
      clearError: true,
    );
  }
}

// Auth Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final storageService = ref.watch(storageServiceProvider);
  return AuthNotifier(apiService, storageService);
});

