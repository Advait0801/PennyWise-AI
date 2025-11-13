from datetime import date
from fastapi import APIRouter, HTTPException, Depends
from app.models.schemas import ExpenseCreate, Expense, ExpensesResponse, User
from app.services.storage import store
from app.services.classifier import get_classifier
from app.dependencies import get_current_user

router = APIRouter(prefix="/expenses", tags=["expenses"])


@router.post("", response_model=Expense, status_code=201)
async def create_expense(
	payload: ExpenseCreate,
	current_user: User = Depends(get_current_user)
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
		
		# Store the expense for the current user
		expense = store.add(current_user.id, expense_payload, category, probability)
		
		return expense
	except Exception as e:
		raise HTTPException(status_code=500, detail=f"Error creating expense: {str(e)}")


@router.get("", response_model=ExpensesResponse)
async def list_expenses(current_user: User = Depends(get_current_user)):
	"""
	Get all expenses for the current user.
	Requires authentication.
	
	Returns a list of all stored expenses for the authenticated user.
	"""
	try:
		expenses = store.list(current_user.id)
		return ExpensesResponse(expenses=expenses)
	except Exception as e:
		raise HTTPException(status_code=500, detail=f"Error retrieving expenses: {str(e)}")

