// Secure storage utilities
export interface StoredUser {
  id: number;
  name: string;
  email: string;
  avatar?: string;
}

export const storage = {
  setToken: (token: string) => {
    localStorage.setItem('token', token);
  },
  
  getToken: (): string | null => {
    return localStorage.getItem('token');
  },
  
  setUser: (user: StoredUser) => {
    localStorage.setItem('user', JSON.stringify(user));
  },
  
  getUser: (): StoredUser | null => {
    const userStr = localStorage.getItem('user');
    if (!userStr) return null;
    try {
      return JSON.parse(userStr);
    } catch {
      return null;
    }
  },
  
  getCurrentUserId: (): number | null => {
    const user = storage.getUser();
    return user?.id || null;
  },
  
  removeToken: () => {
    localStorage.removeItem('token');
    localStorage.removeItem('user');
  },
  
  isAuthenticated: (): boolean => {
    return !!localStorage.getItem('token');
  }
};

