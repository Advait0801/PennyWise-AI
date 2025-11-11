from fastapi import FastAPI

app = FastAPI(title="Smart Expense Classifier API", version="0.1.0")


@app.get("/health")
def health() -> dict:
	return {"status": "ok"}


