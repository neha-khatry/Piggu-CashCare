from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from .utils import predict

class PredictView(APIView):
    def post(self, request):
        features = request.data.get('features', [])
        
        # Check if the number of features is correct (5)
        if len(features) != 5:
            return Response({"error": "Missing or incorrect number of features. Expected 5."}, status=status.HTTP_400_BAD_REQUEST)
        
        try:
            # Get the prediction, category, and recommendation
            prediction, category, recommendation = predict(features)
            
            return Response({
                "prediction": prediction,
                "category": category,
                "recommendation": recommendation
            }, status=status.HTTP_200_OK)
        
        except Exception as e:
            return Response({"error": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
