from datetime import datetime
from django.db.models import Sum
from .models import Income, Expense, MonthlySummary

def aggregate_monthly_summary(user_id):
    today = datetime.today()

    last_month = today.month - 1 if today.month > 1 else 12
    last_year = today.year if today.month > 1 else today.year - 1

    # Calculate totals
    total_income = Income.objects.filter(
        user_id=user_id,
        timestamp__month=last_month,
        timestamp__year=last_year
    ).aggregate(total=Sum('amount'))['total'] or 0

    total_expense = Expense.objects.filter(
        user_id=user_id,
        timestamp__month=last_month,
        timestamp__year=last_year
    ).aggregate(total=Sum('amount'))['total'] or 0

    balance = total_income - total_expense

    # Save to MonthlySummary
    MonthlySummary.objects.update_or_create(
        user_id=user_id,
        month=last_month,
        year=last_year,
        defaults={
            'total_income': total_income,
            'total_expense': total_expense,
            'balance': balance
        }
    )
