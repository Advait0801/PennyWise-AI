from collections import defaultdict
from typing import List
from ..models.schemas import Expense, CategoryStat


def aggregate_by_category(expenses: List[Expense]) -> List[CategoryStat]:
	totals = defaultdict(lambda: {"amount": 0.0, "count": 0})
	for e in expenses:
		totals[e.category]["amount"] += e.amount
		totals[e.category]["count"] += 1
	stats = [
		CategoryStat(category=cat, total_amount=vals["amount"], count=vals["count"])
		for cat, vals in totals.items()
	]
	return sorted(stats, key=lambda s: s.total_amount, reverse=True)


