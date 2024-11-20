from rest_framework import serializers
from .models import Income, Expense

class IncomeSerializer(serializers.ModelSerializer):
    class Meta:
        model = Income
        fields = ['amount', 'source', 'timestamp']

    def create(self, validated_data):
        # Custom logic if needed before saving
        return Income.objects.create(**validated_data)

class ExpenseSerializer(serializers.ModelSerializer):
    class Meta:
        model = Expense
        fields = ['amount', 'source', 'timestamp']

    def create(self, validated_data):
        # Custom logic if needed before saving
        return Expense.objects.create(**validated_data)
