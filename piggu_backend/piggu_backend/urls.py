"""
URL configuration for piggu_backend project.

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/5.1/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.urls import path, include 
from piggu.views import IncomeViews, ExpenseViews, RegisterUserView, UserChartData


urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/register/', RegisterUserView.as_view(), name='register'),
    path('api/income/', IncomeViews.as_view(), name='income-api'),
    path('api/expense/', ExpenseViews.as_view(), name='expense-api'),
    path('api/user-chart-data/', UserChartData.as_view(), name='user-chart-data'),
    path('', include('piggu.urls')),  # Include app-level URLs
]