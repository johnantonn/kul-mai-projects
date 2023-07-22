# Artificial Neural Networks and Deep Learning
Application of various artificial neural network architectures and learning algorithms to different problems and datasets.

## Scope
This repository contains part of the source code that was used/developed in the context of the exercise sessions of the course **Artificial Neural Networks and Deep Learning** for the Master's in Artificial Intelligence, KU Leuven (2020-2021). 

***Note**: A comprehensive report showcasing the application of the various architectures and their insights/results is available upon request.*

## Description
The repository is comprised of the below subdirectories:
* **autoencoders**: digit classification using Stacked Autoencoder architectures
* **boltzmann**: digit reconstruction using Restricted Boltzmann Machines and Deep Boltzmann Machines
* **cnns**: digit classification and image category classification using Convolutional Neural Networks
* **feedforward**: function estimation and regression using feedforward neural networks
* **gans**: image generation using Generative Adversarial Networks
* **hopfield**: application of Hopfield networks to random point vectors
* **lstms**: time series prediction using LSTMs
* **optimal_transport**: image color adaptation using optimal transport algorithms
* **pca**: dimensionality reduction and image reconstruction using PCA

## Requirements
The Matlab script that deploys Stacked Autoencoder architectures requires the below:
* Neural Network Toolbox

In addition to that, the scripts that deploy CNN architectures also require the below:
* Parallel Computing Toolbox
* Statistics and Machine Learning Toolbox
* CUDA-capable GPU card

**Note**: Jupyter Notebooks can be executed in Google Colab.

## Disclaimer
Large parts of the provided source code were originally authored by teaching assistants or MathWorks.
