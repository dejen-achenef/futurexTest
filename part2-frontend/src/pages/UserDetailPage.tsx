import { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import {
  Container,
  Paper,
  Typography,
  Box,
  Avatar,
  CircularProgress,
  Alert,
  Card,
  CardContent,
  Grid,
  Chip,
  Divider,
  IconButton,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogContentText,
  DialogActions,
  Button,
  Tooltip
} from '@mui/material';
import { ArrowBack, Email, VideoLibrary, Delete } from '@mui/icons-material';
import { userService, User } from '../services/userService';
import { videoService, Video } from '../services/videoService';
import { storage } from '../utils/storage';

export const UserDetailPage: React.FC = () => {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const [user, setUser] = useState<User | null>(null);
  const [videos, setVideos] = useState<Video[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string>('');
  const [deleteDialogOpen, setDeleteDialogOpen] = useState(false);
  const [videoToDelete, setVideoToDelete] = useState<Video | null>(null);
  const [deleting, setDeleting] = useState(false);
  
  const currentUserId = storage.getCurrentUserId();
  const isViewingOwnProfile = currentUserId && parseInt(id || '0') === currentUserId;

  useEffect(() => {
    const fetchUserData = async () => {
      if (!id) return;
      
      setLoading(true);
      setError('');
      
      try {
        console.log('[UserDetail] Fetching user:', id);
        const userData = await userService.getUserById(parseInt(id));
        console.log('[UserDetail] User data:', userData);
        
        // Extract user info and videos
        const userInfo: User = {
          id: userData.id,
          name: userData.name,
          email: userData.email,
          avatar: userData.avatar,
          created_at: userData.created_at,
          videoCount: userData.videos ? userData.videos.length : 0
        };
        setUser(userInfo);

        // Get videos from user data (if included) or fetch separately
        if (userData.videos && Array.isArray(userData.videos) && userData.videos.length > 0) {
          // Backend returned videos with user
          const formattedVideos = userData.videos.map((v: any) => ({
            id: v.id,
            title: v.title,
            description: v.description || '',
            youtubeVideoId: v.youtubeVideoId || v.youtube_video_id || '',
            category: v.category,
            duration: v.duration,
            userId: userData.id,
            created_at: v.created_at
          }));
          console.log('[UserDetail] User videos from backend:', formattedVideos);
          setVideos(formattedVideos);
        } else {
          // Fetch videos separately
          try {
            const videosResponse = await videoService.getVideos({});
            const userVideos = videosResponse.videos.filter(v => v.userId === parseInt(id));
            console.log('[UserDetail] User videos fetched separately:', userVideos);
            setVideos(userVideos);
          } catch (videoError) {
            console.error('[UserDetail] Error fetching videos:', videoError);
            setVideos([]);
          }
        }
      } catch (err: any) {
        console.error('[UserDetail] Error:', err);
        setError(err.response?.data?.error || err.message || 'Failed to load user data');
      } finally {
        setLoading(false);
      }
    };

    fetchUserData();
  }, [id]);

  const handleDeleteClick = (video: Video) => {
    setVideoToDelete(video);
    setDeleteDialogOpen(true);
  };

  const handleDeleteConfirm = async () => {
    if (!videoToDelete) return;
    
    setDeleting(true);
    try {
      console.log('[UserDetail] Deleting video:', videoToDelete.id);
      await videoService.deleteVideo(videoToDelete.id);
      console.log('[UserDetail] Video deleted successfully');
      
      // Remove video from list
      setVideos(prev => prev.filter(v => v.id !== videoToDelete.id));
      
      // Update user video count
      if (user) {
        setUser({ ...user, videoCount: (user.videoCount || 0) - 1 });
      }
      
      setDeleteDialogOpen(false);
      setVideoToDelete(null);
    } catch (err: any) {
      console.error('[UserDetail] Error deleting video:', err);
      setError(err.response?.data?.error || 'Failed to delete video');
    } finally {
      setDeleting(false);
    }
  };

  const handleDeleteCancel = () => {
    setDeleteDialogOpen(false);
    setVideoToDelete(null);
  };

  if (loading) {
    return (
      <Container maxWidth="lg" sx={{ mt: 4, mb: 4 }}>
        <Box display="flex" justifyContent="center" p={4}>
          <CircularProgress />
        </Box>
      </Container>
    );
  }

  if (error || !user) {
    return (
      <Container maxWidth="lg" sx={{ mt: 4, mb: 4 }}>
        <Alert severity="error">{error || 'User not found'}</Alert>
        <Box mt={2}>
          <IconButton onClick={() => navigate('/users')}>
            <ArrowBack /> Back to Users
          </IconButton>
        </Box>
      </Container>
    );
  }

  return (
    <Container maxWidth="lg" sx={{ mt: 4, mb: 4 }}>
      <Box sx={{ mb: 3, display: 'flex', alignItems: 'center', gap: 2 }}>
        <IconButton onClick={() => navigate('/users')} color="primary">
          <ArrowBack />
        </IconButton>
        <Typography variant="h4" component="h1">
          User Details
        </Typography>
      </Box>

      <Grid container spacing={3}>
        {/* User Info Card */}
        <Grid item xs={12} md={4}>
          <Paper elevation={3} sx={{ p: 3 }}>
            <Box sx={{ display: 'flex', flexDirection: 'column', alignItems: 'center', mb: 3 }}>
              <Avatar
                src={user.avatar ? `http://localhost:3000/uploads/avatars/${user.avatar}` : undefined}
                sx={{ width: 120, height: 120, bgcolor: 'primary.main', mb: 2 }}
              >
                {user.name.charAt(0).toUpperCase()}
              </Avatar>
              <Typography variant="h5" component="h2" gutterBottom>
                {user.name}
              </Typography>
              <Chip label={`#${user.id}`} size="small" variant="outlined" />
            </Box>

            <Divider sx={{ my: 2 }} />

            <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2 }}>
              <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                <Email color="action" />
                <Typography variant="body1">
                  <strong>Email:</strong> {user.email}
                </Typography>
              </Box>

              <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                <VideoLibrary color="action" />
                <Typography variant="body1">
                  <strong>Videos:</strong> {videos.length}
                </Typography>
              </Box>
            </Box>
          </Paper>
        </Grid>

        {/* Videos List */}
        <Grid item xs={12} md={8}>
          <Paper elevation={3} sx={{ p: 3 }}>
            <Typography variant="h5" component="h2" gutterBottom sx={{ mb: 3 }}>
              Videos ({videos.length})
            </Typography>

            {videos.length === 0 ? (
              <Alert severity="info">
                This user hasn't uploaded any videos yet.
              </Alert>
            ) : (
              <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2 }}>
                {videos.map((video) => (
                  <Card key={video.id} variant="outlined">
                    <CardContent>
                      <Box sx={{ display: 'flex', gap: 2 }}>
                        <Box sx={{ flexShrink: 0 }}>
                          <img
                            src={`https://img.youtube.com/vi/${video.youtubeVideoId}/mqdefault.jpg`}
                            alt={video.title}
                            style={{
                              width: 160,
                              height: 90,
                              objectFit: 'cover',
                              borderRadius: 4
                            }}
                          />
                        </Box>
                        <Box sx={{ flex: 1 }}>
                          <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', mb: 1 }}>
                            <Typography variant="h6" component="h3" sx={{ flex: 1 }}>
                              {video.title}
                            </Typography>
                            {/* Only show delete button if viewing own profile AND video belongs to current user */}
                            {isViewingOwnProfile && currentUserId && video.userId === currentUserId && (
                              <Tooltip title="Delete this video">
                                <IconButton
                                  color="error"
                                  size="small"
                                  onClick={() => handleDeleteClick(video)}
                                  sx={{ ml: 1 }}
                                >
                                  <Delete fontSize="small" />
                                </IconButton>
                              </Tooltip>
                            )}
                          </Box>
                          {video.description && video.description.trim() && (
                            <Typography 
                              variant="body2" 
                              color="text.secondary" 
                              sx={{ mb: 1, whiteSpace: 'pre-wrap' }}
                            >
                              {video.description.length > 200 
                                ? `${video.description.substring(0, 200)}...` 
                                : video.description}
                            </Typography>
                          )}
                          {(!video.description || !video.description.trim()) && (
                            <Typography variant="body2" color="text.disabled" sx={{ mb: 1, fontStyle: 'italic' }}>
                              No description available
                            </Typography>
                          )}
                          <Box sx={{ display: 'flex', gap: 1, flexWrap: 'wrap', mt: 1 }}>
                            <Chip
                              label={video.category}
                              size="small"
                              color="primary"
                              variant="outlined"
                            />
                            {video.duration && video.duration > 0 && (
                              <Chip
                                label={`${Math.floor(video.duration / 60)}:${(video.duration % 60).toString().padStart(2, '0')}`}
                                size="small"
                                variant="outlined"
                              />
                            )}
                            {video.youtubeVideoId && (
                              <Chip
                                label={`YouTube: ${video.youtubeVideoId}`}
                                size="small"
                                variant="outlined"
                                onClick={() => window.open(`https://www.youtube.com/watch?v=${video.youtubeVideoId}`, '_blank')}
                                sx={{ cursor: 'pointer' }}
                              />
                            )}
                          </Box>
                        </Box>
                      </Box>
                    </CardContent>
                  </Card>
                ))}
              </Box>
            )}
          </Paper>
        </Grid>
      </Grid>

      {/* Delete Confirmation Dialog */}
      <Dialog
        open={deleteDialogOpen}
        onClose={handleDeleteCancel}
        aria-labelledby="delete-dialog-title"
        aria-describedby="delete-dialog-description"
      >
        <DialogTitle id="delete-dialog-title">
          Delete Video?
        </DialogTitle>
        <DialogContent>
          <DialogContentText id="delete-dialog-description">
            Are you sure you want to delete "{videoToDelete?.title}"? This action cannot be undone.
          </DialogContentText>
        </DialogContent>
        <DialogActions>
          <Button onClick={handleDeleteCancel} disabled={deleting}>
            Cancel
          </Button>
          <Button 
            onClick={handleDeleteConfirm} 
            color="error" 
            variant="contained"
            disabled={deleting}
          >
            {deleting ? 'Deleting...' : 'Delete'}
          </Button>
        </DialogActions>
      </Dialog>
    </Container>
  );
};

