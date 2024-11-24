import firebase_admin
from firebase_admin import auth

def verify_firebase_token(id_token):
    try:
        # Verify the Firebase ID token
        decoded_token = auth.verify_id_token(id_token)
        return decoded_token  # Return the decoded token if successful
    except firebase_admin.auth.InvalidIdTokenError:
        raise ValueError("Invalid ID token")
    except Exception as e:
        raise ValueError(f"Error verifying ID token: {str(e)}")