# Survive the Night

A modular, data-driven 2D top-down survival and base-building game built in **Godot 4.x** with **GDScript**.

## 🌲 Features (Milestone 1 — Foundation)
- **Modular Core Architecture**: Decoupled `EventBus`, `GameStateManager` finite state machine, `TimeManager` day/night cycle, and `ServiceLocator`.
- **Responsive Top-Down Player**: 8-direction movement, acceleration/friction smoothing, stamina-based sprinting with cooldown/exhaustion.
- **Data-Driven Stats**: Multi-attribute system (`StatAttribute`) supporting flat, additive percent, and multiplicative modifiers for Health, Stamina, Hunger, Speed, and Temperature.
- **Dynamic Camera**: Smooth follow camera with multi-directional trauma screen shake.
- **Day/Night System**: Real-time clock with daylight curve modulating ambient world lighting across Morning, Day, Sunset, and Night phases.
- **Playable World & UI**: Interactive monolith, collision boundaries, obstacles, real-time HUD with interpolated stat bars, pause menu, and `F3` debug telemetry.
- **Automated Test Suite**: Built-in unit tests verifying stat math, time rollover, and state transitions.

## 🕹️ Controls
| Action | Key / Input |
|---|---|
| **Move** | `W`, `A`, `S`, `D` or `Arrow Keys` |
| **Sprint** | Hold `Shift` |
| **Interact** | `E` |
| **Pause / Resume** | `Esc` |
| **Toggle Debug Overlay** | `F3` |

## 🚀 How to Run
Launch via Godot 4.x or through terminal:
```powershell
& "C:\Users\anjin\godot_engine\Godot_v4.3-stable_win64.exe" --path "C:\Users\anjin\Survive the night"
```

To run the automated test suite headlessly:
```powershell
& "C:\Users\anjin\godot_engine\Godot_v4.3-stable_win64_console.exe" --headless --path "C:\Users\anjin\Survive the night" scenes/tests/test_runner.tscn --quit-after 50
```

## 🗺️ Roadmap
- [x] **Milestone 1**: Foundation (Core Architecture, Player, Camera, World, HUD, Tests)
- [ ] **Milestone 2**: Resource System & Gathering
- [ ] **Milestone 3**: Crafting & Recipes
- [ ] **Milestone 4**: Building & Base Construction
- [ ] **Milestone 5**: Combat & Weapons
- [ ] **Milestone 6**: Day/Night & Lighting
- [ ] **Milestone 7**: AI & Enemy Waves
- [ ] **Milestone 8**: Survival & Status Effects
- [ ] **Milestone 9**: Procedural World & Biomes
- [ ] **Milestone 10**: Farming & NPCs
- [ ] **Milestone 11**: Quests & Progression
- [ ] **Milestone 12**: Bosses & Endgame
- [ ] **Milestone 13**: Save/Load & Settings
- [ ] **Milestone 14**: Audio, VFX & Polish
- [ ] **Milestone 15**: QA & Release
