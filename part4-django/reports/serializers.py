from rest_framework import serializers


class CategoryCountSerializer(serializers.Serializer):
    """Serializer for category count"""
    category = serializers.CharField()
    count = serializers.IntegerField()


class SummaryReportSerializer(serializers.Serializer):
    """Serializer for summary report"""
    total_users = serializers.IntegerField()
    total_videos = serializers.IntegerField()
    top_categories = serializers.ListField(
        child=CategoryCountSerializer()
    )
    categories_count = serializers.IntegerField()


class UserSerializer(serializers.Serializer):
    """Serializer for user in activity report"""
    id = serializers.IntegerField()
    name = serializers.CharField()
    email = serializers.CharField()


class UserActivityReportSerializer(serializers.Serializer):
    """Serializer for user activity report"""
    user = UserSerializer()
    total_videos = serializers.IntegerField()
    videos_by_category = serializers.DictField()
    total_duration_seconds = serializers.IntegerField()
    total_duration_formatted = serializers.CharField()
    videos = serializers.ListField()

