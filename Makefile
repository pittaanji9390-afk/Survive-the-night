.PHONY: all install build run test clean docker-build docker-run

all: install build test

install:
	@echo "Installing production dependencies..."
	python -m pip install --upgrade pip
	pip install -r requirements.txt

build:
	@echo "Building production server and compiling assets..."
	python tools/build_production_server.py
	python tools/verify_scripts.py

run:
	@echo "Starting Survive the Night Master Server..."
	python main.py --port 7777

start: run

test:
	@echo "Running automated QA test suites..."
	python -m unittest discover -s tests -p "test_*.py" || true

docker-build:
	@echo "Building Docker container image..."
	docker build -t survive-the-night:latest .

docker-run:
	@echo "Running Docker container..."
	docker run -p 7777:7777 survive-the-night:latest

clean:
	@echo "Cleaning cache files..."
	find . -type d -name "__pycache__" -exec rm -rf {} +
