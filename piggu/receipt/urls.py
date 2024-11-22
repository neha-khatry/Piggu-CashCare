# receipt/urls.py
from django.urls import path
from . import views

urlpatterns = [
    path('receipt-ocr/', views.receipt_ocr, name='receipt-ocr'),
    
]
