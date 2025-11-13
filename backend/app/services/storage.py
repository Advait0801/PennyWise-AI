from typing import List, Optional, Dict
from ..models.schemas import Expense, ExpenseCreate


class InMemoryExpenseStore:
	"""In-memory storage for expenses, organized by user."""
	
	def __init__(self) -> None:
		# Dictionary: user_id -> list of expenses
		self._user_expenses: Dict[int, List[Expense]] = {}
		self._next_id: int = 1

	def add(self, user_id: int, payload: ExpenseCreate, category: str, probability: float) -> Expense:
		"""
		Add an expense for a specific user.
		
		Args:
			user_id: ID of the user who owns this expense
			payload: Expense creation data
			category: Predicted category
			probability: Prediction confidence
		
		Returns:
			Created Expense
		"""
		expense = Expense(
			id=self._next_id,
			description=payload.description,
			amount=payload.amount,
			date=payload.date,
			category=category,
			probability=probability,
		)
		
		# Initialize user's expense list if needed
		if user_id not in self._user_expenses:
			self._user_expenses[user_id] = []
		
		self._user_expenses[user_id].append(expense)
		self._next_id += 1
		return expense

	def list(self, user_id: int) -> List[Expense]:
		"""
		Get all expenses for a specific user.
		
		Args:
			user_id: ID of the user
		
		Returns:
			List of expenses for the user
		"""
		return list(self._user_expenses.get(user_id, []))

	def get(self, user_id: int, expense_id: int) -> Optional[Expense]:
		"""
		Get a specific expense for a user.
		
		Args:
			user_id: ID of the user
			expense_id: ID of the expense
		
		Returns:
			Expense if found, None otherwise
		"""
		user_expenses = self._user_expenses.get(user_id, [])
		for e in user_expenses:
			if e.id == expense_id:
				return e
		return None


# Global store instance
store = InMemoryExpenseStore()

