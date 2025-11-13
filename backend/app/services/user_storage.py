from typing import List, Optional
from ..models.schemas import User, UserCreate
from .auth import get_password_hash


class InMemoryUserStore:
	"""In-memory storage for users."""
	
	def __init__(self) -> None:
		self._users: List[dict] = []  # Store user dicts with hashed passwords
		self._next_id: int = 1
	
	def create_user(self, user_create: UserCreate) -> User:
		"""
		Create a new user.
		
		Args:
			user_create: User creation data
		
		Returns:
			Created User (without password)
		
		Raises:
			ValueError: If username or email already exists
		"""
		# Check if username exists
		if self.get_user_by_username(user_create.username):
			raise ValueError("Username already exists")
		
		# Check if email exists
		if self.get_user_by_email(user_create.email):
			raise ValueError("Email already exists")
		
		# Create user
		user_dict = {
			"id": self._next_id,
			"username": user_create.username,
			"email": user_create.email,
			"hashed_password": get_password_hash(user_create.password)
		}
		self._users.append(user_dict)
		self._next_id += 1
		
		return User(
			id=user_dict["id"],
			username=user_dict["username"],
			email=user_dict["email"]
		)
	
	def get_user_by_username(self, username: str) -> Optional[dict]:
		"""Get user by username (returns dict with hashed_password)."""
		for user in self._users:
			if user["username"] == username:
				return user
		return None
	
	def get_user_by_email(self, email: str) -> Optional[User]:
		"""Get user by email."""
		for user in self._users:
			if user["email"] == email:
				return User(
					id=user["id"],
					username=user["username"],
					email=user["email"]
				)
		return None
	
	def get_user_by_id(self, user_id: int) -> Optional[User]:
		"""Get user by ID."""
		for user in self._users:
			if user["id"] == user_id:
				return User(
					id=user["id"],
					username=user["username"],
					email=user["email"]
				)
		return None


# Global user store instance
user_store = InMemoryUserStore()

