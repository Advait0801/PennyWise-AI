from fastapi import APIRouter, HTTPException, status, Depends
from fastapi.security import OAuth2PasswordBearer
from motor.motor_asyncio import AsyncIOMotorDatabase
from app.models.schemas import UserCreate, User, UserLogin, Token
from app.services.user_storage import create_user, get_user_by_username
from app.services.auth import verify_password, create_access_token
from app.database import get_database

router = APIRouter(prefix="/auth", tags=["authentication"])

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="auth/login")


@router.post("/register", response_model=User, status_code=status.HTTP_201_CREATED)
async def register(user_create: UserCreate, db: AsyncIOMotorDatabase = Depends(get_database)):
	"""
	Register a new user.
	
	Returns the created user (without password).
	"""
	try:
		user = await create_user(db, user_create)
		return user
	except ValueError as e:
		raise HTTPException(
			status_code=status.HTTP_400_BAD_REQUEST,
			detail=str(e)
		)


@router.post("/login", response_model=Token)
async def login(login_data: UserLogin, db: AsyncIOMotorDatabase = Depends(get_database)):
	"""
	Login and get access token.
	
	Accepts JSON body with username and password.
	"""
	# Get user from database
	user_dict = await get_user_by_username(db, login_data.username)
	if not user_dict:
		raise HTTPException(
			status_code=status.HTTP_401_UNAUTHORIZED,
			detail="Incorrect username or password",
			headers={"WWW-Authenticate": "Bearer"},
		)
	
	# Verify password
	if not verify_password(login_data.password, user_dict["hashed_password"]):
		raise HTTPException(
			status_code=status.HTTP_401_UNAUTHORIZED,
			detail="Incorrect username or password",
			headers={"WWW-Authenticate": "Bearer"},
		)
	
	# Create access token
	access_token = create_access_token(data={"sub": login_data.username})
	return Token(access_token=access_token, token_type="bearer")

