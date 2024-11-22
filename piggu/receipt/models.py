from django.db import models
from django.utils import timezone

class Receipt(models.Model):
    receipt_number = models.CharField(max_length=255)
    receipt_date = models.DateField()
    total_amount = models.DecimalField(max_digits=10, decimal_places=2)
    merchant_name = models.CharField(max_length=255)
    category = models.CharField(max_length=100, blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Receipt {self.receipt_number}"
