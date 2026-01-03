# Ghost Path Mechanic Design Document

**Game:** cityBoy2d
**Version:** 1.0
**Date:** 2026-01-03
**Status:** Design Phase

---

## Core Concept

A visual feedback system where the player's previous runs create "ghost paths" that influence the game's visual presentation. Walking with your routine (the average of previous paths) rewards you with rich, saturated visuals but narrows your field of view. Deviating from routine drains color but expands your vision—creating a constant trade-off between comfort and awareness.

### Emotional Goal
**Routine is comfortable but numbing. Breaking it is uncomfortable but clarifying.**

---

## The Mechanic: Two Visual Layers

### Layer 1: Saturation (Color Drain)
- **On the Ghost Path (proximity = 1.0):** World is fully saturated, warm, cinematic
- **Off the Ghost Path (proximity = 0.0):** World drains to monochrome, stark, exposed
- **Transition:** Continuous interpolation based on distance from ghost cluster

### Layer 2: Vignette (Tunnel Vision)
- **On the Ghost Path:** Heavy vignette—peripheral vision darkens, creating tunnel vision
- **Off the Ghost Path:** Vignette fades—full field of view opens, you see everything
- **The Paradox:** Full color but limited vision vs. full vision but no color

---

## Integration with Existing Systems

### TimeManager Integration

The intensity of both effects scales with time of day, creating an emotional arc through each run.

#### Saturation Scaling by Time of Day

```gdscript
# Time progress (0.0 = MORNING, 1.0 = NIGHT)
var time_progress: float = TimeManager.get_time_progress()

# Off-path saturation floor drops as day progresses
var min_saturation = lerp(0.6, 0.0, time_progress)
var max_saturation = 1.0

# Apply based on proximity to ghost path
var actual_saturation = lerp(min_saturation, max_saturation, proximity)
```

| Time Period | On-Path | Off-Path | Emotional Feel |
|-------------|---------|----------|----------------|
| MORNING     | 1.0     | 0.6      | Gentle introduction, deviation feels curious |
| MIDMORNING  | 1.0     | 0.5      | Routine forming, deviation noticeable |
| NOON        | 1.0     | 0.4      | Grind sets in, color loss significant |
| AFTERNOON   | 1.0     | 0.3      | Tired, world fading outside routine |
| EVENING     | 1.0     | 0.2      | Melancholic, routine is safety |
| NIGHT       | 1.0     | 0.0      | Oppressive, path is all that has color |

#### Vignette Scaling by Time of Day

```gdscript
# On-path vignette ceiling rises as day progresses
var min_vignette = 0.0
var max_vignette = lerp(0.3, 0.9, time_progress)

# Apply based on proximity (inverted from saturation)
var actual_vignette = lerp(min_vignette, max_vignette, proximity)
```

| Time Period | On-Path | Off-Path | Visual Effect |
|-------------|---------|----------|---------------|
| MORNING     | 0.3     | 0.0      | Light tunnel, easy to see around |
| MIDMORNING  | 0.4     | 0.0      | Tunnel forming |
| NOON        | 0.5     | 0.0      | Noticeable peripheral darkening |
| AFTERNOON   | 0.6     | 0.0      | Significant tunnel vision |
| EVENING     | 0.7     | 0.0      | Heavy tunnel, edges very dark |
| NIGHT       | 0.9     | 0.0      | Severe tunnel, only path visible |

### SkyColorManager Integration

- The ghost path mechanic operates **on top of** existing sky color transitions
- Base palette comes from time-of-day (SkyColorManager handles this)
- Saturation effect modulates the final rendered output via post-process shader
- Color Beacons can use colors from specific time periods to create time-locked rewards

---

## Technical Implementation

### 1. Ghost Path Recording System

**New Singleton:** `GhostPathManager` (autoload)

