from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.controllers import classify, expenses, stats, auth
from app.services.classifier import get_classifier
from dotenv import load_dotenv

load_dotenv()

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
app.include_router(auth.router)  # Authentication routes (register, login)
app.include_router(classify.router)  # Public classification endpoint
app.include_router(expenses.router)  # Protected expense routes
app.include_router(stats.router)  # Protected stats routes


@app.get("/health")
def health() -> dict:
	return {"status": "ok"}


