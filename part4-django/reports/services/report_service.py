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
            users = self.api_client.get_users()
            videos = self.api_client.get_videos()
            
            # Count videos by category
            categories = [video.get('category', 'Unknown') for video in videos]
            category_counts = Counter(categories)
            top_categories = [
                {'category': cat, 'count': count}
                for cat, count in category_counts.most_common(5)
            ]
            
            return {
                'total_users': len(users),
                'total_videos': len(videos),
                'top_categories': top_categories,
                'categories_count': len(category_counts),
            }
        except Exception as e:
            raise Exception(f"Failed to generate summary report: {str(e)}")
    
    def generate_user_activity_report(self, user_id: int) -> Dict:
        """Generate activity report for a specific user"""
        try:
            user = self.api_client.get_user_by_id(user_id)
            if not user:
                raise Exception(f"User with ID {user_id} not found")
            
            # Get all videos
            videos = self.api_client.get_videos()
            
            # Filter videos by user
            user_videos = [
                video for video in videos
                if video.get('userId') == user_id or video.get('user_id') == user_id
            ]
            
            # Count videos by category for this user
            categories = [video.get('category', 'Unknown') for video in user_videos]
            category_counts = Counter(categories)
            
            # Calculate total duration
            total_duration = sum(
                video.get('duration', 0) or 0
                for video in user_videos
            )
            
            return {
                'user': {
                    'id': user.get('id'),
                    'name': user.get('name'),
                    'email': user.get('email'),
                },
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

