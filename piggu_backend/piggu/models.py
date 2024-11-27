from django.db import models

class User(models.Model):
    user_id = models.CharField(max_length=128, unique=True)
    email = models.EmailField(unique=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.email

class Income(models.Model):
    user_id = models.CharField(max_length=255)  # Link to Firebase UID
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    source = models.CharField(max_length=255)
    timestamp = models.DateTimeField()
    # Explicitly set the database table name
    class Meta:
        db_table = 'piggu_income'  # Use the piggu_income table in the database

    def __str__(self):
        return f"{self.source} - {self.amount}"

class Expense(models.Model):
    user_id = models.CharField(max_length=128)
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    source = models.CharField(max_length=255)
    timestamp = models.DateTimeField()
    # Explicitly set the database table name
    class Meta:
        db_table = 'piggu_expense'  # Use the piggu_expense table in the database

    def __str__(self):
        return f"{self.user_id} - {self.source} - ${self.amount}"

class Receipt(models.Model):
    receipt_number = models.CharField(max_length=255)
    receipt_date = models.DateField()
    total_amount = models.DecimalField(max_digits=10, decimal_places=2)
    merchant_name = models.CharField(max_length=255)
    category = models.CharField(max_length=100, blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Receipt {self.receipt_number}"