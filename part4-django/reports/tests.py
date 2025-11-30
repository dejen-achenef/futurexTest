from django.test import TestCase
from unittest.mock import Mock, patch
from .services.report_service import ReportService
from .services.node_api_client import NodeApiClient


class ReportServiceTestCase(TestCase):
    """Test cases for ReportService"""
    
    def setUp(self):
        self.report_service = ReportService()
    
    @patch('reports.services.report_service.NodeApiClient')
    def test_generate_summary_report(self, mock_api_client_class):
        """Test summary report generation"""
        # Mock API client
        mock_client = Mock(spec=NodeApiClient)
        mock_api_client_class.return_value = mock_client
        
        # Mock data
        mock_client.get_users.return_value = [
            {'id': 1, 'name': 'User 1', 'email': 'user1@example.com'},
            {'id': 2, 'name': 'User 2', 'email': 'user2@example.com'},
        ]
        
        mock_client.get_videos.return_value = [
            {'id': 1, 'title': 'Video 1', 'category': 'Education', 'userId': 1},
            {'id': 2, 'title': 'Video 2', 'category': 'Education', 'userId': 1},
            {'id': 3, 'title': 'Video 3', 'category': 'Entertainment', 'userId': 2},
            {'id': 4, 'title': 'Video 4', 'category': 'Technology', 'userId': 2},
        ]
        
        # Create new service instance to use mocked client
        service = ReportService()
        service.api_client = mock_client
        
        # Generate report
        report = service.generate_summary_report()
        
        # Assertions
        self.assertEqual(report['total_users'], 2)
        self.assertEqual(report['total_videos'], 4)
        self.assertEqual(report['categories_count'], 3)
        self.assertEqual(len(report['top_categories']), 3)
        self.assertEqual(report['top_categories'][0]['category'], 'Education')
        self.assertEqual(report['top_categories'][0]['count'], 2)
    
    @patch('reports.services.report_service.NodeApiClient')
    def test_generate_user_activity_report(self, mock_api_client_class):
        """Test user activity report generation"""
        # Mock API client
        mock_client = Mock(spec=NodeApiClient)
        mock_api_client_class.return_value = mock_client
        
        # Mock user data
        mock_client.get_user_by_id.return_value = {
            'id': 1,
            'name': 'Test User',
            'email': 'test@example.com'
        }
        
        # Mock videos data
        mock_client.get_videos.return_value = [
            {
                'id': 1,
                'title': 'Video 1',
                'category': 'Education',
                'userId': 1,
                'duration': 300
            },
            {
                'id': 2,
                'title': 'Video 2',
                'category': 'Education',
                'userId': 1,
                'duration': 600
            },
            {
                'id': 3,
                'title': 'Video 3',
                'category': 'Technology',
                'userId': 2,
                'duration': 450
            },
        ]
        
        # Create new service instance
        service = ReportService()
        service.api_client = mock_client
        
        # Generate report
        report = service.generate_user_activity_report(1)
        
        # Assertions
        self.assertEqual(report['user']['id'], 1)
        self.assertEqual(report['user']['name'], 'Test User')
        self.assertEqual(report['total_videos'], 2)
        self.assertEqual(report['total_duration_seconds'], 900)
        self.assertEqual(report['videos_by_category']['Education'], 2)
        self.assertIn('total_duration_formatted', report)
    
    @patch('reports.services.report_service.NodeApiClient')
    def test_user_not_found(self, mock_api_client_class):
        """Test user activity report when user not found"""
        # Mock API client
        mock_client = Mock(spec=NodeApiClient)
        mock_api_client_class.return_value = mock_client
        
        # Mock user not found
        mock_client.get_user_by_id.return_value = None
        
        # Create new service instance
        service = ReportService()
        service.api_client = mock_client
        
        # Should raise exception
        with self.assertRaises(Exception) as context:
            service.generate_user_activity_report(999)
        
        self.assertIn('not found', str(context.exception).lower())


class NodeApiClientTestCase(TestCase):
    """Test cases for NodeApiClient"""
    
    @patch('reports.services.node_api_client.requests.get')
    def test_get_users_success(self, mock_get):
        """Test successful user fetch"""
        from .services.node_api_client import NodeApiClient
        
        # Mock response
        mock_response = Mock()
        mock_response.json.return_value = {
            'users': [
                {'id': 1, 'name': 'User 1'},
                {'id': 2, 'name': 'User 2'},
            ]
        }
        mock_response.raise_for_status = Mock()
        mock_get.return_value = mock_response
        
        client = NodeApiClient()
        users = client.get_users()
        
        self.assertEqual(len(users), 2)
        self.assertEqual(users[0]['id'], 1)
    
    @patch('reports.services.node_api_client.requests.get')
    def test_get_videos_with_filters(self, mock_get):
        """Test video fetch with search and category filters"""
        from .services.node_api_client import NodeApiClient
        
        # Mock response
        mock_response = Mock()
        mock_response.json.return_value = {
            'videos': [
                {'id': 1, 'title': 'Test Video', 'category': 'Education'},
            ]
        }
        mock_response.raise_for_status = Mock()
        mock_get.return_value = mock_response
        
        client = NodeApiClient()
        videos = client.get_videos(search='Test', category='Education')
        
        # Verify request was made with correct params
        mock_get.assert_called_once()
        call_args = mock_get.call_args
        self.assertIn('search', call_args[1]['params'])
        self.assertIn('category', call_args[1]['params'])

