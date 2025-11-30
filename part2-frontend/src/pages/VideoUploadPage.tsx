import { useState } from 'react';
import {
  Container,
  Paper,
  TextField,
  Button,
  Typography,
  Box,
  Alert,
  MenuItem,
  Grid,
  Card,
  CardMedia,
  CircularProgress
} from '@mui/material';
import { videoService, CreateVideoData } from '../services/videoService';
import { youtubeService } from '../services/youtubeService';

const categories = [
  'Education',
  'Entertainment',
  'Technology',
  'Sports',
  'Music',
  'Gaming',
  'Other'
];

export const VideoUploadPage: React.FC = () => {
  const [formData, setFormData] = useState<CreateVideoData>({
    title: '',
    description: '',
    youtubeVideoId: '',
    category: '',
    duration: undefined
  });
  const [thumbnail, setThumbnail] = useState<string>('');
  const [loading, setLoading] = useState(false);
  const [fetchingInfo, setFetchingInfo] = useState(false);
  const [success, setSuccess] = useState('');
  const [error, setError] = useState('');

  const extractVideoId = (urlOrId: string): string => {
    // Handle full YouTube URL
    const urlPattern = /(?:youtube\.com\/(?:[^\/]+\/.+\/|(?:v|e(?:mbed)?)\/|.*[?&]v=)|youtu\.be\/)([^"&?\/\s]{11})/;
    const match = urlOrId.match(urlPattern);
    return match ? match[1] : urlOrId;
  };

  const handleYoutubeIdChange = async (value: string) => {
    const videoId = extractVideoId(value);
    setFormData({ ...formData, youtubeVideoId: videoId });
    
    if (videoId) {
      setFetchingInfo(true);
      setError('');
      try {
        console.log('[VideoUpload] Fetching YouTube info for:', videoId);
        const info = await youtubeService.getVideoInfo(videoId);
        console.log('[VideoUpload] YouTube info received:', info);
        
        if (info) {
          setThumbnail(info.thumbnail);
          
          // Always update title if fetched (even if form already has a title, allow override)
          if (info.title) {
            setFormData(prev => ({ ...prev, title: info.title }));
            console.log('[VideoUpload] Title auto-filled:', info.title);
          }
          
          // Always update description if fetched
          if (info.description) {
            setFormData(prev => ({ ...prev, description: info.description }));
            console.log('[VideoUpload] Description auto-filled');
          }
          
          // Only update duration if not already set
          if (info.duration && info.duration > 0 && !formData.duration) {
            setFormData(prev => ({ ...prev, duration: info.duration }));
            console.log('[VideoUpload] Duration auto-filled:', info.duration);
          }
        } else {
          // Fallback to thumbnail only
          setThumbnail(youtubeService.getVideoThumbnail(videoId));
        }
      } catch (err) {
        console.error('[VideoUpload] Error fetching YouTube info:', err);
        setThumbnail(youtubeService.getVideoThumbnail(videoId));
        setError('Could not fetch video details, but you can still upload manually');
      } finally {
        setFetchingInfo(false);
      }
    } else {
      setThumbnail('');
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setSuccess('');
    setLoading(true);

    try {
      await videoService.createVideo(formData);
      setSuccess('Video uploaded successfully!');
      setFormData({
        title: '',
        description: '',
        youtubeVideoId: '',
        category: '',
        duration: undefined
      });
      setThumbnail('');
    } catch (err: any) {
      setError(err.response?.data?.error || 'Failed to upload video');
    } finally {
      setLoading(false);
    }
  };

  return (
    <Container maxWidth="md" sx={{ mt: 4, mb: 4 }}>
      <Typography variant="h4" component="h1" gutterBottom>
        Upload Video
      </Typography>

      <Paper elevation={3} sx={{ p: 4 }}>
        {success && (
          <Alert severity="success" sx={{ mb: 2 }}>
            {success}
          </Alert>
        )}

        {error && (
          <Alert severity="error" sx={{ mb: 2 }}>
            {error}
          </Alert>
        )}

        <form onSubmit={handleSubmit}>
          <Grid container spacing={3}>
            <Grid item xs={12} md={8}>
              <TextField
                fullWidth
                label="YouTube Video ID or URL"
                value={formData.youtubeVideoId}
                onChange={(e) => handleYoutubeIdChange(e.target.value)}
                margin="normal"
                required
                helperText="Enter YouTube video ID or full URL"
              />

              {fetchingInfo && (
                <Box display="flex" alignItems="center" gap={1} mt={1}>
                  <CircularProgress size={20} />
                  <Typography variant="body2">Fetching video title and thumbnail from YouTube...</Typography>
                </Box>
              )}
              
              {thumbnail && !fetchingInfo && formData.title && (
                <Alert severity="success" sx={{ mt: 1 }}>
                  ✓ Video title {formData.description ? 'and description' : ''} fetched from YouTube
                </Alert>
              )}

              <TextField
                fullWidth
                label="Title"
                value={formData.title}
                onChange={(e) => setFormData({ ...formData, title: e.target.value })}
                margin="normal"
                required
              />

              <TextField
                fullWidth
                label="Description"
                value={formData.description}
                onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                margin="normal"
                multiline
                rows={4}
              />

              <TextField
                fullWidth
                select
                label="Category"
                value={formData.category}
                onChange={(e) => setFormData({ ...formData, category: e.target.value })}
                margin="normal"
                required
              >
                {categories.map((cat) => (
                  <MenuItem key={cat} value={cat}>
                    {cat}
                  </MenuItem>
                ))}
              </TextField>

              <TextField
                fullWidth
                label="Duration (seconds)"
                type="number"
                value={formData.duration || ''}
                onChange={(e) => setFormData({ ...formData, duration: parseInt(e.target.value) || undefined })}
                margin="normal"
              />

              <Button
                type="submit"
                variant="contained"
                fullWidth
                sx={{ mt: 3 }}
                disabled={loading}
              >
                {loading ? 'Uploading...' : 'Upload Video'}
              </Button>
            </Grid>

            <Grid item xs={12} md={4}>
              {thumbnail && (
                <Card>
                  <CardMedia
                    component="img"
                    height="200"
                    image={thumbnail}
                    alt="Video thumbnail"
                  />
                  <Box p={2}>
                    <Typography variant="body2" color="text.secondary">
                      Video Preview
                    </Typography>
                  </Box>
                </Card>
              )}
            </Grid>
          </Grid>
        </form>
      </Paper>
    </Container>
  );
};

