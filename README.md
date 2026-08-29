# Survive the Night

A complete, modular, commercial-grade 2D top-down survival, base-building, and simulation game built with **Godot 4.3** & **GDScript**, accompanied by an authoritative **Python Master Game Server & Simulation Engine** with 63,000+ lines of production code.

---

## Features Overview

- **Modular Core Architecture**: Decoupled `EventBus`, `GameStateManager`, `TimeManager` day/night cycle, and `ServiceLocator`.
- **Authoritative Game Server**: 50 modular server subsystems (`server/`) handling ECS physics, A* pathfinding, behavior trees, market order books, fluid cellular automata, and telemetry.
- **Base Construction & Power Grids**: Grid-based building (walls, doors, chests, spike traps, turrets) with real-time wattage generation, battery storage, and conveyor automation.
- **13 Boss Encounters & 10 Legendary Guardians**: Multi-phase metamorphoses, enrage thresholds, and telegraph animations.
- **6 Integrated Arcade Mini-Games**: Bullet heaven horde survivor, grid tower defense, roguelike card deckbuilder, deep sea fishing simulator, subterranean excavator, and space shooter.
- **Multiplayer & Level Editor**: ENet client-server synchronization, snapshot interpolation, and in-game scenario editor.

---

## Dependencies

The project requires the following runtimes and packages:

- **Python**: `>= 3.10`
- **Godot Engine**: `4.3 Stable`
- **Node.js**: `>= 18.0` (Optional for npm scripts)
- **Docker**: (Optional for container deployment)

### Python Core Dependencies
- `fastapi >= 0.109.0`
- `uvicorn >= 0.27.0`
- `websockets >= 12.0`
- `pydantic >= 2.6.0`
- `numpy >= 1.26.0`
- `cryptography >= 42.0.0`

---

## Installation

### 1. Python Environment Setup
```bash
# Clone repository
git clone https://github.com/pittaanji9390-afk/Survive-the-night.git
cd Survive-the-night

# Create virtual environment
python -m venv venv

# Activate virtual environment
# Windows:
.\venv\Scripts\activate
# Linux/macOS:
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt
```

### 2. Node & Package Dependencies
```bash
# Install node dependencies
npm install
```

---

## Build

### Building Server & Simulation Pipelines
```bash
# Build server architecture and verify script assets
python tools/build_production_server.py
python tools/verify_scripts.py

# Or use Makefile
make build

# Or use npm
npm run build
```

### Building Docker Container
```bash
# Build Docker image
docker build -t survive-the-night:latest .

# Or using Makefile
make docker-build
```

---

## Run

### Starting the Master Game Server & Simulation Host
```bash
# Run server entry point
python main.py --port 7777 --ticks 60

# Or run via app alias
python app.py

# Or using Makefile
make run

# Or using npm
npm start
```

### Running with Docker
```bash
docker run -p 7777:7777 -p 8000:8000 survive-the-night:latest
```

### Launching Godot Game Client
```bash
# Windows
& "C:\Users\anjin\godot_engine\Godot_v4.3-stable_win64.exe" --path "C:\Users\anjin\Survive the night"

# Headless Test Runner
& "C:\Users\anjin\godot_engine\Godot_v4.3-stable_win64_console.exe" --headless --path . scenes/tests/test_runner.tscn --quit-after 50
```

---

## Usage

### 1. Game Controls
- **W, A, S, D / Arrow Keys**: 8-Direction Player Movement
- **Left Mouse Click**: Attack / Gather Resource / Harvest Plot
- **Right Mouse Click**: Place Selected Building / Structure Ghost
- **Keys [1] – [8]**: Quick-select Hotbar Slots
- **[E] / [I]**: Toggle 24-Slot Inventory & Equipment Screen
- **[C]**: Open Crafting Matrix & Batch Queue
- **[T]**: Tech Tree & Research DAG Progression
- **[B]**: Base Building Menu
- **[ESC]**: Pause Menu & Audio / Video Settings

### 2. Market & Stock Exchange
- Access the in-game Trading Post or call `MarketExchangeManager.buy_commodity(&"wheat", 10)` to invest in commodity futures and profit from dynamic price swings.

---

## License
MIT License. Created for production and commercial deployment.
