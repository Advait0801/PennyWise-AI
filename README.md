# 💰 PennyWise AI

<div align="center">

**An intelligent expense tracking iOS application powered by machine learning and modern full-stack architecture**

[![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org)
[![Python](https://img.shields.io/badge/Python-3.13-blue.svg)](https://www.python.org)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.115-green.svg)](https://fastapi.tiangolo.com)
[![MongoDB](https://img.shields.io/badge/MongoDB-Atlas-brightgreen.svg)](https://www.mongodb.com)
[![iOS](https://img.shields.io/badge/iOS-17.0+-lightgrey.svg)](https://developer.apple.com/ios)

</div>

---

## 📱 Overview

**PennyWise AI** is a full-stack expense tracking application that leverages Natural Language Processing (NLP) to automatically categorize expenses. Built with SwiftUI for iOS and FastAPI for the backend, it provides an intuitive interface for users to log expenses, view spending analytics, and gain insights into their financial habits through intelligent categorization.

### Key Highlights

- 🤖 **AI-Powered Classification**: Automatically categorizes expenses using TF-IDF vectorization and Logistic Regression
- 🔐 **Secure Authentication**: JWT-based authentication with bcrypt password hashing
- 📊 **Real-time Analytics**: Interactive charts and statistics powered by Swift Charts
- ☁️ **Cloud Database**: MongoDB Atlas integration for scalable data persistence
- 🎨 **Modern UI/UX**: Clean, responsive SwiftUI interface with dynamic sizing
- ✅ **Input Validation**: Comprehensive client-side validation with visual feedback
- 🔄 **CRUD Operations**: Full Create, Read, Update, Delete functionality for expenses

---

## ✨ Features

### Core Functionality
- **Smart Expense Classification**: Enter a description and get instant category predictions (Food, Travel, Shopping, Entertainment, Bills, Healthcare, Education, Other)
- **Confidence Scoring**: View prediction confidence percentages for transparency
- **Expense Management**: 
  - Add expenses with description, amount, and optional date
  - Edit existing expenses with automatic re-classification
  - Delete expenses with swipe gestures or dedicated button
- **User Authentication**: Secure registration and login with JWT tokens
- **Persistent Storage**: All data stored in MongoDB Atlas cloud database

### Analytics & Visualization
- **Category Statistics**: View total spending per category with count breakdowns
- **Interactive Charts**: Swift Charts integration for visual spending analysis
- **Total Spending Summary**: Real-time calculation of total expenses
- **Date-based Filtering**: Track expenses by custom dates

### User Experience
- **Input Validation**: Real-time validation with visual feedback (red borders, error messages)
- **Responsive Design**: Dynamic sizing that adapts to different screen sizes
- **Loading States**: Optimistic UI updates with proper state management
- **Error Handling**: Comprehensive error messages and alerts
- **Keyboard Management**: Automatic keyboard dismissal on form submission

---

## 🏗️ Architecture

### System Architecture

```
┌─────────────────┐         ┌──────────────────┐         ┌─────────────────┐
│   iOS Client    │◄───────►│   FastAPI Backend│◄───────►│  MongoDB Atlas  │
│   (SwiftUI)     │  REST   │   (Python)       │  Async  │   (Cloud DB)    │
└─────────────────┘         └──────────────────┘         └─────────────────┘
      │                              │
      │                              │
      ▼                              ▼
┌─────────────┐              ┌──────────────┐
│  JWT Token  │              │  ML Model    │
│  Storage    │              │(scikit-learn)│
└─────────────┘              └──────────────┘
```

### Frontend Architecture (iOS - MVC Pattern)

```
PennyWise AI/
├── Models/              # Data models (Expense, Category, Auth)
├── Views/               # SwiftUI views (declarative, render-only)
│   ├── AuthScreen.swift
│   ├── MainScreen.swift
│   ├── AddExpenseView.swift
│   └── EditExpenseView.swift
├── Controllers/         # Business logic & state management
│   ├── AuthController.swift
│   └── ExpenseController.swift
├── Services/            # API communication layer
│   └── APIService.swift
└── Utilities/           # Helper extensions & utilities
    ├── Colors.swift
    └── ViewExtensions.swift
```

### Backend Architecture (FastAPI - MVC-ish Pattern)

```
backend/
├── app/
│   ├── main.py              # FastAPI app & CORS configuration
│   ├── database.py          # MongoDB connection management
│   ├── dependencies.py      # Dependency injection (auth, DB)
│   ├── controllers/         # API endpoints (routers)
│   │   ├── auth.py          # Authentication routes
│   │   ├── classify.py      # Classification endpoint
│   │   ├── expenses.py      # CRUD operations
│   │   └── stats.py         # Statistics aggregation
│   ├── models/              # Pydantic schemas
│   │   └── schemas.py       # Request/Response models
│   └── services/            # Business logic layer
│       ├── auth.py          # JWT & password hashing
│       ├── classifier.py    # ML model (TF-IDF + Logistic Regression)
│       ├── storage.py       # Expense database operations
│       ├── user_storage.py  # User database operations
│       └── stats.py         # Statistics calculation
└── requirements.txt
```

---

## 🛠️ Tech Stack

### Frontend (iOS)
- **Language**: Swift 5.9+
- **Framework**: SwiftUI
- **Charts**: Swift Charts
- **Architecture**: MVC (Model-View-Controller)
- **Networking**: URLSession with async/await
- **Minimum iOS**: 17.0+

### Backend (Python)
- **Framework**: FastAPI 0.115.2
- **ASGI Server**: Uvicorn
- **Database**: MongoDB Atlas (via Motor async driver)
- **Authentication**: JWT (python-jose) + bcrypt
- **ML Library**: scikit-learn 1.5.2
- **Data Processing**: NumPy 2.1.1
- **Python Version**: 3.13+

### Machine Learning
- **Model**: Logistic Regression
- **Feature Extraction**: TF-IDF Vectorization
- **Categories**: Food, Travel, Shopping, Entertainment, Bills, Healthcare, Education, Other
- **Training**: Pre-trained model loaded at startup

---

## 🎯 Key Features Implementation

### Machine Learning Classification
- **Model**: Pre-trained Logistic Regression classifier
- **Features**: TF-IDF vectorization of expense descriptions
- **Categories**: 8 predefined categories with confidence scores
- **Performance**: Fast inference (< 50ms per prediction)

### Authentication & Security
- **Password Hashing**: bcrypt with salt rounds
- **Token Management**: JWT tokens with expiration
- **Secure Storage**: Tokens stored in UserDefaults (iOS)
- **CORS**: Configured for iOS simulator and devices

### Data Persistence
- **Database**: MongoDB Atlas (cloud-hosted)
- **Collections**: `users`, `expenses`
- **Indexes**: Optimized for username, email, user_id, date, category queries
- **Async Operations**: All database operations are asynchronous

---

## 🔒 Security Features

- ✅ Password hashing with bcrypt
- ✅ JWT token-based authentication
- ✅ Secure API endpoints with dependency injection
- ✅ Input validation on both client and server
- ✅ CORS configuration for authorized origins
- ✅ Environment variables for sensitive data

---

## 🚧 Future Enhancements

- [ ] Receipt scanning with OCR integration
- [ ] Budget tracking and alerts
- [ ] Export expenses to CSV/PDF
- [ ] Multi-currency support
- [ ] Recurring expense management
- [ ] Advanced analytics and insights
- [ ] Dark mode optimization
- [ ] Widget support for quick expense entry
- [ ] Apple Watch companion app

---

<div align="center">

**Built with ❤️ using Swift, Python, and Machine Learning**

⭐ Star this repo if you find it helpful!

</div>
