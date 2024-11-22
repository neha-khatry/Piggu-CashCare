from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from PIL import Image
import pytesseract
import re
from datetime import datetime
import json
import firebase_admin
from firebase_admin import credentials, firestore


# Initialize Firebase Admin with service account credentials
cred = credentials.Certificate(r'C:\Project Main\piggu main\piggu\firebase_key\serviceAccountKey.json')  # Updated path
firebase_admin.initialize_app(cred)

# Get reference to Firestore
db = firestore.client()

@csrf_exempt
def receipt_ocr(request):
    if request.method == 'POST':
        file = request.FILES.get('file')
        if file:
            image = Image.open(file)
            processed_text = pytesseract.image_to_string(image)

            # Clean HTML if needed
            processed_text = re.sub(r'<.*?>', '', processed_text)

            # Date extraction (MM-DD-YYYY or similar)
            date_pattern = r'(\d{2})[-/](\d{2})[-/](\d{4})'
            date_match = re.search(date_pattern, processed_text)
            firebase_date = None
            if date_match:
                month, day, year = date_match.groups()
                formatted_date = f"{year}-{month}-{day}"
                try:
                    # Convert to a valid date format
                    parsed_date = datetime.strptime(formatted_date, "%Y-%m-%d").date()
                    firebase_date = parsed_date  # Store as a date object, not a string
                except ValueError:
                    firebase_date = None

            # Amount extraction
            amount_pattern = r'\$(\d+(?:\.\d{2})?)'
            amount_matches = re.findall(amount_pattern, processed_text)
            amount = max([float(a) for a in amount_matches]) if amount_matches else None

            # Merchant name extraction
            merchant_name = None
            merchant_patterns = [r'(Store|Merchant|Vendor):?\s?([A-Za-z0-9 &]+)']
            for pattern in merchant_patterns:
                match = re.search(pattern, processed_text)
                if match:
                    merchant_name = match.group(2)
                    break
            if not merchant_name:
                merchant_name = processed_text.split('\n')[0]  # Use the first line as fallback

            # Item extraction
            items = []
            item_pattern = r'([A-Za-z0-9 ]+)\s+(\d+(?:\.\d{2})?)'
            for line in processed_text.split('\n'):
                match = re.search(item_pattern, line)
                if match:
                    item_name = match.group(1).strip()
                    item_amount = float(match.group(2))
                    items.append({"name": item_name, "amount": item_amount})

            # Save the receipt data to Firestore
            if firebase_date and amount and merchant_name:
                receipt_data = {
                    "amount": amount,
                    "source": "Others",  # You can set a more specific source if needed
                    "timestamp": firebase_date.strftime('%d %B %Y'),
                    "merchant": merchant_name,
                    "items": items,
                    "total": amount
                }

                # Save to Firestore (you can change the collection name if needed)
                db.collection('receipts').add(receipt_data)

                return JsonResponse({
                    "message": "Receipt saved successfully",
                    "processed_text": processed_text,
                    "extracted_data": receipt_data
                }, status=200)
            else:
                return JsonResponse({"error": "Required data not found in receipt text"}, status=400)

        return JsonResponse({"error": "No file uploaded"}, status=400)

    return JsonResponse({"error": "Invalid request method"}, status=400)
