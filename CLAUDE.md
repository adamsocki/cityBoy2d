# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Godot 4.5 2D platformer game called "cityBoy2d" featuring a cyberpunk/urban aesthetic. The game includes a player character that can move, jump, and interact with NPCs in a city environment with parallax backgrounds. The project uses a hybrid GDScript and C# architecture.

## Development Commands

**Running the Game:**
- Open the project in Godot Editor and press F5, or use the "Play" button
- Main scene: `res://game.tscn`

**Project Structure:**
- No build system - Godot handles compilation internally
- Hybrid GDScript/C# project with .NET support
- No separate test framework identified in the codebase
- Assets are automatically imported by Godot Engine

## Code Architecture

### Core Systems

**Game Manager (`game_manager.gd`)**
- Main game controller that manages pause functionality and FPS monitoring
- Integrates with TimeManager for game time progression
- Handles pause menu visibility via Escape key

**Player System (`player.gd`)**
- CharacterBody2D-based player controller with state machine
- States: IDLE, WALK, JUMP_UP, JUMP_DOWN, ATTACK
- Physics-based movement with gravity, acceleration, friction
- Animation system tied to movement states
- Ground detection with raycast for improved platform behavior

**Time Management (`time_manager.gd`)**
- Tracks game time progression
- Supports time-of-day system (MORNING, MIDMORNING, NOON, AFTERNOON, EVENING, NIGHT)
- Currently set to EVENING by default

**NPC System (`npc_001.gd`)**
- AI-controlled characters using BasicMovingCharacter2D base class
- State machine with WALK/IDLE states
- Interaction system via InteractiveArea2D
- Direction-based sprite flipping and collision adjustment

**Level Management (`LevelManager.cs`)**
- C# component for managing scene visibility and transitions
- Controls Scene switching between different level nodes
- Exported properties for direct scene assignment in editor

**Sky Color Management (`sky_color_manager.gd`)**
- Manages dynamic sky color transitions based on time of day
- Smooth color interpolation with configurable transition duration
- Integrates with time management and developer mode systems

**Developer Mode (`developer_mode.gd`)**
- Autoload singleton for development tools and debugging
- Runtime controls for time progression, sky colors, and time of day
- On-screen debug UI with real-time game state information
- Hotkey system (F12 for dev mode, T/P/C/1-6 for various controls)

### Reusable Components (`Recipies/` folder)

**BasicMovingCharacter2D**
- Base class for moving characters with physics
- Configurable speed, direction, gravity, and jump strength

**InteractiveArea2D**
- Area2D-based interaction system
- Emits signals for interaction availability and completion
- Input handling for interaction actions

**BumptingEnemy2D**
- Enemy character component with collision-based behavior
- Part of the reusable character system architecture

### Scene Structure

- `game.tscn` - Main game scene
- `level_node1.tscn` - Level scene managed by LevelManager
- `player.tscn` - Player character prefab
- `npc_001.tscn` - NPC prefab
- `MainMenu.tscn` / `PauseMenu.tscn` - UI scenes
- `parallax.tscn` / `parallax2.tscn` - Parallax background scenes
- `LevelManager.tscn` - C# level management system
- Various platform and environment prefabs (elevator, closing_platform, light_platform, etc.)

### Input Configuration

**Defined input actions:**
- `left` - Left Arrow key movement
- `right` - Right Arrow / D key movement
- `jump` / `space` - Spacebar for jumping
- `pause` - Escape key for pause menu
- `e_key` - E key for interactions

**Developer Mode Controls:**
- `F12` - Toggle developer mode on/off
- `T` - Cycle through time of day (when dev mode active)
- `P` - Toggle time progression pause (when dev mode active)
- `C` - Toggle manual/automatic color mode (when dev mode active)
- `1-6` - Set specific time of day directly (when dev mode active)

### Art Assets

The project contains extensive pixel art assets organized in folders:
- Character sprites with animation frames (idle, walk, jump)
- Parallax city backgrounds for different times of day
- Tileset assets for level construction
- UI elements and environmental props

### Physics Configuration

- Uses Godot's CharacterBody2D for player movement
- Custom pass-through layer (layer 2) for one-way platforms
- Ground detection raycast for improved platform snapping
- Configurable physics parameters (gravity, acceleration, friction, jump velocity)

## Current Game Features

- 2D platformer movement with jump mechanics
- NPC interaction system
- Dynamic time of day progression system
- Sky color transitions based on time of day
- Developer mode with runtime debugging tools
- Level management and scene switching
- Pause functionality
- Parallax scrolling backgrounds
- Urban/cyberpunk aesthetic with pixel art
- Basic UI system
- Hybrid GDScript/C# architecture

## Development Notes

- Project is configured for 2400x1600 resolution
- VSync mode set to 2 (adaptive)
- Uses Forward Plus rendering
- No FPS limit set (Engine.max_fps = 0)
- DeveloperMode is set as an autoload singleton
- C# assembly name: "t2"
- Godot 4.5 with C# support enabled

## Autoloads

- `DeveloperMode` - Global developer tools and debugging system (`*res://developer_mode.gd`)