```gdscript
# singletons/ghost_path_manager_singleton.gd
extends Node

signal ghost_proximity_changed(proximity: float)

# Recording
var current_run_path: PackedVector2Array = []
var recording_enabled: bool = true
var record_interval_pixels: float = 50.0  # Record every 50 pixels moved
var last_recorded_position: Vector2 = Vector2.ZERO

# Stored paths from previous runs
var ghost_paths: Array[PackedVector2Array] = []
var max_ghost_paths: int = 5  # Keep last 5 runs

# Current proximity to ghost cluster
var current_proximity: float = 1.0

func record_position(pos: Vector2) -> void:
    if not recording_enabled:
        return
    if current_run_path.is_empty() or pos.distance_to(last_recorded_position) >= record_interval_pixels:
        current_run_path.append(pos)
        last_recorded_position = pos

func end_run() -> void:
    # Save current path to ghost collection
    if current_run_path.size() > 0:
        ghost_paths.append(current_run_path.duplicate())
        if ghost_paths.size() > max_ghost_paths:
            ghost_paths.pop_front()

    # Save to disk via SaveManager
    SaveManager.save_ghost_paths(ghost_paths)
    current_run_path.clear()

func calculate_proximity(player_pos: Vector2) -> float:
    if ghost_paths.is_empty():
        return 1.0  # No ghosts = full saturation initially

    # Find average Y position of all ghost paths at current X position
    var relevant_points: Array[Vector2] = []
    var search_radius: float = 100.0  # X-axis tolerance

    for ghost_path in ghost_paths:
        for point in ghost_path:
            if abs(point.x - player_pos.x) < search_radius:
                relevant_points.append(point)

    if relevant_points.is_empty():
        return 0.0  # No ghost data here = full deviation

    # Calculate average position
    var avg_pos: Vector2 = Vector2.ZERO
    for point in relevant_points:
        avg_pos += point
    avg_pos /= relevant_points.size()

    # Calculate proximity (0.0 = far, 1.0 = on path)
    var distance: float = player_pos.distance_to(avg_pos)
    var max_deviation: float = 200.0  # Tunable parameter
    var proximity: float = clamp(1.0 - (distance / max_deviation), 0.0, 1.0)

    if proximity != current_proximity:
        current_proximity = proximity
        ghost_proximity_changed.emit(proximity)

    return proximity
```

### 2. Visual Effects System

**New Node:** `VisualEffectsManager` (scene instance, not singleton)

**Scene Structure:**
```
VisualEffectsManager (CanvasLayer, layer = 100)
├─ ColorRect (covers full screen)
│  └─ Material: ShaderMaterial (ghost_path_effects.gdshader)
└─ ColorBeaconsLayer (CanvasLayer, layer = 101)
```

**Shader:** `shaders/ghost_path_effects.gdshader`

```glsl
shader_type canvas_item;

uniform float saturation : hint_range(0.0, 1.0) = 1.0;
uniform float vignette_strength : hint_range(0.0, 1.0) = 0.0;
uniform float vignette_radius : hint_range(0.0, 1.0) = 0.5;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
    vec4 color = texture(SCREEN_TEXTURE, SCREEN_UV);

    // Saturation adjustment
    float gray = dot(color.rgb, vec3(0.299, 0.587, 0.114));
    color.rgb = mix(vec3(gray), color.rgb, saturation);

    // Vignette effect
    vec2 uv = SCREEN_UV - 0.5;
    float dist = length(uv);
    float vignette = smoothstep(vignette_radius, vignette_radius - 0.3, dist);
    color.rgb *= mix(1.0, vignette, vignette_strength);

    COLOR = color;
}
```

**Script:** `visual_effects_manager.gd`

```gdscript
extends CanvasLayer

@onready var color_rect: ColorRect = $ColorRect
var shader_material: ShaderMaterial

func _ready() -> void:
    shader_material = color_rect.material as ShaderMaterial
    GhostPathManager.ghost_proximity_changed.connect(_on_proximity_changed)
    TimeManager.time_of_day_changed.connect(_on_time_changed)

func _on_proximity_changed(proximity: float) -> void:
    var time_progress: float = TimeManager.get_time_progress()

    # Calculate saturation
    var min_sat: float = lerp(0.6, 0.0, time_progress)
    var saturation: float = lerp(min_sat, 1.0, proximity)

    # Calculate vignette (inverted)
    var max_vig: float = lerp(0.3, 0.9, time_progress)
    var vignette: float = lerp(0.0, max_vig, proximity)

    shader_material.set_shader_parameter("saturation", saturation)
    shader_material.set_shader_parameter("vignette_strength", vignette)

func _on_time_changed(new_time: TimeManager.TimeOfDay) -> void:
    # Recalculate with new time context
    _on_proximity_changed(GhostPathManager.current_proximity)
```

### 3. Ghost Visual Playback

**New Scene:** `ghost_sprite.tscn`

```
GhostSprite (Node2D)
└─ AnimatedSprite2D
   - Modulate: Color(1, 1, 1, 0.3)  # 30% opacity
   - Material: CanvasItemMaterial (blend_mode = Add)
```

**Script:** `ghost_sprite.gd`

