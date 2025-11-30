import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import {
  Container,
  Paper,
  TextField,
  Button,
  Typography,
  Box,
  Alert
} from '@mui/material';
import { authService } from '../services/authService';
import { storage } from '../utils/storage';

export const LoginPage: React.FC = () => {
  const navigate = useNavigate();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setLoading(true);

    try {
      console.log('Attempting login with:', { email });
      const response = await authService.login({ email, password });
      console.log('Login response:', response);
      
      if (response && response.token) {
        storage.setToken(response.token);
        storage.setUser(response.user);
        console.log('Token and user saved, navigating to /users');
        navigate('/users');
      } else {
        setError('Invalid response from server');
      }
    } catch (err: any) {
      console.error('Login error:', err);
      console.error('Error response:', err.response);
      console.error('Error message:', err.message);
      
      let errorMessage = 'Login failed';
      
      if (err.response) {
        // Server responded with error
        errorMessage = err.response.data?.error || 
                      err.response.data?.message || 
                      `Server error: ${err.response.status}`;
      } else if (err.request) {
        // Request was made but no response
        errorMessage = 'Cannot connect to server. Please check your internet connection.';
      } else {
        // Something else happened
        errorMessage = err.message || 'An unexpected error occurred';
      }
      
      setError(errorMessage);
    } finally {
      setLoading(false);
    }
  };

  return (
    <Container maxWidth="sm">
      <Box sx={{ minHeight: '100vh', display: 'flex', alignItems: 'center' }}>
        <Paper elevation={3} sx={{ p: 4, width: '100%' }}>
          <Typography variant="h4" component="h1" gutterBottom align="center">
            FutureX Login
          </Typography>
          
          {error && (
            <Alert severity="error" sx={{ mb: 2 }} onClose={() => setError('')}>
              <Typography variant="body2" component="div">
                <strong>Error:</strong> {error}
              </Typography>
              <Typography variant="caption" color="text.secondary" sx={{ mt: 1, display: 'block' }}>
                Check browser console (F12) for more details
              </Typography>
            </Alert>
          )}

          <form onSubmit={handleSubmit}>
            <TextField
              fullWidth
              label="Email"
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              margin="normal"
              required
              autoComplete="email"
            />
            <TextField
              fullWidth
              label="Password"
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              margin="normal"
              required
              autoComplete="current-password"
            />
            <Button
              type="submit"
              fullWidth
              variant="contained"
              sx={{ mt: 3, mb: 2 }}
              disabled={loading}
            >
              {loading ? 'Logging in...' : 'Login'}
            </Button>
          </form>
        </Paper>
      </Box>
    </Container>
  );
};

