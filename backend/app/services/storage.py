from typing import List, Optional
from ..models.schemas import Expense, ExpenseCreate


class InMemoryExpenseStore:
	def __init__(self) -> None:
		self._items: List[Expense] = []
		self._next_id: int = 1

	def add(self, payload: ExpenseCreate, category: str, probability: float) -> Expense:
		expense = Expense(
			id=self._next_id,
			description=payload.description,
			amount=payload.amount,
			date=payload.date,
			category=category,
			probability=probability,
		)
		self._items.append(expense)
		self._next_id += 1
		return expense

	def list(self) -> List[Expense]:
		return list(self._items)

	def get(self, expense_id: int) -> Optional[Expense]:
		for e in self._items:
			if e.id == expense_id:
				return e
		return None


# Global store instance
store = InMemoryExpenseStore()

