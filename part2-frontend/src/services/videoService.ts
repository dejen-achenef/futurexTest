import api from '../utils/api';

export interface Video {
  id: number;
  title: string;
  description?: string;
  youtubeVideoId: string;
  category: string;
  duration?: number;
  userId: number;
  user?: {
    id: number;
    name: string;
    email: string;
    avatar?: string;
  };
  created_at?: string;
}

export interface CreateVideoData {
  title: string;
  description?: string;
  youtubeVideoId: string;
  category: string;
  duration?: number;
}

export interface VideosResponse {
  videos: Video[];
  pagination: {
    total: number;
    page: number;
    limit: number;
    totalPages: number;
  };
}

export const videoService = {
  getVideos: async (params?: { search?: string; category?: string; page?: number; limit?: number }): Promise<VideosResponse> => {
    const response = await api.get<VideosResponse>('/videos', { params });
    return response.data;
  },

  createVideo: async (data: CreateVideoData): Promise<{ message: string; video: Video }> => {
    const response = await api.post<{ message: string; video: Video }>('/videos', data);
    return response.data;
  },

  getVideoById: async (id: number): Promise<Video> => {
    const response = await api.get<Video>(`/videos/${id}`);
    return response.data;
  },

  deleteVideo: async (id: number): Promise<{ message: string }> => {
    const response = await api.delete<{ message: string }>(`/videos/${id}`);
    return response.data;
  }
};

