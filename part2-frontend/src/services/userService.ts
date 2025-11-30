import api from '../utils/api';

export interface User {
  id: number;
  name: string;
  email: string;
  avatar?: string;
  created_at?: string;
  videoCount?: number;
  videos?: any[]; // For user detail page
}

export interface UsersResponse {
  users: User[];
  pagination: {
    total: number;
    page: number;
    limit: number;
    totalPages: number;
  };
}

export const userService = {
  getUsers: async (params?: { search?: string; page?: number; limit?: number }): Promise<UsersResponse> => {
    const response = await api.get<UsersResponse>('/users', { params });
    return response.data;
  },

  getUserById: async (id: number): Promise<User> => {
    const response = await api.get<User>(`/users/${id}`);
    return response.data;
  }
};

