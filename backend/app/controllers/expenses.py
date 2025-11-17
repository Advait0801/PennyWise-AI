from datetime import date
from fastapi import APIRouter, HTTPException, Depends
from motor.motor_asyncio import AsyncIOMotorDatabase
from app.models.schemas import ExpenseCreate, Expense, ExpensesResponse, User
from app.services.storage import create_expense, get_expenses_by_user, update_expense, delete_expense
from app.services.classifier import get_classifier
from app.dependencies import get_current_user
from app.database import get_database

router = APIRouter(prefix="/expenses", tags=["expenses"])


@router.post("", response_model=Expense, status_code=201)
async def create_expense_endpoint(
	payload: ExpenseCreate,
	current_user: User = Depends(get_current_user),
	db: AsyncIOMotorDatabase = Depends(get_database)
):
	"""
	Create a new expense. The description will be automatically classified.
	Date is automatically set to today if not provided.
	Requires authentication.
	
	Returns the created expense with its predicted category.
	"""
	try:
		# Classify the expense
		classifier = get_classifier()
		category, probability, _ = classifier.predict(payload.description)
		
		# Set current date if not provided
		expense_date = payload.date if payload.date else date.today().isoformat()
		
		# Create expense with auto-set date
		expense_payload = ExpenseCreate(
			description=payload.description,
			amount=payload.amount,
			date=expense_date
		)
		
		# Store the expense in the database for the current user
		expense = await create_expense(db, current_user.id, expense_payload, category, probability)
		
		return expense
	except Exception as e:
		raise HTTPException(status_code=500, detail=f"Error creating expense: {str(e)}")


@router.get("", response_model=ExpensesResponse)
async def list_expenses_endpoint(
	current_user: User = Depends(get_current_user),
	db: AsyncIOMotorDatabase = Depends(get_database)
):
	"""
	Get all expenses for the current user.
	Requires authentication.
	
	Returns a list of all stored expenses for the authenticated user.
	"""
	try:
		expenses = await get_expenses_by_user(db, current_user.id)
		return ExpensesResponse(expenses=expenses)
	except Exception as e:
		raise HTTPException(status_code=500, detail=f"Error retrieving expenses: {str(e)}")


@router.put("/{expense_id}", response_model=Expense)
async def update_expense_endpoint(
	expense_id: str,
	payload: ExpenseCreate,
	current_user: User = Depends(get_current_user),
	db: AsyncIOMotorDatabase = Depends(get_database)
):
	"""
	Update an existing expense. The description will be re-classified.
	Requires authentication.
	
	Returns the updated expense with its predicted category.
	"""
	try:
		# Re-classify the expense
		classifier = get_classifier()
		category, probability, _ = classifier.predict(payload.description)
		
		# Set current date if not provided
		expense_date = payload.date if payload.date else date.today().isoformat()
		
		# Create expense payload with auto-set date
		expense_payload = ExpenseCreate(
			description=payload.description,
			amount=payload.amount,
			date=expense_date
		)
		
		# Update the expense in the database
		updated_expense = await update_expense(db, current_user.id, expense_id, expense_payload, category, probability)
		
		if not updated_expense:
			raise HTTPException(status_code=404, detail="Expense not found")
		
		return updated_expense
	except HTTPException:
		raise
	except Exception as e:
		raise HTTPException(status_code=500, detail=f"Error updating expense: {str(e)}")


@router.delete("/{expense_id}", status_code=204)
async def delete_expense_endpoint(
	expense_id: str,
	current_user: User = Depends(get_current_user),
	db: AsyncIOMotorDatabase = Depends(get_database)
):
	"""
	Delete an expense.
	Requires authentication.
	
	Returns 204 No Content on success.
	"""
	try:
		deleted = await delete_expense(db, current_user.id, expense_id)
		
		if not deleted:
			raise HTTPException(status_code=404, detail="Expense not found")
		
		return None
	except HTTPException:
		raise
	except Exception as e:
		raise HTTPException(status_code=500, detail=f"Error deleting expense: {str(e)}")

