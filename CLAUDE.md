# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Godot 4.5 2D platformer game called "cityBoy2d" featuring a cyberpunk/urban aesthetic. The project uses a hybrid GDScript and C# architecture with a singleton-based system for managing core game functionality.

## Development Commands

**Running the Game:**
- Open the project in Godot Editor and press F5, or use the "Play" button
- Main scene: `res://Level1.tscn`
- No build system - Godot handles compilation internally
- Assets are automatically imported by Godot Engine

## Architecture Overview

### Singleton System (Autoloads)

The game uses six autoloaded singletons that manage core functionality:

**DeveloperMode** (`developer_mode.gd`)
- Global developer tools and debugging system
- Runtime controls for time progression, sky colors, and time of day
- Hotkey system: F12 (toggle), T (cycle time), P (pause time), C (color mode), 1-6 (specific times)

**GameManager** (`singletons/game_manager_singleton.gd`)
- Central game state controller
- Manages pause functionality via `game_paused` signal
- Maintains player data (health, items, coins, experience, checkpoint positions)
- Stores game settings (developer_mode, volumes)
- Always processed (PROCESS_MODE_ALWAYS) to handle pause input

**LevelManager** (`singletons/level_manager_singleton.gd`)
- Scene transition system with fade effects
- Maintains current level state and level completion tracking
- Spawn point positioning system via `spawn_points` group
- Emits signals: `level_transition_started`, `level_transition_completed`, `level_loaded`
- Prevents concurrent transitions with `is_transitioning` flag

**TimeManager** (`singletons/time_manager_singleton.gd`)
- Day/night cycle with 6 time periods: MORNING, MIDMORNING, NOON, AFTERNOON, EVENING, NIGHT
- Configurable time progression speed and period duration
- Emits `time_of_day_changed` signal for color transitions
- Can be controlled by DeveloperMode for debugging

**AudioManager** (`singletons/audio_manager_singleton.gd`)
- Three audio buses: Music, SFX, Ambient
- Music/SFX library system with fade transitions
- Volume controls and enable/disable toggles
- Creates temporary AudioStreamPlayers for overlapping sound effects

**SaveManager** (`singletons/save_manager_singleton.gd`)
- JSON-based save system with 3 save slots
- Auto-save functionality (5 minute interval by default)
- Saves all singleton state: player data, level progress, time state, audio settings
- Save location: `user://savegame_[0-2].save`

### Level System Architecture

**BaseLevel Pattern** (`base_level.gd`)
- Common base script for all level scenes
- Connects to singleton signals on `_ready()`
- Handles spawn point positioning from GameManager player data
- Manages pause menu visibility via GameManager signals
- Links TimeManager to SkyColorManager for dynamic sky colors
- Properly disconnects signals on `_exit_tree()`

**Level Transitions** (`level_transition.gd`)
- Area2D-based trigger system
- Properties: `next_level_scene` (String), `spawn_point` (String), `transition_delay` (float)
- Calls `LevelManager.transition_to_level()` with spawn point ID
- Prevents re-triggering with `is_transitioning` flag

**Spawn Points** (`spawn_point.gd`)
- SpawnPoint class extends Marker2D
- Properties: `spawn_id`, `spawn_direction`, `is_checkpoint`
- Added to `spawn_points` group for LevelManager lookup
- Checkpoint activation saves position to GameManager
- Editor-only visual indicators (green for default, yellow for named)

### Character System

**Player** (`player.gd`)
- CharacterBody2D with state machine: IDLE, WALK, JUMP_UP, JUMP_DOWN, ATTACK
- Physics-based movement with configurable gravity, acceleration, friction
- Ground detection raycast for platform snapping
- Animation system tied to movement states
- Direction-based sprite flipping

**Reusable Components** (`Recipies/` folder)
- `BasicMovingCharacter2D.gd` - Base class for AI characters with physics
- `InteractiveArea2D.gd` - Area2D interaction system with signals
- `BumptingEnemy2D.gd` - Enemy collision behavior component

**NPC System** (`npc_001.gd`)
- Extends BasicMovingCharacter2D base class
- State machine with WALK/IDLE states
- Uses InteractiveArea2D for player interaction
- Direction-based collision adjustment

### Visual Systems

**Sky Color Manager** (`sky_color_manager.gd`)
- Dynamic sky color transitions based on TimeManager
- Smooth color interpolation with configurable duration
- Responds to `time_of_day_changed` signal
- Can be manually controlled via DeveloperMode

**Parallax Backgrounds** (`parallax.tscn`, `parallax2.tscn`)
- Time-of-day specific city backgrounds
- Integrated with overall aesthetic

### Input Configuration

**Movement:**
- `left` - Left Arrow
- `right` - Right Arrow / D key
- `jump` / `space` - Spacebar
- `e_key` - E key (interactions)
- `pause` - Escape key

**Developer Mode (when active):**
- `F12` - Toggle developer mode
- `T` - Cycle through time of day
- `P` - Toggle time progression pause
- `C` - Toggle manual/automatic color mode
- `1-6` - Set specific time of day directly

### Physics Configuration

- CharacterBody2D-based movement system
- Layer 2: "Pass Through Layer" for one-way platforms
- Ground detection raycast for improved platform snapping
- Configurable physics parameters in player script

## Important Patterns

**Singleton Communication:**
- Prefer signals over direct method calls
- All singletons emit signals for state changes
- Connect to singleton signals in level `_ready()`, disconnect in `_exit_tree()`

**Level Scene Setup:**
- Extend or reference `base_level.gd` for common functionality
- Include PauseMenu, Player, and SkyColorManager nodes
- Ensure spawn points are in `spawn_points` group with unique IDs

**Data Persistence:**
- Player state is saved to GameManager via `save_player_data()`
- LevelManager tracks level completion independently
- SaveManager serializes all singleton state to JSON

**Dual Language Architecture:**
- GDScript for game logic and singleton systems
- C# for specific components (LevelManager.cs for editor scene management)
- C# assembly name: "t2"

## Development Notes

- Resolution: 2400x1600
- VSync: Adaptive (mode 2)
- Rendering: Forward Plus
- No FPS limit (Engine.max_fps = 0)
- Godot 4.5 with .NET 8.0 support
