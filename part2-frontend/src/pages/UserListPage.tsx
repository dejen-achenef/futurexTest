import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import {
  Container,
  Paper,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  TextField,
  Box,
  Typography,
  Avatar,
  Pagination,
  CircularProgress,
  Alert,
  Chip,
  IconButton,
  Tooltip
} from '@mui/material';
import { Visibility } from '@mui/icons-material';
import { userService, User } from '../services/userService';

export const UserListPage: React.FC = () => {
  const navigate = useNavigate();
  const [users, setUsers] = useState<User[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [page, setPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [total, setTotal] = useState(0);
  const [error, setError] = useState<string>('');

  const fetchUsers = async () => {
    setLoading(true);
    try {
      console.log('[UserList] Fetching users:', { search, page });
      const response = await userService.getUsers({
        search: search || undefined,
        page,
        limit: 10
      });
      console.log('[UserList] Response:', response);
      
      // Handle both response formats (with pagination object or direct array)
      if (response.users && Array.isArray(response.users)) {
        setUsers(response.users);
        if (response.pagination) {
          setTotalPages(response.pagination.totalPages || 1);
          setTotal(response.pagination.total || response.users.length);
        } else {
          // Fallback if no pagination data
          setTotalPages(1);
          setTotal(response.users.length);
        }
      } else if (Array.isArray(response)) {
        // Backend returned array directly
        setUsers(response);
        setTotalPages(1);
        setTotal(response.length);
      } else {
        console.error('[UserList] Unexpected response format:', response);
        setUsers([]);
        setTotalPages(1);
        setTotal(0);
      }
      setError('');
    } catch (error: any) {
      console.error('[UserList] Error fetching users:', error);
      console.error('[UserList] Error details:', error.response?.data);
      setUsers([]);
      setTotalPages(1);
      setTotal(0);
      setError(error.response?.data?.error || error.message || 'Failed to fetch users');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchUsers();
  }, [page]);

  useEffect(() => {
    const debounceTimer = setTimeout(() => {
      if (page === 1) {
        fetchUsers();
      } else {
        setPage(1);
      }
    }, 500);

    return () => clearTimeout(debounceTimer);
  }, [search]);

  return (
    <Container maxWidth="lg" sx={{ mt: 4, mb: 4 }}>
      <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 3 }}>
        <Typography variant="h4" component="h1">
          Users
        </Typography>
        {total > 0 && (
          <Chip label={`${total} user${total !== 1 ? 's' : ''}`} color="primary" />
        )}
      </Box>

      {error && (
        <Alert severity="error" sx={{ mb: 3 }} onClose={() => setError('')}>
          {error}
        </Alert>
      )}

      <Box sx={{ mb: 3 }}>
        <TextField
          fullWidth
          label="Search users"
          variant="outlined"
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          placeholder="Search by name or email..."
          InputProps={{
            startAdornment: search && (
              <Box sx={{ mr: 1, color: 'text.secondary' }}>
                🔍
              </Box>
            )
          }}
        />
      </Box>

      {loading ? (
        <Box display="flex" justifyContent="center" p={4}>
          <CircularProgress />
        </Box>
      ) : (
        <>
          <TableContainer component={Paper}>
            <Table>
              <TableHead>
                <TableRow>
                  <TableCell>Avatar</TableCell>
                  <TableCell><strong>Name</strong></TableCell>
                  <TableCell><strong>Email</strong></TableCell>
                  <TableCell><strong>Videos</strong></TableCell>
                  <TableCell><strong>User ID</strong></TableCell>
                  <TableCell align="center"><strong>Actions</strong></TableCell>
                </TableRow>
              </TableHead>
              <TableBody>
                {users.length === 0 ? (
                  <TableRow>
                    <TableCell colSpan={6} align="center" sx={{ py: 4 }}>
                      <Typography variant="body1" color="text.secondary">
                        {search ? `No users found matching "${search}"` : 'No users found'}
                      </Typography>
                    </TableCell>
                  </TableRow>
                ) : (
                  users.map((user) => (
                    <TableRow key={user.id} hover>
                      <TableCell>
                        <Avatar 
                          src={user.avatar ? `https://futurextest-3.onrender.com/uploads/avatars/${user.avatar}` : undefined}
                          sx={{ bgcolor: 'primary.main' }}
                        >
                          {user.name.charAt(0).toUpperCase()}
                        </Avatar>
                      </TableCell>
                      <TableCell>
                        <Typography variant="body1" fontWeight="medium">
                          {user.name}
                        </Typography>
                      </TableCell>
                      <TableCell>{user.email}</TableCell>
                      <TableCell>
                        <Chip 
                          label={`${user.videoCount || 0} video${(user.videoCount || 0) !== 1 ? 's' : ''}`}
                          size="small"
                          color={user.videoCount && user.videoCount > 0 ? 'primary' : 'default'}
                          variant={user.videoCount && user.videoCount > 0 ? 'filled' : 'outlined'}
                        />
                      </TableCell>
                      <TableCell>
                        <Chip label={`#${user.id}`} size="small" variant="outlined" />
                      </TableCell>
                      <TableCell align="center">
                        <Tooltip title="View User Details">
                          <IconButton
                            color="primary"
                            onClick={() => navigate(`/users/${user.id}`)}
                            size="small"
                          >
                            <Visibility />
                          </IconButton>
                        </Tooltip>
                      </TableCell>
                    </TableRow>
                  ))
                )}
              </TableBody>
            </Table>
          </TableContainer>

          {totalPages > 1 && (
            <Box sx={{ mt: 3, display: 'flex', justifyContent: 'center', alignItems: 'center', gap: 2 }}>
              <Pagination
                count={totalPages}
                page={page}
                onChange={(_, value) => setPage(value)}
                color="primary"
                showFirstButton
                showLastButton
              />
            </Box>
          )}

          {total > 0 && (
            <Box sx={{ mt: 2, display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
              <Typography variant="body2" color="text.secondary">
                Showing {((page - 1) * 10) + 1} to {Math.min(page * 10, total)} of {total} users
              </Typography>
              <Typography variant="body2" color="text.secondary">
                Page {page} of {totalPages}
              </Typography>
            </Box>
          )}
        </>
      )}
    </Container>
  );
};

