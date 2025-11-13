import app.compat as compat
import os
from datetime import datetime, timedelta
from typing import Optional
from jose import JWTError, jwt
from passlib.context import CryptContext
from app.models.schemas import TokenData

# Secret key for JWT (in production, use environment variable)
SECRET_KEY = os.getenv("SECRET_KEY", "secret-key")
ALGORITHM = os.getenv("ALGORITHM", "HS256")
ACCESS_TOKEN_EXPIRE_MINUTES = int(os.getenv("ACCESS_TOKEN_EXPIRE_MINUTES", 60 * 24 * 30))

# Password hashing context
# Using bcrypt - passwords will be truncated to 72 bytes before hashing
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


def get_password_hash(password: str) -> str:
    """
    Hash a password using Passlib with bcrypt.
    Passlib safely handles the 72-byte bcrypt limit.
    """
    password = password.strip()
    return pwd_context.hash(password)


def verify_password(plain_password: str, hashed_password: str) -> bool:
    """
    Verify a password against its bcrypt hash.
    """
    plain_password = plain_password.strip()
    return pwd_context.verify(plain_password, hashed_password)


def create_access_token(data: dict, expires_delta: Optional[timedelta] = None) -> str:
	"""
	Create a JWT access token.
	
	Args:
		data: Dictionary containing user data (e.g., {"sub": username})
		expires_delta: Optional expiration time delta
	
	Returns:
		Encoded JWT token string
	"""
	to_encode = data.copy()
	if expires_delta:
		expire = datetime.utcnow() + expires_delta
	else:
		expire = datetime.utcnow() + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
	
	to_encode.update({"exp": expire})
	encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
	return encoded_jwt


def decode_access_token(token: str) -> Optional[TokenData]:
	"""
	Decode and verify a JWT access token.
	
	Args:
		token: JWT token string
	
	Returns:
		TokenData if valid, None otherwise
	"""
	try:
		payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
		username: str = payload.get("sub")
		if username is None:
			return None
		return TokenData(username=username)
	except JWTError:
		return None

