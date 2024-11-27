from django.urls import path
from piggu.views import IncomeViews, ExpenseViews
from .views import RegisterUserView
from .views import UserChartData
from . import views

urlpatterns = [
    path('income/', IncomeViews.as_view(), name='income-api'),
    path('expense/', ExpenseViews.as_view(), name='expense-api'),
    path('register/', RegisterUserView.as_view(), name='register'),
    path('user-chart-data/', UserChartData.as_view(), name='user_chart_data'),
    path('api/receipt-ocr/', views.receipt_ocr, name='receipt-ocr'),
    path('predict/', views.predict, name='predict'),
]

