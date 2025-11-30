from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import ReportViewSet, SummaryReportView, UserActivityReportView

router = DefaultRouter()
router.register(r'', ReportViewSet, basename='report')

urlpatterns = [
    path('summary/', SummaryReportView.as_view(), name='report-summary'),
    path('user/<int:user_id>/', UserActivityReportView.as_view(), name='report-user'),
    path('', include(router.urls)),
]

