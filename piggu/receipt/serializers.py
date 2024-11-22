from rest_framework import serializers
from .models import Receipt

class ReceiptSerializer(serializers.ModelSerializer):
    class Meta:
        model = Receipt
        fields = ['receipt_number', 'receipt_date', 'total_amount', 'merchant_name', 'category']
