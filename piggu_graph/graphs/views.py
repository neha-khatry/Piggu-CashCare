from django.http import FileResponse, JsonResponse
from .utils import fetch_data_from_postgresql, create_bar_chart

def chart_view(request):
    try:
        # Fetch data from PostgreSQL
        data = fetch_data_from_postgresql()

        # Generate the bar chart and get the path to the saved image
        chart_path = create_bar_chart(data)

        # Return the generated chart image as a response
        return FileResponse(open(chart_path, 'rb'), content_type='image/png')

    except Exception as e:
        # Return error message if something goes wrong
        return JsonResponse({'error': str(e)}, status=500)
