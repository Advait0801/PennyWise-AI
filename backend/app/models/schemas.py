from typing import List, Optional
from pydantic import BaseModel, Field


class ClassifyRequest(BaseModel):
	description: str = Field(..., min_length=1)


class ClassifyResponse(BaseModel):
	category: str
	probability: float
	top_classes: List[str]


class ExpenseCreate(BaseModel):
	description: str = Field(..., min_length=1)
	amount: float = Field(..., gt=0)
	date: Optional[str] = None  # ISO date string (YYYY-MM-DD), optional


class Expense(BaseModel):
	id: int
	description: str
	amount: float
	date: Optional[str] = None
	category: str
	probability: float


class ExpensesResponse(BaseModel):
	expenses: List[Expense]


class CategoryStat(BaseModel):
	category: str
	total_amount: float
	count: int


class CategoryStatsResponse(BaseModel):
	stats: List[CategoryStat]


# User Authentication Schemas
class UserCreate(BaseModel):
	username: str = Field(..., min_length=3, max_length=50)
	email: str = Field(..., pattern=r'^[^@]+@[^@]+\.[^@]+$')
	password: str = Field(..., min_length=6)


class UserLogin(BaseModel):
	username: str
	password: str


class User(BaseModel):
	id: int
	username: str
	email: str


class Token(BaseModel):
	access_token: str
	token_type: str = "bearer"


class TokenData(BaseModel):
	username: Optional[str] = None


