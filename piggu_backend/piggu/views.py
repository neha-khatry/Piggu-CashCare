from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from piggu.serializers import IncomeSerializer, ExpenseSerializer
from piggu.models import Income, Expense, User  # Ensure to import your models
from firebase_admin import firestore
from django.http import HttpResponse
from django.db.models import Sum
import logging
from .serializers import UserSerializer

def home(request):
    return HttpResponse("Welcome to Piggu Backend API")


# Initialize Firestore client
db = firestore.client()

# Set up logging
logger = logging.getLogger(__name__)

class RegisterUserView(APIView):
    def post(self, request):
        # Ensure 'user_id' comes from Firebase Authentication
        user_id = request.data.get('user_id')
        email = request.data.get('email')

        # Check if user already exists in PostgreSQL
        user, created = User.objects.get_or_create(user_id=user_id, email=email)

        if created:
            return Response({'user_id': user.user_id, 'email': user.email}, status=status.HTTP_201_CREATED)
        else:
            return Response({'message': 'User already exists'}, status=status.HTTP_400_BAD_REQUEST)


class Income(APIView):
    def post(self, request):
        # Ensure 'user_id' is passed with the data
        user_id = request.data.get('user_id')

        # Validate the income data
        serializer = IncomeSerializer(data=request.data)
        if serializer.is_valid():
            # Save income to PostgreSQL with the user_id
            income_data = serializer.save(user_id=user_id)  # Pass user_id for association
            
            # Optionally, save the income data to Firestore
            income_ref = db.collection('incomes').document(user_id).collection('user_incomes').add({
                'amount': float(income_data.amount),
                'source': income_data.source,
                'timestamp': income_data.timestamp
            })
            
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def get(self, request):
        try:
            # Ensure 'user_id' is passed to filter the incomes for the specific user
            user_id = request.query_params.get('user_id')
            if user_id:
                incomes = Income.objects.filter(user_id=user_id).values('amount', 'source', 'timestamp')
                return Response(list(incomes), status=status.HTTP_200_OK)
            else:
                return Response({"error": "User ID is required."}, status=status.HTTP_400_BAD_REQUEST)
        except Exception as e:
            # Log the error
            logger.error(f"Error fetching incomes: {str(e)}")
            return Response({"error": f"Failed to fetch incomes: {str(e)}"}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


class Expense(APIView):
    def post(self, request):
        # Ensure 'user_id' is passed with the data
        user_id = request.data.get('user_id')

        # Validate the expense data
        serializer = ExpenseSerializer(data=request.data)
        if serializer.is_valid():
            # Save expense to PostgreSQL with the user_id
            expense_data = serializer.save(user_id=user_id)  # Pass user_id for association
            
            # Optionally, save the expense data to Firestore
            expense_ref = db.collection('expenses').document(user_id).collection('user_expenses').add({
                'amount': expense_data.amount,
                'source': expense_data.source,
                'timestamp': expense_data.timestamp
            })
            
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def get(self, request):
        try:
            # Ensure 'user_id' is passed to filter the expenses for the specific user
            user_id = request.query_params.get('user_id')
            if user_id:
                expenses = Expense.objects.filter(user_id=user_id)
                # Serialize expenses for the user
                serializer = ExpenseSerializer(expenses, many=True)
                return Response(serializer.data, status=status.HTTP_200_OK)
            else:
                return Response({"error": "User ID is required."}, status=status.HTTP_400_BAD_REQUEST)
        except Exception as e:
            # Log the error
            logger.error(f"Error fetching expenses: {str(e)}")
            return Response({"error": f"Failed to fetch expenses: {str(e)}"}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


class IncomeExpenseSummaryView(APIView):
    def get(self, request):
        try:
            # Ensure 'user_id' is passed for aggregation
            user_id = request.query_params.get('user_id')
            if not user_id:
                return Response({"error": "User ID is required."}, status=status.HTTP_400_BAD_REQUEST)
            
            # Aggregate total income and expenses for the user
            total_income = Income.objects.filter(user_id=user_id).aggregate(Sum('amount'))['amount__sum'] or 0
            total_expenses = Expense.objects.filter(user_id=user_id).aggregate(Sum('amount'))['amount__sum'] or 0
            
            return Response(
                {
                    "income": total_income,
                    "expenses": total_expenses
                },
                status=status.HTTP_200_OK
            )
        except Exception as e:
            return Response(
                {"error": f"An error occurred: {str(e)}"},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
