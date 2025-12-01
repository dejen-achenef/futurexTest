import requests
import aiohttp
import asyncio
from django.conf import settings
from typing import List, Dict, Optional


class NodeApiClient:
    """Client to fetch data from Node.js API"""
    
    def __init__(self):
        self.base_url = settings.NODE_API_BASE_URL
        self.timeout = 60  # Increased for Render's free tier cold starts (30-60 seconds)
    
    def _get_headers(self) -> Dict[str, str]:
        """Get default headers for API requests"""
        return {
            'Content-Type': 'application/json',
        }
    
    def get_users(self) -> List[Dict]:
        """Fetch all users from Node.js API
        
        Note: This endpoint requires authentication.
        If authentication fails, returns empty list (for summary report fallback).
        """
        try:
            # Note: This endpoint requires authentication
            # In production, you'd need to pass a token
            response = requests.get(
                f'{self.base_url}/users',
                headers=self._get_headers(),
                timeout=self.timeout
            )
            response.raise_for_status()
            data = response.json()
            return data.get('users', [])
        except requests.exceptions.Timeout:
            raise Exception(f"Request timed out after {self.timeout} seconds. Render free tier may be sleeping. Please try again in 30-60 seconds.")
        except requests.exceptions.HTTPError as e:
            if e.response.status_code == 401:
                # Authentication required - return empty list for fallback
                return []
            raise Exception(f"Failed to fetch users: HTTP {e.response.status_code}")
        except requests.RequestException as e:
            raise Exception(f"Failed to fetch users: {str(e)}")
    
    def get_videos(self, search: Optional[str] = None, category: Optional[str] = None) -> List[Dict]:
        """Fetch all videos from Node.js API (handles pagination automatically)"""
        try:
            params = {}
            if search:
                params['search'] = search
            if category:
                params['category'] = category
            
            # Set a high limit to get all videos (or fetch all pages)
            params['limit'] = 1000  # Get up to 1000 videos per request
            params['page'] = 1
            
            all_videos = []
            while True:
                response = requests.get(
                    f'{self.base_url}/videos',
                    headers=self._get_headers(),
                    params=params,
                    timeout=self.timeout
                )
                response.raise_for_status()
                data = response.json()
                videos = data.get('videos', [])
                all_videos.extend(videos)
                
                # Check if there are more pages
                pagination = data.get('pagination', {})
                current_page = pagination.get('page', 1)
                total_pages = pagination.get('totalPages', 1)
                
                if current_page >= total_pages:
                    break
                
                params['page'] = current_page + 1
            
            return all_videos
        except requests.exceptions.Timeout:
            raise Exception(f"Request timed out after {self.timeout} seconds. Render free tier may be sleeping. Please try again in 30-60 seconds.")
        except requests.RequestException as e:
            raise Exception(f"Failed to fetch videos: {str(e)}")
    
    async def get_users_async(self) -> List[Dict]:
        """Async version to fetch all users"""
        try:
            async with aiohttp.ClientSession() as session:
                async with session.get(
                    f'{self.base_url}/users',
                    headers=self._get_headers(),
                    timeout=aiohttp.ClientTimeout(total=self.timeout)
                ) as response:
                    response.raise_for_status()
                    data = await response.json()
                    return data.get('users', [])
        except Exception as e:
            raise Exception(f"Failed to fetch users: {str(e)}")
    
    async def get_videos_async(self, search: Optional[str] = None, category: Optional[str] = None) -> List[Dict]:
        """Async version to fetch all videos"""
        try:
            params = {}
            if search:
                params['search'] = search
            if category:
                params['category'] = category
            
            async with aiohttp.ClientSession() as session:
                async with session.get(
                    f'{self.base_url}/videos',
                    headers=self._get_headers(),
                    params=params,
                    timeout=aiohttp.ClientTimeout(total=self.timeout)
                ) as response:
                    response.raise_for_status()
                    data = await response.json()
                    return data.get('videos', [])
        except Exception as e:
            raise Exception(f"Failed to fetch videos: {str(e)}")
    
    def get_user_by_id(self, user_id: int) -> Optional[Dict]:
        """Fetch a specific user by ID
        
        Note: This endpoint requires authentication.
        Returns None if user not found or authentication fails.
        """
        try:
            response = requests.get(
                f'{self.base_url}/users/{user_id}',
                headers=self._get_headers(),
                timeout=self.timeout
            )
            response.raise_for_status()
            return response.json()
        except requests.exceptions.Timeout:
            raise Exception(f"Request timed out after {self.timeout} seconds. Render free tier may be sleeping. Please try again in 30-60 seconds.")
        except requests.exceptions.HTTPError as e:
            if e.response.status_code == 404:
                return None
            elif e.response.status_code == 401:
                # Authentication required - return None so we can try fallback
                return None
            raise Exception(f"Failed to fetch user: HTTP {e.response.status_code}")
        except requests.RequestException as e:
            raise Exception(f"Failed to fetch user: {str(e)}")

