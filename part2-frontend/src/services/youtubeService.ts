// YouTube API service to fetch video thumbnail
const YOUTUBE_API_KEY = import.meta.env.VITE_YOUTUBE_API_KEY || '';
const YOUTUBE_API_URL = 'https://www.googleapis.com/youtube/v3/videos';

export interface YouTubeVideoInfo {
  thumbnail: string;
  title: string;
  description: string;
  duration: number;
}

export const youtubeService = {
  getVideoThumbnail: (videoId: string): string => {
    return `https://img.youtube.com/vi/${videoId}/maxresdefault.jpg`;
  },

  getVideoInfo: async (videoId: string): Promise<YouTubeVideoInfo | null> => {
    // Try YouTube API first if key is available
    if (YOUTUBE_API_KEY) {
      try {
        const response = await fetch(
          `${YOUTUBE_API_URL}?id=${videoId}&key=${YOUTUBE_API_KEY}&part=snippet,contentDetails`
        );
        const data = await response.json();

        if (data.items && data.items.length > 0) {
          const item = data.items[0];
          const duration = parseDuration(item.contentDetails.duration);
          
          return {
            thumbnail: item.snippet.thumbnails.maxres?.url || youtubeService.getVideoThumbnail(videoId),
            title: item.snippet.title || '',
            description: item.snippet.description || '',
            duration
          };
        }
      } catch (error) {
        console.error('Error fetching YouTube API info:', error);
      }
    }

    // Fallback: Try oEmbed API (no key required, but limited info)
    try {
      const oEmbedUrl = `https://www.youtube.com/oembed?url=https://www.youtube.com/watch?v=${videoId}&format=json`;
      const response = await fetch(oEmbedUrl);
      
      if (response.ok) {
        const data = await response.json();
        return {
          thumbnail: youtubeService.getVideoThumbnail(videoId),
          title: data.title || '',
          description: '', // oEmbed doesn't provide description
          duration: 0 // oEmbed doesn't provide duration
        };
      }
    } catch (error) {
      console.error('Error fetching YouTube oEmbed info:', error);
    }

    // Final fallback: thumbnail only
    return {
      thumbnail: youtubeService.getVideoThumbnail(videoId),
      title: '',
      description: '',
      duration: 0
    };
  }
};

// Helper to parse ISO 8601 duration (PT1H2M10S) to seconds
function parseDuration(duration: string): number {
  const match = duration.match(/PT(\d+H)?(\d+M)?(\d+S)?/);
  if (!match) return 0;

  const hours = (match[1] || '').replace('H', '') || '0';
  const minutes = (match[2] || '').replace('M', '') || '0';
  const seconds = (match[3] || '').replace('S', '') || '0';

  return parseInt(hours) * 3600 + parseInt(minutes) * 60 + parseInt(seconds);
}

