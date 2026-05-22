from django.urls import path
from .views import ChartData, chart_view

urlpatterns = [
    path('api/chart-data/', ChartData.as_view(), name='chart-data'),
    path('charts/', chart_view, name='charts'),
]