```gdscript
extends Node2D

var ghost_path: PackedVector2Array = []
var path_index: int = 0
var playback_speed: float = 1.0
var time_offset: float = 0.0  # Stagger ghosts

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func initialize(path: PackedVector2Array, offset: float = 0.0) -> void:
    ghost_path = path
    time_offset = offset

func _process(delta: float) -> void:
    if ghost_path.is_empty():
        return

    # Advance along path
    var progress: float = (Time.get_ticks_msec() / 1000.0 + time_offset) * playback_speed
    path_index = int(progress) % ghost_path.size()

    global_position = ghost_path[path_index]

    # Mirror sprite based on direction of movement
    if path_index > 0:
        var direction: float = ghost_path[path_index].x - ghost_path[path_index - 1].x
        sprite.flip_h = direction < 0
```

### 4. Color Beacon System

**New Scene:** `color_beacon.tscn`

```
ColorBeacon (Node2D)
├─ Sprite2D
│  - Modulate: (beacon color - full saturation)
│  - Material: CanvasItemMaterial (blend_mode = Mix, light_mode = Normal)
└─ Area2D (optional for discovery tracking)
```

**Script:** `color_beacon.gd`

```gdscript
extends Node2D

@export var beacon_color: Color = Color.RED
@export var time_of_day_requirement: TimeManager.TimeOfDay = TimeManager.TimeOfDay.MORNING
@export var allow_all_times: bool = false

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
    sprite.modulate = beacon_color
    TimeManager.time_of_day_changed.connect(_on_time_changed)
    _update_visibility()

func _on_time_changed(new_time: TimeManager.TimeOfDay) -> void:
    _update_visibility()

func _update_visibility() -> void:
    if allow_all_times:
        visible = true
    else:
        visible = TimeManager.current_time_of_day == time_of_day_requirement
```

**Placement:** Beacons are placed on a separate CanvasLayer (layer 101) that renders **above** the post-process shader, so they retain full color even when the world is desaturated.

### 5. SaveManager Integration

Add to `SaveManager.save_game()`:

```gdscript
save_data["ghost_paths"] = GhostPathManager.ghost_paths
```

Add to `SaveManager.load_game()`:

```gdscript
if save_data.has("ghost_paths"):
    GhostPathManager.ghost_paths = save_data["ghost_paths"]
```

### 6. Player Integration

Modify `player.gd`:

```gdscript
func _physics_process(delta: float) -> void:
    # Existing movement code...

    # Record position for ghost path
    GhostPathManager.record_position(global_position)

    # Update proximity calculation
    GhostPathManager.calculate_proximity(global_position)
```

### 7. Optional: Audio Filter

**New Bus:** "Ambient" (if not already present)

**Effect:** AudioEffectHighPassFilter

```gdscript
# In AudioManager or VisualEffectsManager
func _on_proximity_changed(proximity: float) -> void:
    var bus_idx: int = AudioServer.get_bus_index("Ambient")
    var effect: AudioEffectHighPassFilter = AudioServer.get_bus_effect(bus_idx, 0)

    # Low proximity = thin sound (high pass)
    # High proximity = full sound (low pass)
    effect.cutoff_hz = lerp(2000.0, 20.0, proximity)
```

---

## Level Setup Requirements

### Every Level Scene Must Include:

1. **VisualEffectsManager** instance (as child of level or autoloaded globally)
2. **ColorBeaconsLayer** (CanvasLayer, layer 101) for beacon placement
3. **GhostContainer** (Node2D) where ghost sprites will be spawned
4. Existing: TimeManager connection (already handled by `base_level.gd`)

### BaseLevel Extension:

```gdscript
# Add to base_level.gd
@onready var ghost_container: Node2D = $GhostContainer

func _ready() -> void:
    # Existing code...

    # Spawn ghost sprites for each recorded path
    _spawn_ghosts()

func _spawn_ghosts() -> void:
    # Clear existing ghosts
    for child in ghost_container.get_children():
        child.queue_free()

    # Spawn new ghosts from stored paths
    var ghost_scene = preload("res://ghost_sprite.tscn")
    for i in range(GhostPathManager.ghost_paths.size()):
        var ghost_instance = ghost_scene.instantiate()
        ghost_instance.initialize(GhostPathManager.ghost_paths[i], i * 0.1)
        ghost_container.add_child(ghost_instance)

func _exit_tree() -> void:
    # Existing code...
    GhostPathManager.end_run()  # Save current run when leaving level
```

---

## Implementation Phases

### Phase 1: Core Loop (Minimum Viable)
- [ ] Create `GhostPathManager` singleton
- [ ] Implement path recording in `player.gd`
- [ ] Create basic proximity calculation
- [ ] Build saturation shader
- [ ] Build vignette shader
- [ ] Create `VisualEffectsManager` scene
- [ ] Test in Level1.tscn with manual ghost paths

**Goal:** See color drain and vignette respond to distance from a single ghost path.

