from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.controllers import classify, expenses, stats
from app.services.classifier import get_classifier

app = FastAPI(title="Smart Expense Classifier API", version="0.1.0")

# Enable CORS for iOS simulator and device
app.add_middleware(
	CORSMiddleware,
	allow_origins=["*"],  # In production, specify exact origins
	allow_credentials=True,
	allow_methods=["*"],
	allow_headers=["*"],
)

# Initialize classifier at startup
@app.on_event("startup")
async def startup_event():
	"""Initialize the ML classifier on app startup."""
	print("Initializing expense classifier...")
	classifier = get_classifier()
	print(f"Classifier ready! Supports {len(classifier.CATEGORIES)} categories.")


# Include routers
app.include_router(classify.router)
app.include_router(expenses.router)
app.include_router(stats.router)


@app.get("/health")
def health() -> dict:
	return {"status": "ok"}


