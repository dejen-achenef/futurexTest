from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.views import APIView
from .services.report_service import ReportService
from .serializers import SummaryReportSerializer, UserActivityReportSerializer


class ReportViewSet(viewsets.ViewSet):
    """ViewSet for generating reports"""
    
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.report_service = ReportService()
    
    @action(detail=False, methods=['get'], url_path='summary')
    def summary(self, request):
        """Generate summary report"""
        try:
            report_data = self.report_service.generate_summary_report()
            serializer = SummaryReportSerializer(report_data)
            return Response(serializer.data, status=status.HTTP_200_OK)
        except Exception as e:
            return Response(
                {'error': str(e)},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
    
    @action(detail=True, methods=['get'], url_path='user')
    def user_activity(self, request, pk=None):
        """Generate user activity report"""
        try:
            user_id = int(pk)
            report_data = self.report_service.generate_user_activity_report(user_id)
            serializer = UserActivityReportSerializer(report_data)
            return Response(serializer.data, status=status.HTTP_200_OK)
        except ValueError:
            return Response(
                {'error': 'Invalid user ID'},
                status=status.HTTP_400_BAD_REQUEST
            )
        except Exception as e:
            return Response(
                {'error': str(e)},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )


class SummaryReportView(APIView):
    """API View for summary report"""
    
    def get(self, request):
        """GET /api/report/summary"""
        try:
            report_service = ReportService()
            report_data = report_service.generate_summary_report()
            serializer = SummaryReportSerializer(report_data)
            return Response(serializer.data, status=status.HTTP_200_OK)
        except Exception as e:
            return Response(
                {'error': str(e)},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )


class UserActivityReportView(APIView):
    """API View for user activity report"""
    
    def get(self, request, user_id):
        """GET /api/report/user/<id>"""
        try:
            user_id_int = int(user_id)
            report_service = ReportService()
            report_data = report_service.generate_user_activity_report(user_id_int)
            serializer = UserActivityReportSerializer(report_data)
            return Response(serializer.data, status=status.HTTP_200_OK)
        except ValueError:
            return Response(
                {'error': 'Invalid user ID'},
                status=status.HTTP_400_BAD_REQUEST
            )
        except Exception as e:
            return Response(
                {'error': str(e)},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )

