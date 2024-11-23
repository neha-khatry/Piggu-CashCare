from django.urls import path
from . import views

urlpatterns = [
    path('chart/', views.chart_view, name='chart_data'),
]