### Phase 2: Ghost Playback & Polish
- [ ] Create `ghost_sprite.tscn` and script
- [ ] Implement multi-ghost spawning in `base_level.gd`
- [ ] Add SaveManager integration for path persistence
- [ ] Tune proximity falloff curves (test linear vs. ease-in-out)
- [ ] Integrate TimeManager scaling for saturation/vignette intensity

**Goal:** Multiple ghost runs persist across sessions and affect visual intensity.

### Phase 3: Color Beacons & Content
- [ ] Create `color_beacon.tscn` scene template
- [ ] Build ColorBeaconsLayer rendering setup
- [ ] Place 5-10 beacons in Level1 with different time-of-day requirements
- [ ] Add beacon discovery tracking (optional)
- [ ] Create time-locked beacon variants (morning café, evening couple, night neon)

**Goal:** Meaningful rewards for deviation that vary by time of day.

### Phase 4: Advanced Features (Optional)
- [ ] Audio high-pass filter on "Ambient" bus
- [ ] Ghost overlap glow intensification
- [ ] Vignette inversion (ghosts only visible in tunnel)
- [ ] Color bleed halos around beacons
- [ ] Accumulating vignette across runs

**Goal:** Enhanced sensory feedback and replay depth.

---

## Tunable Parameters

| Parameter | Default | Purpose | Location |
|-----------|---------|---------|----------|
| `record_interval_pixels` | 50.0 | How often to record player position | GhostPathManager |
| `max_ghost_paths` | 5 | Number of previous runs to keep | GhostPathManager |
| `max_deviation` | 200.0 | Distance for full color drain (pixels) | GhostPathManager |
| `morning_min_saturation` | 0.6 | Off-path saturation floor at morning | VisualEffectsManager |
| `night_min_saturation` | 0.0 | Off-path saturation floor at night | VisualEffectsManager |
| `morning_max_vignette` | 0.3 | On-path vignette strength at morning | VisualEffectsManager |
| `night_max_vignette` | 0.9 | On-path vignette strength at night | VisualEffectsManager |
| `vignette_radius` | 0.5 | Size of vignette circle | Shader |
| `ghost_opacity` | 0.3 | Transparency of ghost sprites | GhostSprite |
| `ghost_playback_speed` | 1.0 | Speed of ghost path replay | GhostSprite |

---

## Creative Variations to Explore Later

### The Afterimage
When stepping off the path, ghosts leave a brief color afterimage before fading—a reminder of what you're leaving behind.

### The Echo Zone
Specific level pockets where deviation triggers **inverted saturation** (hyper-color burst). Like finding a memory.

### The Accumulating Vignette
Each run increases base vignette strength slightly. By run 5, tunnel vision is severe even at start. Training into compliance.

### The Ghost Overlap
When multiple ghosts occupy the same position (identical paths), their glow intensifies. Well-worn routine shines brighter.

### The Color Bleed
Beacons emit a subtle color halo into surrounding grayscale, creating visual "warmth zones."

---

## Success Criteria

This mechanic is successful if:

1. **Players understand the system without a tutorial** (learns through escalation from morning → night)
2. **Players feel the emotional trade-off** (comfort vs. awareness is visceral, not intellectual)
3. **Deviation feels meaningful** (color beacons provide visual goals worth pursuing)
4. **The system integrates seamlessly** with existing time-of-day and level progression
5. **Replayability emerges naturally** (different paths at different times reveal different beacons)

---

## Technical Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Ghost path file size grows large | Save/load slowdown | Implement path compression (store deltas, subsample) |
| Proximity calculation is expensive | Frame rate drops | Cache calculations, only update every N frames |
| Vignette feels disorienting | Player frustration | Make morning vignette very subtle, ramp slowly |
| Shader doesn't work on all platforms | Visual bugs | Test on target platforms early, provide fallback |
| Ghost sprites clutter the screen | Visual noise | Limit visible ghost count, fade distant ghosts |

---

## References

**Related Systems:**
- [TimeManager](../singletons/time_manager_singleton.gd) - Time of day progression
- [SkyColorManager](../sky_color_manager.gd) - Base palette per time period
- [SaveManager](../singletons/save_manager_singleton.gd) - Persistence layer
- [BaseLevel](../base_level.gd) - Level initialization pattern

**Related Design Docs:**
- [Anti-Platformer Blog Outline](../blog_outline_anti_platformer.md) - Conceptual foundation

**Assets Needed:**
- Ghost sprite sheet (transparent player silhouette)
- Color beacon sprites (door, streetlight, plant, mailbox, window)
- Ambient city soundscape (for audio filter, optional)

---

**End of Document**
