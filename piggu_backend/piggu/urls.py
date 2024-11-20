from django.urls import path
from piggu.views import Income, Expense

urlpatterns = [
    path('income/', Income.as_view(), name='income-api'),
    path('expense/', Expense.as_view(), name='expense-api'),
]
