from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from motor.motor_asyncio import AsyncIOMotorDatabase
from app.services.auth import decode_access_token
from app.services.user_storage import get_user_by_username
from app.models.schemas import User
from app.database import get_database

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="auth/login")


async def get_current_user(
	token: str = Depends(oauth2_scheme),
	db: AsyncIOMotorDatabase = Depends(get_database)
) -> User:
	"""
	Get the current authenticated user from JWT token.
	
	This dependency can be used in route handlers to require authentication.
	
	Example:
		@router.get("/protected")
		async def protected_route(current_user: User = Depends(get_current_user)):
			return {"user": current_user.username}
	"""
	# Decode token
	token_data = decode_access_token(token)
	if token_data is None:
		raise HTTPException(
			status_code=status.HTTP_401_UNAUTHORIZED,
			detail="Could not validate credentials",
			headers={"WWW-Authenticate": "Bearer"},
		)
	
	# Get user from database
	user_dict = await get_user_by_username(db, token_data.username)
	if user_dict is None:
		raise HTTPException(
			status_code=status.HTTP_401_UNAUTHORIZED,
			detail="User not found",
			headers={"WWW-Authenticate": "Bearer"},
		)
	
	return User(
		id=user_dict["id"],
		username=user_dict["username"],
		email=user_dict["email"]
	)

