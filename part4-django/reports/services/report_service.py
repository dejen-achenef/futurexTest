from typing import Dict, List
from collections import Counter
from .node_api_client import NodeApiClient


class ReportService:
    """Service to generate reports from Node.js API data"""
    
    def __init__(self):
        self.api_client = NodeApiClient()
    
    def generate_summary_report(self) -> Dict:
        """Generate summary report with total users, videos, and top categories"""
        try:
            # Get videos first (they don't require authentication)
            videos = self.api_client.get_videos()
            
            # Try to get users, but fallback to counting unique user IDs from videos
            # if authentication is required (users endpoint needs auth)
            try:
                users = self.api_client.get_users()
                # If we got users successfully and the list is not empty, use it
                if users and len(users) > 0:
                    total_users = len(users)
                else:
                    # Empty list means auth failed, count from videos
                    total_users = self._count_unique_users_from_videos(videos)
            except Exception as e:
                # If users endpoint fails, count unique user IDs from videos
                total_users = self._count_unique_users_from_videos(videos)
            
            # Count videos by category
            categories = [video.get('category', 'Unknown') for video in videos]
            category_counts = Counter(categories)
            top_categories = [
                {'category': cat, 'count': count}
                for cat, count in category_counts.most_common(5)
            ]
            
            return {
                'total_users': total_users,
                'total_videos': len(videos),
                'top_categories': top_categories,
                'categories_count': len(category_counts),
            }
        except Exception as e:
            raise Exception(f"Failed to generate summary report: {str(e)}")
    
    def _count_unique_users_from_videos(self, videos: List[Dict]) -> int:
        """Count unique user IDs from video list"""
        unique_user_ids = set()
        for video in videos:
            # Try multiple possible field names and structures
            user_id = None
            
            # Direct fields (camelCase or snake_case)
            user_id = video.get('userId') or video.get('user_id')
            
            # Nested user object
            if not user_id:
                user_obj = video.get('user')
                if user_obj:
                    if isinstance(user_obj, dict):
                        user_id = user_obj.get('id')
                    elif hasattr(user_obj, 'id'):
                        user_id = user_obj.id
            
            if user_id:
                unique_user_ids.add(int(user_id))  # Ensure it's an integer
        
        return len(unique_user_ids)
    
    def generate_user_activity_report(self, user_id: int) -> Dict:
        """Generate activity report for a specific user"""
        try:
            # Get all videos first (they don't require authentication)
            videos = self.api_client.get_videos()
            
            # Filter videos by user (check multiple possible field locations)
            user_videos = []
            user_info = None  # Will be populated from API or videos
            
            for video in videos:
                video_user_id = None
                # Try direct fields
                video_user_id = video.get('userId') or video.get('user_id')
                # Try nested user object
                if not video_user_id:
                    user_obj = video.get('user')
                    if user_obj:
                        if isinstance(user_obj, dict):
                            video_user_id = user_obj.get('id')
                            # If we found user info in video, save it
                            if not user_info and int(video_user_id) == user_id:
                                user_info = {
                                    'id': user_obj.get('id'),
                                    'name': user_obj.get('name', 'Unknown User'),
                                    'email': user_obj.get('email', 'N/A'),
                                }
                        elif hasattr(user_obj, 'id'):
                            video_user_id = user_obj.id
                
                if video_user_id and int(video_user_id) == user_id:
                    user_videos.append(video)
            
            # Try to get user from API (requires auth, but we have fallback)
            if not user_info:
                user = self.api_client.get_user_by_id(user_id)
                if user:
                    user_info = {
                        'id': user.get('id'),
                        'name': user.get('name', 'Unknown User'),
                        'email': user.get('email', 'N/A'),
                    }
            
            # If still no user info, create a basic one from the user_id
            if not user_info:
                if len(user_videos) > 0:
                    # We have videos but no user info - create basic user object
                    user_info = {
                        'id': user_id,
                        'name': 'Unknown User',
                        'email': 'N/A',
                    }
                else:
                    raise Exception(f"User with ID {user_id} not found or has no videos")
            
            # Count videos by category for this user
            categories = [video.get('category', 'Unknown') for video in user_videos]
            category_counts = Counter(categories)
            
            # Calculate total duration
            total_duration = sum(
                video.get('duration', 0) or 0
                for video in user_videos
            )
            
            return {
                'user': user_info,
                'total_videos': len(user_videos),
                'videos_by_category': dict(category_counts),
                'total_duration_seconds': total_duration,
                'total_duration_formatted': self._format_duration(total_duration),
                'videos': user_videos,
            }
        except Exception as e:
            raise Exception(f"Failed to generate user activity report: {str(e)}")
    
    def _format_duration(self, seconds: int) -> str:
        """Format duration in seconds to human-readable format"""
        hours = seconds // 3600
        minutes = (seconds % 3600) // 60
        secs = seconds % 60
        
        if hours > 0:
            return f"{hours}h {minutes}m {secs}s"
        elif minutes > 0:
            return f"{minutes}m {secs}s"
        else:
            return f"{secs}s"

