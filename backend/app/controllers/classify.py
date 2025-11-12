from fastapi import APIRouter, HTTPException
from app.models.schemas import ClassifyRequest, ClassifyResponse
from app.services.classifier import get_classifier

router = APIRouter(prefix="/classify", tags=["classification"])


@router.post("", response_model=ClassifyResponse)
async def classify_expense(request: ClassifyRequest):
	"""
	Classify an expense description into a category.
	
	Returns the predicted category, confidence probability, and top 3 categories.
	"""
	try:
		classifier = get_classifier()
		category, probability, top_classes = classifier.predict(request.description)
		
		return ClassifyResponse(
			category=category,
			probability=probability,
			top_classes=top_classes
		)
	except Exception as e:
		raise HTTPException(status_code=500, detail=f"Classification error: {str(e)}")

