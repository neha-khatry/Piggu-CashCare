from django.shortcuts import render
from rest_framework.views import APIView
from rest_framework.response import Response
from django.contrib.auth.decorators import login_required
from .models import Income, Expense
from graphs import models

class ChartData(APIView):
    def get(self, request):
        user = request.user
        incomes = Income.objects.filter(user=user)
        expenses = Expense.objects.filter(user=user)

        income_data = incomes.values('source').annotate(total=models.Sum('amount'))
        expense_data = expenses.values('category').annotate(total=models.Sum('amount'))

        return Response({
            'income': list(income_data),
            'expense': list(expense_data),
        })

@login_required
def chart_view(request):
    return render(request, 'charts.html')
