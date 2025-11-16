"""User storage using MongoDB."""
from typing import Optional
from datetime import datetime
from bson import ObjectId
from motor.motor_asyncio import AsyncIOMotorDatabase
from ..models.schemas import User, UserCreate
from .auth import get_password_hash


async def create_user(db: AsyncIOMotorDatabase, user_create: UserCreate) -> User:
	"""
	Create a new user in MongoDB.
	
	Args:
		db: MongoDB database instance
		user_create: User creation data
	
	Returns:
		Created User (without password)
	
	Raises:
		ValueError: If username or email already exists
	"""
	# Check if username exists
	existing_user = await db.users.find_one({"username": user_create.username})
	if existing_user:
		raise ValueError("Username already exists")
	
	# Check if email exists
	existing_email = await db.users.find_one({"email": user_create.email})
	if existing_email:
		raise ValueError("Email already exists")
	
	# Create new user document
	user_doc = {
		"username": user_create.username,
		"email": user_create.email,
		"hashed_password": get_password_hash(user_create.password),
		"created_at": datetime.utcnow(),
		"updated_at": datetime.utcnow()
	}
	
	result = await db.users.insert_one(user_doc)
	
	return User(
		id=str(result.inserted_id),
		username=user_doc["username"],
		email=user_doc["email"]
	)


async def get_user_by_username(db: AsyncIOMotorDatabase, username: str) -> Optional[dict]:
	"""
	Get user by username (returns dict with hashed_password).
	
	Args:
		db: MongoDB database instance
		username: Username to search for
	
	Returns:
		User dict with hashed_password, or None if not found
	"""
	user_doc = await db.users.find_one({"username": username})
	if not user_doc:
		return None
	
	return {
		"id": str(user_doc["_id"]),
		"username": user_doc["username"],
		"email": user_doc["email"],
		"hashed_password": user_doc["hashed_password"]
	}


async def get_user_by_email(db: AsyncIOMotorDatabase, email: str) -> Optional[User]:
	"""
	Get user by email.
	
	Args:
		db: MongoDB database instance
		email: Email to search for
	
	Returns:
		User (without password), or None if not found
	"""
	user_doc = await db.users.find_one({"email": email})
	if not user_doc:
		return None
	
	return User(
		id=str(user_doc["_id"]),
		username=user_doc["username"],
		email=user_doc["email"]
	)


async def get_user_by_id(db: AsyncIOMotorDatabase, user_id: str) -> Optional[User]:
	"""
	Get user by ID.
	
	Args:
		db: MongoDB database instance
		user_id: User ID (MongoDB ObjectId as string)
	
	Returns:
		User (without password), or None if not found
	"""
	try:
		user_doc = await db.users.find_one({"_id": ObjectId(user_id)})
		if not user_doc:
			return None
		
		return User(
			id=str(user_doc["_id"]),
			username=user_doc["username"],
			email=user_doc["email"]
		)
	except Exception:
		return None
