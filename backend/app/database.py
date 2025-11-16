"""MongoDB database configuration and connection management."""
import os
from motor.motor_asyncio import AsyncIOMotorClient
from dotenv import load_dotenv

load_dotenv()

# Get MongoDB connection URL from environment variable
# Default to local MongoDB instance
MONGO_URL = os.getenv(
    "MONGODB_URL",
    "mongodb://localhost:27017"  # Default local MongoDB
)

# Database name
DATABASE_NAME = os.getenv("MONGODB_DATABASE", "expense_tracker")

# Create MongoDB client (singleton)
_client: AsyncIOMotorClient = None
_database = None


def get_client() -> AsyncIOMotorClient:
    """
    Get or create MongoDB client.
    Returns singleton AsyncIOMotorClient instance.
    """
    global _client
    if _client is None:
        _client = AsyncIOMotorClient(
            MONGO_URL,
            serverSelectionTimeoutMS=5000,  # 5 second timeout
        )
    return _client


def get_database():
    """
    Get database instance.
    Use this in FastAPI route dependencies.
    
    Example:
        @router.get("/items")
        async def get_items(db = Depends(get_database)):
            items = await db.items.find({}).to_list(length=100)
            return items
    """
    global _database
    if _database is None:
        client = get_client()
        _database = client[DATABASE_NAME]
    return _database


async def close_database():
    """Close database connection (call on app shutdown)."""
    global _client, _database
    if _client:
        _client.close()
        _client = None
        _database = None

