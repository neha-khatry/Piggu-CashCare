from django.http import HttpResponse
from django.db.models import Sum
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from piggu.models import Income, Expense, User
from piggu.serializers import IncomeSerializer, ExpenseSerializer
from firebase_admin import firestore
import matplotlib.pyplot as plt
import pandas as pd
from io import BytesIO
import base64
import logging
from firebase_admin import auth
from rest_framework.decorators import api_view

# Initialize Firestore client
db = firestore.client()

# Set up logging
logger = logging.getLogger(__name__)

# Home route for a simple welcome message
def home(request):
    return HttpResponse("Welcome to Piggu Backend API")

# Register User View
class RegisterUserView(APIView):
    def post(self, request):
        user_id = request.data.get('user_id')
        email = request.data.get('email')

        # Check if user already exists in PostgreSQL
        user, created = User.objects.get_or_create(user_id=user_id, email=email)

        if created:
            return Response({'user_id': user.user_id, 'email': user.email}, status=status.HTTP_201_CREATED)
        else:
            return Response({'message': 'User already exists'}, status=status.HTTP_400_BAD_REQUEST)


# Income-related API view
class IncomeViews(APIView):
    def post(self, request):
        user_id = request.data.get('user_id')

        # Validate income data
        serializer = IncomeSerializer(data=request.data)
        if serializer.is_valid():
            # Save income to PostgreSQL with the user_id
            income_data = serializer.save(user_id=user_id)
            
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def get(self, request):
        try:
            user_id = request.query_params.get('user_id')
            if user_id:
                incomes = Income.objects.filter(user_id=user_id).values('amount', 'source', 'timestamp')
                return Response(list(incomes), status=status.HTTP_200_OK)
            else:
                return Response({"error": "User ID is required."}, status=status.HTTP_400_BAD_REQUEST)
        except Exception as e:
            logger.error(f"Error fetching incomes: {str(e)}")
            return Response({"error": f"Failed to fetch incomes: {str(e)}"}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


# Expense-related API view
class ExpenseViews(APIView):
    def post(self, request):
        user_id = request.data.get('user_id')

        # Validate expense data
        serializer = ExpenseSerializer(data=request.data)
        if serializer.is_valid():
            # Save expense to PostgreSQL with the user_id
            expense_data = serializer.save(user_id=user_id)
            
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def get(self, request):
        try:
            user_id = request.query_params.get('user_id')
            if user_id:
                expenses = Expense.objects.filter(user_id=user_id)
                serializer = ExpenseSerializer(expenses, many=True)
                return Response(serializer.data, status=status.HTTP_200_OK)
            else:
                return Response({"error": "User ID is required."}, status=status.HTTP_400_BAD_REQUEST)
        except Exception as e:
            logger.error(f"Error fetching expenses: {str(e)}")
            return Response({"error": f"Failed to fetch expenses: {str(e)}"}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


class UserChartData(APIView):
    def get(self, request):
        user_id = request.headers.get('User-ID')  # Get user_id from the request header

        if not user_id:
            return Response({"error": "User ID is required."}, status=status.HTTP_400_BAD_REQUEST)

        # Check if user exists in the database
        try:
            user = User.objects.get(user_id=user_id)
        except User.DoesNotExist:
            return Response({"error": "User not found."}, status=status.HTTP_404_NOT_FOUND)

        try:
            # Fetch income and expense data for the user
            income_data = Income.objects.filter(user_id=user_id).values('source').annotate(total=Sum('amount'))
            expense_data = Expense.objects.filter(user_id=user_id).values('source').annotate(total=Sum('amount'))

            # If no data is found for income or expenses, return a message
            if not income_data and not expense_data:
                return Response({"error": "No income or expense data found for this user."}, status=status.HTTP_404_NOT_FOUND)

            # Prepare dataframes
            income_df = pd.DataFrame(list(income_data))
            expense_df = pd.DataFrame(list(expense_data))

            charts = {}

            # Generate income chart
            if not income_df.empty:
                fig, ax = plt.subplots(figsize=(10, 6))
                ax.bar(income_df['source'], income_df['total'], color='green', alpha=0.6)
                ax.set_xlabel('Income Source')
                ax.set_ylabel('Total Amount')
                ax.set_title(f'Income ')
                buf = BytesIO()
                plt.savefig(buf, format='png')
                buf.seek(0)
                charts['income_chart'] = base64.b64encode(buf.read()).decode('utf-8')
                plt.close(fig)  # Close the figure after saving to buffer

            # Generate expense chart
            if not expense_df.empty:
                fig, ax = plt.subplots(figsize=(10, 6))
                ax.bar(expense_df['source'], expense_df['total'], color='red', alpha=0.6)
                ax.set_xlabel('Expense Source')
                ax.set_ylabel('Total Amount')
                ax.set_title(f'Expenses')
                buf = BytesIO()
                plt.savefig(buf, format='png')
                buf.seek(0)
                charts['expense_chart'] = base64.b64encode(buf.read()).decode('utf-8')
                plt.close(fig)  # Close the figure after saving to buffer

            # Return the charts along with the income and expense data
            return Response({
                'charts': charts,
                'income': list(income_data),
                'expense': list(expense_data),
            })

        except Exception as e:
            # Log any errors that occur during the process
            logger.error(f"Error generating chart data: {str(e)}")
            return Response({"error": f"An error occurred: {str(e)}"}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)