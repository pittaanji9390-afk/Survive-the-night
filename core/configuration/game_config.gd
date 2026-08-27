class_name GameConfiguration
extends Node

# Global Game Configuration and Constants
const GAME_TITLE: String = "Survive the Night"
const VERSION: String = "0.1.0"

# World Grid Configuration
const TILE_SIZE: int = 32
const CHUNK_SIZE: int = 16 # 16x16 tiles per chunk

# Player Defaults
const DEFAULT_PLAYER_SPEED: float = 120.0
const SPRINT_SPEED_MULTIPLIER: float = 1.65
const SPRINT_STAMINA_DRAIN_PER_SEC: float = 20.0
const STAMINA_REGEN_PER_SEC: float = 15.0
const STAMINA_REGEN_DELAY: float = 1.25

# Time Configuration
const SECONDS_PER_GAME_DAY: float = 480.0 # 8 real-time minutes per full 24h game day
const DEFAULT_START_HOUR: float = 8.0 # Starts at 8:00 AM

# Logging
const LOG_LEVEL_DEBUG: int = 0
const LOG_LEVEL_INFO: int = 1
const LOG_LEVEL_WARN: int = 2
const LOG_LEVEL_ERROR: int = 3
var current_log_level: int = LOG_LEVEL_DEBUG
