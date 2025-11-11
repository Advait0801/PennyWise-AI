Smart Expense Classifier
========================

App Features
------------
- Smart categorization: Type or paste an expense description and the app auto-detects a category (Food, Travel, Rent, etc.) using an NLP model.
- Confidence insights: See the predicted category with confidence; optionally view top alternative categories.
- Expense logging: Save categorized expenses with amount and date.
- Trend visualization: Explore spending trends over time with Swift Charts, including category breakdowns.
- Quick health check: Built-in backend health endpoint ensures the app only interacts with a live API.
- Offline-friendly UX: Optimistic UI updates and clear error messages for intermittent connectivity.

Platforms
---------
- iOS app using SwiftUI and Swift Charts
- Python backend using FastAPI

Tech Highlights
---------------
- NLP: TF‑IDF + Logistic Regression for lightweight, fast categorization
- Clean architecture: MVC on iOS; controllers handle state and networking, views stay declarative
- Simple, extensible API design for easy iteration and deployment

User Flows
----------
- Add Expense: Enter description + amount (+ optional date) → receive predicted category → save.
- Browse History: View a list of saved expenses with categories and confidence.
- Analyze Spending: View charts of total spend per category and trends over time.

Future Enhancements
-------------------
- Persistent storage (SQLite/Postgres) and user accounts
- Model persistence and incremental training
- Attach receipts and enable OCR-based extraction
- Advanced analytics (budgets, alerts, recommendations)


