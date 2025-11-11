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


