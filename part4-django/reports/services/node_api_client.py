import requests
import aiohttp
import asyncio
from django.conf import settings
from typing import List, Dict, Optional


class NodeApiClient:
    """Client to fetch data from Node.js API"""
    
    def __init__(self):
        self.base_url = settings.NODE_API_BASE_URL
        self.timeout = 10
    
    def _get_headers(self) -> Dict[str, str]:
        """Get default headers for API requests"""
        return {
            'Content-Type': 'application/json',
        }
    
    def get_users(self) -> List[Dict]:
        """Fetch all users from Node.js API"""
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
        except requests.RequestException as e:
            raise Exception(f"Failed to fetch users: {str(e)}")
    
    def get_videos(self, search: Optional[str] = None, category: Optional[str] = None) -> List[Dict]:
        """Fetch all videos from Node.js API"""
        try:
            params = {}
            if search:
                params['search'] = search
            if category:
                params['category'] = category
            
            response = requests.get(
                f'{self.base_url}/videos',
                headers=self._get_headers(),
                params=params,
                timeout=self.timeout
            )
            response.raise_for_status()
            data = response.json()
            return data.get('videos', [])
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
        """Fetch a specific user by ID"""
        try:
            response = requests.get(
                f'{self.base_url}/users/{user_id}',
                headers=self._get_headers(),
                timeout=self.timeout
            )
            response.raise_for_status()
            return response.json()
        except requests.RequestException as e:
            if response.status_code == 404:
                return None
            raise Exception(f"Failed to fetch user: {str(e)}")

