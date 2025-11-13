from fastapi import APIRouter, HTTPException, Depends
from app.models.schemas import CategoryStatsResponse, User
from app.services.storage import store
from app.services.stats import aggregate_by_category
from app.dependencies import get_current_user

router = APIRouter(prefix="/stats", tags=["statistics"])


@router.get("/category", response_model=CategoryStatsResponse)
async def get_category_stats(current_user: User = Depends(get_current_user)):
	"""
	Get spending statistics grouped by category for the current user.
	Requires authentication.
	
	Returns total amount and count for each category, sorted by total amount (descending).
	"""
	try:
		expenses = store.list(current_user.id)
		stats = aggregate_by_category(expenses)
		return CategoryStatsResponse(stats=stats)
	except Exception as e:
		raise HTTPException(status_code=500, detail=f"Error retrieving stats: {str(e)}")

