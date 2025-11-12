from fastapi import APIRouter, HTTPException
from app.models.schemas import CategoryStatsResponse
from app.services.storage import store
from app.services.stats import aggregate_by_category

router = APIRouter(prefix="/stats", tags=["statistics"])


@router.get("/category", response_model=CategoryStatsResponse)
async def get_category_stats():
	"""
	Get spending statistics grouped by category.
	
	Returns total amount and count for each category, sorted by total amount (descending).
	"""
	try:
		expenses = store.list()
		stats = aggregate_by_category(expenses)
		return CategoryStatsResponse(stats=stats)
	except Exception as e:
		raise HTTPException(status_code=500, detail=f"Error retrieving stats: {str(e)}")

