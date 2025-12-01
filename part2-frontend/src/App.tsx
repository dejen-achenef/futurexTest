import { BrowserRouter, Routes, Route, Navigate, Link, useLocation } from 'react-router-dom';
import { ThemeProvider, createTheme } from '@mui/material/styles';
import CssBaseline from '@mui/material/CssBaseline';
import { AppBar, Toolbar, Typography, Button, Box } from '@mui/material';
import { storage } from './utils/storage';
import { ProtectedRoute } from './components/ProtectedRoute';
import { LoginPage } from './pages/LoginPage';
import { UserListPage } from './pages/UserListPage';
import { UserDetailPage } from './pages/UserDetailPage';
import { VideoUploadPage } from './pages/VideoUploadPage';

const theme = createTheme({
  palette: {
    primary: {
      main: '#667eea',
    },
    secondary: {
      main: '#764ba2',
    },
    background: {
      default: '#f5f7fa',
    },
  },
  typography: {
    fontFamily: '"Inter", "Roboto", "Helvetica", "Arial", sans-serif',
    h4: {
      fontWeight: 700,
    },
    h5: {
      fontWeight: 600,
    },
    h6: {
      fontWeight: 600,
    },
  },
  shape: {
    borderRadius: 12,
  },
  components: {
    MuiButton: {
      styleOverrides: {
        root: {
          textTransform: 'none',
          fontWeight: 600,
          borderRadius: 8,
        },
      },
    },
    MuiCard: {
      styleOverrides: {
        root: {
          boxShadow: '0 4px 20px rgba(0, 0, 0, 0.08)',
          borderRadius: 16,
        },
      },
    },
  },
});

function Navigation() {
  const location = useLocation();
  const handleLogout = () => {
    storage.removeToken();
    window.location.href = '/login';
  };

  if (!storage.isAuthenticated()) return null;

  return (
    <AppBar 
      position="static"
      sx={{
        background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
        boxShadow: '0 4px 20px rgba(102, 126, 234, 0.3)',
      }}
    >
      <Toolbar>
        <Typography 
          variant="h6" 
          component="div" 
          sx={{ 
            flexGrow: 1,
            fontWeight: 700,
            fontSize: '1.5rem',
          }}
        >
          FutureX Dashboard
        </Typography>
        <Box sx={{ display: 'flex', gap: 1 }}>
          <Button
            color="inherit"
            component={Link}
            to="/users"
            sx={{
              backgroundColor: location.pathname === '/users' ? 'rgba(255, 255, 255, 0.2)' : 'transparent',
              borderRadius: 2,
              px: 2,
              '&:hover': {
                backgroundColor: 'rgba(255, 255, 255, 0.15)',
              },
            }}
          >
            Users
          </Button>
          <Button
            color="inherit"
            component={Link}
            to="/videos/upload"
            sx={{
              backgroundColor: location.pathname === '/videos/upload' ? 'rgba(255, 255, 255, 0.2)' : 'transparent',
              borderRadius: 2,
              px: 2,
              '&:hover': {
                backgroundColor: 'rgba(255, 255, 255, 0.15)',
              },
            }}
          >
            Upload Video
          </Button>
          <Button 
            color="inherit" 
            onClick={handleLogout}
            sx={{
              borderRadius: 2,
              px: 2,
              '&:hover': {
                backgroundColor: 'rgba(255, 255, 255, 0.1)',
              },
            }}
          >
            Logout
          </Button>
        </Box>
      </Toolbar>
    </AppBar>
  );
}

function App() {
  return (
    <ThemeProvider theme={theme}>
      <CssBaseline />
      <BrowserRouter>
        <Navigation />

        <Routes>
          <Route path="/login" element={<LoginPage />} />
          <Route
            path="/users"
            element={
              <ProtectedRoute>
                <UserListPage />
              </ProtectedRoute>
            }
          />
          <Route
            path="/users/:id"
            element={
              <ProtectedRoute>
                <UserDetailPage />
              </ProtectedRoute>
            }
          />
          <Route
            path="/videos/upload"
            element={
              <ProtectedRoute>
                <VideoUploadPage />
              </ProtectedRoute>
            }
          />
          <Route path="/" element={<Navigate to="/users" replace />} />
        </Routes>
      </BrowserRouter>
    </ThemeProvider>
  );
}

export default App;

