import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import 'services_provider.dart';

// User State
class UserState {
  final User? user;
  final bool isLoading;
  final String? error;

  const UserState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  UserState copyWith({
    User? user,
    bool? isLoading,
    String? error,
  }) {
    return UserState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// User Notifier
class UserNotifier extends StateNotifier<UserState> {
  final ApiService _apiService;

  UserNotifier(this._apiService) : super(const UserState());

  Future<void> loadUser(int id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _apiService.getUserById(id);
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> updateUser(int id, {String? name, String? email}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _apiService.updateUser(id, name: name, email: email);
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }
}

// User Provider
final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return UserNotifier(apiService);
});

// User by ID Provider (for loading specific users)
final userByIdProvider = FutureProvider.family<User, int>((ref, id) async {
  final apiService = ref.watch(apiServiceProvider);
  return await apiService.getUserById(id);
});

