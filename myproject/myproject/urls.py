
from django.urls import path
from prediction.views import PredictView  # Correct path to the view

urlpatterns = [
    path('api/predict/', PredictView.as_view(), name='predict'),
]

