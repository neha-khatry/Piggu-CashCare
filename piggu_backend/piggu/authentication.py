import firebase_admin
from firebase_admin import auth
from rest_framework.authentication import BaseAuthentication
from rest_framework.exceptions import AuthenticationFailed

class FirebaseAuthentication(BaseAuthentication):
    def authenticate(self, request):
        token = request.headers.get('Authorization')
        if not token:
            return None
        try:
            # Remove "Bearer " from the token string if present
            token = token.split(' ')[1]
            decoded_token = auth.verify_id_token(token)
            user_id = decoded_token.get('uid')
            return (user_id, token)  # Or return user object if available
        except Exception as e:
            raise AuthenticationFailed(f'Invalid Firebase token: {str(e)}')
