#!/bin/bash
echo "Running all tests with coverage..."
pytest --cov=src --cov-report=term-missing --cov-report=html --cov-fail-under=30

