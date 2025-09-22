# Level System Architecture Plan

## Overview

This document outlines the plan for implementing persistent game systems across levels in the cityBoy2d Godot project.

## Current Issues Analysis

The current level system has several limitations:

### Isolated Systems Per Level
- **Game Manager**: Currently in `game.tscn` but not accessible in individual levels
- **Pause System**: Each level has its own PauseMenu with no centralized management
- **Time Management**: TimeManager needs to persist across levels to maintain time of day
- **Developer Mode**: Should be available in all levels consistently
- **Player Data**: Health, items, progress should carry over between levels
- **Sky Color Management**: Should maintain time of day state across transitions
- **Audio/Music**: Should continue seamlessly during level changes
- **Save/Load System**: No persistent game state management

### Current Architecture Problems
- Duplicate systems in each level scene
- No data persistence between level transitions
- Inconsistent pause behavior
- Time of day resets with each level
- No global game state management

## Recommended Solution: Autoload Singletons

### Approach 1: Autoload Singletons (Recommended)

Create autoload singletons for persistent systems that exist above the scene tree and persist throughout the entire game session.

#### Benefits of Autoload Approach:
- ✅ True persistence across all scenes
- ✅ Clean separation of concerns
- ✅ Easy to access from any script (`GameManager.pause_game()`)
- ✅ Maintains current level-based architecture
- ✅ Scales well for larger games
- ✅ Standard Godot pattern for global systems

## Implementation Plan

### Phase 1: Core Autoloads

#### 1. Create GameManager Autoload
```gdscript
# game_manager_singleton.gd
extends Node

signal game_paused(is_paused: bool)
signal player_health_changed(new_health: int)

var is_game_paused: bool = false
var player_data = {
	"health": 100,
	"max_health": 100,
	"items": [],
	"current_level": "Level1",
	"checkpoint_position": Vector2.ZERO
}

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

func pause_game():
	is_game_paused = !is_game_paused
	get_tree().paused = is_game_paused
	game_paused.emit(is_game_paused)

func save_player_data(data: Dictionary):
	player_data.merge(data)

func get_player_data() -> Dictionary:
	return player_data
```

#### 2. Create LevelManager Autoload
```gdscript
# level_manager_singleton.gd
extends Node

signal level_transition_started(from_level: String, to_level: String)
signal level_transition_completed(level_name: String)

var current_level: String = ""
var level_completion_data = {}
var available_levels = ["Level1", "Level2"]

func transition_to_level(level_path: String, spawn_point: String = "default"):
	level_transition_started.emit(current_level, level_path)

	# Store player data before transition
	var player = get_tree().get_first_node_in_group("player")
	if player:
		GameManager.save_player_data({
			"checkpoint_position": player.global_position,
			"current_level": current_level
		})

	# Transition with fade effect
	await create_fade_transition()
	get_tree().change_scene_to_file(level_path)
	current_level = level_path

	level_transition_completed.emit(level_path)

func create_fade_transition():
	# Fade implementation
	pass
```

#### 3. Convert TimeManager to Autoload
Move existing `time_manager.gd` to autoload and enhance:

```gdscript
# time_manager_singleton.gd
extends Node

signal time_changed(current_time: TimeOfDay)
signal day_night_cycle_complete()

enum TimeOfDay { MORNING, MIDMORNING, NOON, AFTERNOON, EVENING, NIGHT }

var current_time: TimeOfDay = TimeOfDay.EVENING
var time_progression_enabled: bool = true
var time_speed: float = 1.0

func _ready():
	add_to_group("time_manager")

# Existing time management code...
```

#### 4. Create AudioManager Autoload
```gdscript
# audio_manager_singleton.gd
extends Node

var background_music: AudioStreamPlayer
var sound_effects: AudioStreamPlayer

func _ready():
	background_music = AudioStreamPlayer.new()
	sound_effects = AudioStreamPlayer.new()
	add_child(background_music)
	add_child(sound_effects)

func play_level_music(music_resource: AudioStream):
	if background_music.stream != music_resource:
		background_music.stream = music_resource
		background_music.play()

func play_sound_effect(sound: AudioStream):
	sound_effects.stream = sound
	sound_effects.play()
```

### Phase 2: Enhanced Level Transition

