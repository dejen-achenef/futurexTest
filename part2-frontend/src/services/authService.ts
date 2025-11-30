import api from '../utils/api';

export interface RegisterData {
  name: string;
  email: string;
  password: string;
}

export interface LoginData {
  email: string;
  password: string;
}

export interface AuthResponse {
  message: string;
  user: {
    id: number;
    name: string;
    email: string;
    avatar?: string;
  };
  token: string;
}

export const authService = {
  register: async (data: RegisterData): Promise<AuthResponse> => {
    console.log('[AuthService] Registering user:', data.email);
    try {
      const response = await api.post<AuthResponse>('/auth/register', data);
      console.log('[AuthService] Register response:', response.data);
      return response.data;
    } catch (error: any) {
      console.error('[AuthService] Register error:', error);
      throw error;
    }
  },

  login: async (data: LoginData): Promise<AuthResponse> => {
    console.log('[AuthService] Logging in user:', data.email);
    console.log('[AuthService] API base URL:', api.defaults.baseURL);
    try {
      const response = await api.post<AuthResponse>('/auth/login', data);
      console.log('[AuthService] Login response:', response.data);
      return response.data;
    } catch (error: any) {
      console.error('[AuthService] Login error:', error);
      console.error('[AuthService] Error response:', error.response);
      throw error;
    }
  }
};

