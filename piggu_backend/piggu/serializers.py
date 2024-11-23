from rest_framework import serializers
from .models import Income, Expense
from .models import User

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['user_id', 'email', 'created_at']

class IncomeSerializer(serializers.ModelSerializer):
    class Meta:
        model = Income
        fields = ['user_id','amount', 'source', 'timestamp']

    #def create(self, validated_data):
        # Custom logic if needed before saving
        #return Income.objects.create(**validated_data)

class ExpenseSerializer(serializers.ModelSerializer):
    class Meta:
        model = Expense
        fields = ['user_id','id','amount', 'source', 'timestamp']

    #def create(self, validated_data):
        # Custom logic if needed before saving
        #return Expense.objects.create(**validated_data)
