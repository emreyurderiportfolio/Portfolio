# Vehicle Positioning and Demand Prediction Using Deep Learning

## Project Description

This project focuses on predicting high-demand regions for vehicle positioning based on historical demand data and time-based features. Various deep learning models, including fully connected neural networks and advanced models like Transformers, were tested to identify optimal strategies. The project leverages the attention mechanism to improve prediction accuracy by focusing on critical features such as lag values and cyclic time-based patterns.

## Key Features

- **Custom Deep Learning Model:** A tailored structure incorporating an Attention layer to capture demand patterns effectively.
- **Transformer Model Comparison:** Evaluation of Transformers against custom models in terms of precision and computational efficiency.
- **Demand Prediction:** Probabilities of high demand in specific grids for the following hours are aligned with historical data trends.
- **Time-Based Features:** Utilizes cyclic time features and lagged demand values to enhance prediction accuracy.

## Dataset Overview
A mock dataset was created to demonstrate the approaches and methods used in the actual project due to an NDA agreement. Mock dataset contains the following data types
- Coordinates (latitude-longitude)
- Date and time information
- Drive time and distance

## Project Workflow

1. **Data Preparation:**
   - Historical demand data is preprocessed to include lag values and cyclic time-based features.
   - Grids are identified and categorized based on their historical demand.

2. **Model Development:**
   - **Fully Connected Neural Networks:** Basic models are implemented as benchmarks.
   - **Attention Mechanism:** Integrated into custom models to prioritize high-demand grids.
   - **Transformers:** Utilized for advanced prediction tasks, focusing on multi-head attention.

3. **Model Comparison:**
   - Precision scores and computational costs of different models are compared.
   - The impact of the attention mechanism on prediction alignment is analyzed.

4. **Evaluation:**
   - Performance metrics include precision, recall, and computational efficiency.
   - Predicted probabilities are assessed for alignment with historical demands.

## Technologies Used

- **Python:** Core programming language.
- **Deep Learning Frameworks:** TensorFlow for model development.
- **Attention Mechanisms:** Custom Attention layers and Transformers.
- **Data Visualization:** Matplotlib and Seaborn for data visualization. Cartopy and Folium for map visuzalization and interactive maps.

## Key Findings

- **Attention Mechanism:** Plays a significant role in predicting realistic probabilities aligned with historical events.
- **Transformer Limitations:** While performing comparably to custom models, Transformers incurred higher computational costs and slightly lower precision scores.
- **Custom Model Efficiency:** Outperformed Transformers in precision and computat
