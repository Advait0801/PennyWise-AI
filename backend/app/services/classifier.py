from typing import List, Tuple
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.linear_model import LogisticRegression
from sklearn.pipeline import Pipeline
import re


class ExpenseClassifier:
	"""
	ML classifier for expense categorization using TF-IDF + Logistic Regression.
	Trains on seed data at initialization.
	"""
	
	# Expense categories
	CATEGORIES = [
		"Food",
		"Travel",
		"Shopping",
		"Rent",
		"Utilities",
		"Entertainment",
		"Healthcare",
		"Transportation",
		"Other"
	]
	
	def __init__(self):
		"""Initialize and train the classifier with seed data."""
		self.pipeline = Pipeline([
			('tfidf', TfidfVectorizer(
				max_features=1000,
				ngram_range=(1, 2),
				stop_words='english',
				lowercase=True
			)),
			('classifier', LogisticRegression(
				max_iter=1000,
				random_state=42
			))
		])
		
		# Load training data from seed data
		training_texts, training_labels = self._get_seed_data()
		self.pipeline.fit(training_texts, training_labels)
	
	def _get_seed_data(self) -> Tuple[List[str], List[str]]:
		"""Generate seed training data for each category."""
		seed_data = {
			"Food": [
				"lunch at restaurant",
				"groceries from supermarket",
				"coffee shop",
				"dinner with friends",
				"pizza delivery",
				"breakfast",
				"fast food",
				"grocery shopping",
				"restaurant bill",
				"food delivery",
				"dining out",
				"takeout food",
				"cafe",
				"bakery",
				"food store",
				"supermarket",
				"grocery store",
				"restaurant",
				"lunch",
				"dinner",
				"snacks",
				"food purchase",
				"eating out",
				"food order",
				"meal",
				"food items",
				"grocery",
				"food shopping",
				"restaurant meal",
				"food delivery service"
			],
			"Travel": [
				"hotel booking",
				"flight ticket",
				"train fare",
				"taxi ride",
				"airport parking",
				"vacation rental",
				"travel insurance",
				"car rental",
				"bus ticket",
				"hotel stay",
				"airplane ticket",
				"hotel room",
				"lodging",
				"accommodation",
				"flight",
				"airfare",
				"train ticket",
				"travel expenses",
				"vacation",
				"trip",
				"hotel reservation",
				"airport",
				"travel booking",
				"resort",
				"hostel",
				"travel cost",
				"journey",
				"travel fare"
			],
			"Shopping": [
				"clothing purchase",
				"electronics store",
				"online shopping",
				"department store",
				"shoes",
				"gadgets",
				"apparel",
				"retail store",
				"amazon purchase",
				"mall shopping",
				"clothes",
				"clothing",
				"shopping",
				"retail purchase",
				"store purchase",
				"buying clothes",
				"electronics",
				"shopping mall",
				"retail",
				"purchase",
				"buying",
				"store",
				"shopping trip",
				"retail shopping",
				"online purchase",
				"ecommerce",
				"shopping spree"
			],
			"Rent": [
				"monthly rent",
				"apartment rent",
				"house rent",
				"rental payment",
				"lease payment",
				"rent payment",
				"housing rent",
				"apartment payment",
				"rental",
				"lease",
				"housing payment",
				"monthly rental",
				"apartment lease",
				"house payment",
				"rental fee",
				"housing cost"
			],
			"Utilities": [
				"electricity bill",
				"water bill",
				"gas bill",
				"internet bill",
				"phone bill",
				"utility payment",
				"cable tv",
				"internet service",
				"electric bill",
				"power bill",
				"utility bill",
				"phone service",
				"internet",
				"cable",
				"utilities",
				"electric",
				"water",
				"gas utility",
				"internet provider",
				"phone service bill",
				"utility",
				"electricity",
				"utility service"
			],
			"Entertainment": [
				"movie tickets",
				"concert",
				"streaming service",
				"netflix subscription",
				"spotify premium",
				"theater show",
				"gaming subscription",
				"watching film",
				"watching movie",
				"cinema",
				"movie",
				"film",
				"theater",
				"movie theater",
				"cinema ticket",
				"movie ticket",
				"film ticket",
				"watching films",
				"watching movies",
				"going to movies",
				"going to cinema",
				"movie night",
				"film screening",
				"entertainment",
				"streaming",
				"music subscription",
				"gaming",
				"video games",
				"concert ticket",
				"show ticket",
				"theater ticket",
				"entertainment subscription",
				"music service",
				"video streaming",
				"entertainment service"
			],
			"Healthcare": [
				"doctor visit",
				"pharmacy",
				"medicine",
				"hospital bill",
				"dental checkup",
				"prescription",
				"medical insurance",
				"doctor",
				"hospital",
				"medical",
				"healthcare",
				"pharmacy purchase",
				"medication",
				"drugs",
				"medical bill",
				"health insurance",
				"dental",
				"doctor appointment",
				"medical visit",
				"health checkup",
				"medical care",
				"healthcare service"
			],
			"Transportation": [
				"gas station",
				"fuel",
				"uber ride",
				"lyft",
				"parking fee",
				"toll",
				"metro card",
				"public transport",
				"gas",
				"petrol",
				"ride share",
				"taxi",
				"cab",
				"parking",
				"parking ticket",
				"transit",
				"public transportation",
				"bus",
				"subway",
				"metro",
				"transport",
				"transportation",
				"fuel cost",
				"gas cost",
				"ride",
				"commute"
			],
			"Other": [
				"miscellaneous",
				"general expense",
				"unknown",
				"other purchase",
				"other",
				"misc",
				"general",
				"unclassified",
				"other expense",
				"misc expense"
			]
		}
		
		texts = []
		labels = []
		for category, examples in seed_data.items():
			texts.extend(examples)
			labels.extend([category] * len(examples))
		
		return texts, labels
	
	def predict(self, description: str) -> Tuple[str, float, List[str]]:
		"""
		Predict category for expense description.
		
		Args:
			description: Expense description text
		
		Returns:
			Tuple of (predicted_category, probability, top_3_categories)
		"""
		# Clean and normalize input
		cleaned = self._clean_text(description)
		
		# Predict
		predicted_category = self.pipeline.predict([cleaned])[0]
		probabilities = self.pipeline.predict_proba([cleaned])[0]
		
		# Get probability for predicted category
		category_idx = self.CATEGORIES.index(predicted_category)
		probability = float(probabilities[category_idx])
		
		# Get top 3 categories
		top_indices = probabilities.argsort()[-3:][::-1]
		top_classes = [self.CATEGORIES[idx] for idx in top_indices]
		
		return predicted_category, probability, top_classes
	
	def _clean_text(self, text: str) -> str:
		"""Clean and normalize input text."""
		# Lowercase
		text = text.lower()
		# Remove extra whitespace
		text = re.sub(r'\s+', ' ', text)
		# Strip
		text = text.strip()
		return text


# Global classifier instance (initialized at startup)
classifier = None


def get_classifier() -> ExpenseClassifier:
	"""Get or initialize the global classifier instance."""
	global classifier
	if classifier is None:
		classifier = ExpenseClassifier()
	return classifier

