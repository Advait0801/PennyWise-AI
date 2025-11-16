"""Expense storage using MongoDB."""
from typing import List, Optional
from datetime import date, datetime
from bson import ObjectId
from motor.motor_asyncio import AsyncIOMotorDatabase
from ..models.schemas import Expense, ExpenseCreate


async def create_expense(
	db: AsyncIOMotorDatabase,
	user_id: str,
	payload: ExpenseCreate,
	category: str,
	probability: float
) -> Expense:
	"""
	Create a new expense for a specific user.
	
	Args:
		db: MongoDB database instance
		user_id: ID of the user who owns this expense (MongoDB ObjectId as string)
		payload: Expense creation data
		category: Predicted category
		probability: Prediction confidence
	
	Returns:
		Created Expense
	"""
	# Parse date string to date object
	expense_date = date.today()
	if payload.date:
		try:
			expense_date = datetime.strptime(payload.date, "%Y-%m-%d").date()
		except ValueError:
			expense_date = date.today()
	
	# Create expense document
	expense_doc = {
		"user_id": ObjectId(user_id),
		"description": payload.description,
		"amount": payload.amount,
		"date": expense_date.isoformat(),
		"category": category,
		"probability": probability,
		"created_at": datetime.utcnow(),
		"updated_at": datetime.utcnow()
	}
	
	result = await db.expenses.insert_one(expense_doc)
	
	# Convert to Pydantic model
	return Expense(
		id=str(result.inserted_id),
		description=expense_doc["description"],
		amount=expense_doc["amount"],
		date=expense_doc["date"],
		category=expense_doc["category"],
		probability=expense_doc["probability"]
	)


async def get_expenses_by_user(db: AsyncIOMotorDatabase, user_id: str) -> List[Expense]:
	"""
	Get all expenses for a specific user, ordered by date (newest first).
	
	Args:
		db: MongoDB database instance
		user_id: ID of the user (MongoDB ObjectId as string)
	
	Returns:
		List of expenses for the user
	"""
	try:
		cursor = db.expenses.find({"user_id": ObjectId(user_id)})\
			.sort([("date", -1), ("created_at", -1)])
		
		expenses = []
		async for expense_doc in cursor:
			expenses.append(Expense(
				id=str(expense_doc["_id"]),
				description=expense_doc["description"],
				amount=expense_doc["amount"],
				date=expense_doc.get("date"),
				category=expense_doc["category"],
				probability=expense_doc["probability"]
			))
		
		return expenses
	except Exception:
		return []


async def get_expense_by_id(
	db: AsyncIOMotorDatabase,
	user_id: str,
	expense_id: str
) -> Optional[Expense]:
	"""
	Get a specific expense for a user.
	
	Args:
		db: MongoDB database instance
		user_id: ID of the user (MongoDB ObjectId as string)
		expense_id: ID of the expense (MongoDB ObjectId as string)
	
	Returns:
		Expense if found, None otherwise
	"""
	try:
		expense_doc = await db.expenses.find_one({
			"_id": ObjectId(expense_id),
			"user_id": ObjectId(user_id)
		})
		
		if not expense_doc:
			return None
		
		return Expense(
			id=str(expense_doc["_id"]),
			description=expense_doc["description"],
			amount=expense_doc["amount"],
			date=expense_doc.get("date"),
			category=expense_doc["category"],
			probability=expense_doc["probability"]
		)
	except Exception:
		return None
