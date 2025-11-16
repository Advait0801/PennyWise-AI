from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.controllers import classify, expenses, stats, auth
from app.services.classifier import get_classifier
from app.database import get_client, get_database, close_database
import os
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


# Initialize database and classifier at startup
@app.on_event("startup")
async def startup_event():
	"""Initialize the database and ML classifier on app startup."""
	# Initialize MongoDB connection
	try:
		client = get_client()
		# Test connection
		await client.admin.command('ping')
		print("✅ MongoDB connection established successfully.")
		
		# Create indexes for better query performance
		db = get_database()
		await db.users.create_index("username", unique=True)
		await db.users.create_index("email", unique=True)
		await db.expenses.create_index("user_id")
		await db.expenses.create_index("date")
		await db.expenses.create_index("category")
		print("✅ Database indexes created/verified.")
	except Exception as e:
		print(f"⚠️  Warning: Could not connect to MongoDB: {e}")
		print("   For MongoDB Atlas: Check your connection string in .env file")
		print("   For Local MongoDB: brew services start mongodb-community (macOS)")
		print("   Connection URL:", os.getenv("MONGODB_URL", "mongodb://localhost:27017"))
	
	# Initialize classifier
	print("Initializing expense classifier...")
	classifier = get_classifier()
	print(f"Classifier ready! Supports {len(classifier.CATEGORIES)} categories.")


# Close database connection on shutdown
@app.on_event("shutdown")
async def shutdown_event():
	"""Close database connections on app shutdown."""
	await close_database()
	print("Database connections closed.")


# Include routers
app.include_router(auth.router)  # Authentication routes (register, login)
app.include_router(classify.router)  # Public classification endpoint
app.include_router(expenses.router)  # Protected expense routes
app.include_router(stats.router)  # Protected stats routes


@app.get("/health")
def health() -> dict:
	return {"status": "ok"}


