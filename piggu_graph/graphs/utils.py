import psycopg2
import pandas as pd
import matplotlib.pyplot as plt
from django.conf import settings

def fetch_data_from_postgresql():
    try:
        # Connect to PostgreSQL
        connection = psycopg2.connect(
            dbname="piggu",
            user="postgres",
            password="1234",
            host="localhost",
            port="5432"
        )
        # Query to fetch category and total amount
        query = "SELECT source, SUM(amount) as total FROM piggu_expense GROUP BY source;"
        # Use Pandas to execute the query and return a DataFrame
        data = pd.read_sql_query(query, connection)
        return data
    except Exception as e:
        raise Exception(f"Database error: {e}")
    finally:
        if connection:
            connection.close()

def create_bar_chart(data):
    # Create a bar chart from the data
    plt.figure(figsize=(10, 6))
    plt.bar(data['source'], data['total'], color=['green', 'red', 'blue', 'orange'])
    plt.title('Category-wise Total Amount')
    plt.xlabel('Category')
    plt.ylabel('Total Amount')
    # Save chart as a PNG file
    chart_path = 'static/charts/category_chart.png'
    plt.savefig(chart_path)
    plt.close()
    return chart_path
