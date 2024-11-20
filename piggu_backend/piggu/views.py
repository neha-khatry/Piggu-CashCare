from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from piggu.serializers import IncomeSerializer, ExpenseSerializer
from piggu.models import Income, Expense  # Make sure to import your models
from firebase_admin import firestore
from django.http import HttpResponse

def home(request):
    return HttpResponse("Welcome to Piggu Backend API")

# Initialize Firestore client
db = firestore.client()

class Income(APIView):
    def post(self, request):
        serializer = IncomeSerializer(data=request.data)
        if serializer.is_valid():
            # Save to PostgreSQL
            income_data = serializer.save()  # Save the data to PostgreSQL
            # Optionally, save to Firestore here
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class Expense(APIView):
    def post(self, request):
        serializer = ExpenseSerializer(data=request.data)
        if serializer.is_valid():
            # Save to PostgreSQL
            expense_data = serializer.save()  # Save the data to PostgreSQL
            # Optionally, save to Firestore here
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)