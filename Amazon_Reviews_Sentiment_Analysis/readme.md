# Sentiment Analysis Using VADER and TextBlob

## Project Description

This project evaluates the performance of two popular natural language processing tools, **VADER** and **TextBlob**, for sentiment analysis. Using a dataset of textual reviews with ground truth sentiment labels, the project aims to classify sentiments as Positive, Neutral, or Negative and compare the strengths and weaknesses of both tools.

## Key Features

- **Sentiment Classification:** Classifies reviews as Positive, Neutral, or Negative.
- **Model Comparison:** Compares VADER and TextBlob using performance metrics.
- **Preprocessing Pipeline:** Implements text cleaning, tokenization, and outlier detection.
- **Evaluation Metrics:** Uses precision, recall, F1-score, and accuracy to evaluate performance.

## Dataset Overview

The dataset includes reviews with the following key columns:

| Column         | Description                                                                                  |
|-----------------|----------------------------------------------------------------------------------------------|
| `overall`      | Rating given by the reviewer.                                                               |
| `reviewText`   | Full text of the review.                                                                    |
| `reviewTime`   | Date when the review was posted.                                                            |
| `reviewerID`   | Unique identifier for the reviewer.                                                         |
| `asin`         | Amazon Standard Identification Number (unique product ID).                                  |
| `summary`      | Short summary of the review.                                                                |
| `vote`         | Number of helpful votes received.                                                           |
| `style`        | Metadata about the product.                                                                 |
| `image`        | Images posted by the reviewer after receiving the product.                                  |

## Project Workflow

1. **Data Exploration:**
   - Summarizes and visualizes data distribution.
   - Identifies potential issues like imbalanced data and outliers.

2. **Preprocessing:**
   - Removes punctuation and stop words.
   - Detects and handles outliers using external dictionaries of positive and negative words.

3. **Sentiment Analysis:**
   - Uses VADER and TextBlob to classify reviews based on their textual content.
   - Implements custom preprocessing steps tailored to each tool.

4. **Model Evaluation:**
   - Compares the performance of VADER and TextBlob using:
     - Precision
     - Recall
     - F1-Score
     - Accuracy
   - Analyzes misclassifications to highlight model biases.

5. **Visualization:**
   - Generates charts comparing the performance of VADER and TextBlob.
   - Creates confusion matrices to illustrate classification accuracy.

## Tools and Technologies

- **VADER (Valence Aware Dictionary and Sentiment Reasoner):** A rule-based sentiment analysis tool optimized for social media text.
- **TextBlob:** A general-purpose NLP library for sentiment analysis and text processing.
- **Python Libraries:** pandas, numpy, matplotlib, seaborn, nltk, scikit-learn.

## Key Findings

- **VADER:**
  - Strengths: High recall and F1-score, capturing more true positives.
  - Weaknesses: Slightly biased towards positive sentiment.

- **TextBlob:**
  - Strengths: Higher precision, better at avoiding false positives.
  - Weaknesses: More prone to mislabeling neutral reviews as positive.

## Usage

1. **Clone the Repository:**
   
   `git clone https://github.com/emreyurderiportfolio/Portfolio.git`

2. **Locate The Folder**
   
   `cd /Portfolio/Amazon_Reviews_Sentiment_Analysis`
   
3. **Install Dependencies**

    `pip install -r requirements.txt`

4. **Run The Notebook**
   
   Open and run Sentiment_Analysis.ipynb in a Jupyter Notebook environment.

5. **Analyze Results**

    Explore the charts and metrics generated in the notebook to compare the performance of VADER and TextBlob.

