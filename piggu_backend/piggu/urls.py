from django.urls import path
from piggu.views import Income, Expense
from .views import RegisterUserView
#from .views import IncomeExpenseSummaryView

urlpatterns = [
    path('income/', Income.as_view(), name='income-api'),
    path('expense/', Expense.as_view(), name='expense-api'),
    path('register/', RegisterUserView.as_view(), name='register'),
    #path('summary/', IncomeExpenseSummaryView.as_view(), name='income_expense_summary'),
]