#### Update level_transition.gd
```gdscript
extends Area2D

@export var next_level_scene: String = ""
@export var spawn_point: String = "default"

func _ready():
	body_entered.connect(_on_player_entered)

func _on_player_entered(body):
	if body.name == "Player":
		# Use LevelManager for transition
		LevelManager.transition_to_level(next_level_scene, spawn_point)
```

#### Spawn Point System
```gdscript
# spawn_point.gd
extends Marker2D
class_name SpawnPoint

@export var spawn_id: String = "default"

func _ready():
	add_to_group("spawn_points")
```

### Phase 3: Global Systems

#### Global Pause System
- Remove individual pause menus from levels
- Create global pause overlay managed by GameManager
- Consistent pause behavior across all scenes

#### Persistent Audio Management
- Background music continues through level transitions
- Environmental audio changes based on level
- Sound effect management

#### Save/Load System
```gdscript
# save_manager_singleton.gd
extends Node

const SAVE_FILE = "user://savegame.save"

func save_game():
	var save_file = FileAccess.open(SAVE_FILE, FileAccess.WRITE)
	var save_data = {
		"player_data": GameManager.get_player_data(),
		"level_completion": LevelManager.level_completion_data,
		"current_time": TimeManager.current_time,
		"settings": {}
	}
	save_file.store_string(JSON.stringify(save_data))
	save_file.close()

func load_game():
	if not FileAccess.file_exists(SAVE_FILE):
		return false

	var save_file = FileAccess.open(SAVE_FILE, FileAccess.READ)
	var json_string = save_file.get_as_text()
	save_file.close()

	var save_data = JSON.parse_string(json_string)

	GameManager.player_data = save_data.player_data
	LevelManager.level_completion_data = save_data.level_completion
	TimeManager.current_time = save_data.current_time

	return true
```

### Phase 4: Level System Enhancements

#### Level Completion Tracking
- Track which levels have been completed
- Store completion times and scores
- Unlock progression system

#### Level Selection System
- Create level hub or menu system
- Show completion status
- Allow replay of completed levels

#### Checkpoint System
- Save points within levels
- Respawn at checkpoints on death
- Progress preservation

## Project.godot Autoload Configuration

Add to `project.godot`:

```ini
[autoload]

DeveloperMode="*res://developer_mode.gd"
GameManager="*res://singletons/game_manager_singleton.gd"
LevelManager="*res://singletons/level_manager_singleton.gd"
TimeManager="*res://singletons/time_manager_singleton.gd"
AudioManager="*res://singletons/audio_manager_singleton.gd"
SaveManager="*res://singletons/save_manager_singleton.gd"
```

## File Structure

```
cityBoy2d/
├── singletons/
│   ├── game_manager_singleton.gd
│   ├── level_manager_singleton.gd
│   ├── time_manager_singleton.gd
│   ├── audio_manager_singleton.gd
│   └── save_manager_singleton.gd
├── levels/
│   ├── BaseLevel.tscn
│   ├── Level1.tscn
│   ├── Level2.tscn
│   └── ...
├── ui/
│   ├── GlobalPauseMenu.tscn
│   ├── LevelSelectMenu.tscn
│   └── ...
└── ...
```

## Migration Strategy

1. **Create singleton folder and scripts**
2. **Update project.godot autoload settings**
3. **Test basic autoload functionality**
4. **Migrate TimeManager to autoload**
5. **Update level scenes to use global systems**
6. **Implement enhanced level transitions**
7. **Test persistence across level changes**
8. **Add save/load functionality**

## Alternative Approach: Persistent Scene Architecture

If autoloads don't meet your needs, consider:

- Keep main scene that never unloads
- Load level content as children
- Player and systems stay in main scene
- More complex but gives maximum control

## Conclusion

The autoload singleton approach provides a clean, scalable solution for persistent game systems while maintaining your current level-based architecture. This approach is standard in Godot and will give you professional-grade persistence and state management.

Each autoload singleton handles a specific concern:
- **GameManager**: Core game state and coordination
- **LevelManager**: Level progression and transitions
- **TimeManager**: Persistent time of day system
- **AudioManager**: Continuous audio experience
- **SaveManager**: Game state persistence

This architecture will scale well as your game grows and provides a solid foundation for advanced features like achievements, statistics tracking, and complex progression systems.
