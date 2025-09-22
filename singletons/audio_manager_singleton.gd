extends Node

signal music_changed(new_music: String)
signal sound_effect_played(sound_name: String)

var background_music: AudioStreamPlayer
var sound_effects: AudioStreamPlayer
var ambient_sound: AudioStreamPlayer

var current_music: String = ""
var music_volume: float = 1.0
var sfx_volume: float = 1.0
var ambient_volume: float = 0.5

var is_music_enabled: bool = true
var is_sfx_enabled: bool = true
var is_ambient_enabled: bool = true

# Music library - can be expanded with actual audio resources
var music_library = {
	"main_theme": null,
	"level_music": null,
	"boss_music": null,
	"menu_music": null
}

var sfx_library = {
	"jump": null,
	"land": null,
	"coin": null,
	"hurt": null,
	"interact": null
}

func _ready():
	add_to_group("audio_manager")
	_setup_audio_players()

func _setup_audio_players():
	# Background music player
	background_music = AudioStreamPlayer.new()
	background_music.bus = "Music"
	background_music.volume_db = linear_to_db(music_volume)
	add_child(background_music)

	# Sound effects player
	sound_effects = AudioStreamPlayer.new()
	sound_effects.bus = "SFX"
	sound_effects.volume_db = linear_to_db(sfx_volume)
	add_child(sound_effects)

	# Ambient sound player
	ambient_sound = AudioStreamPlayer.new()
	ambient_sound.bus = "Ambient"
	ambient_sound.volume_db = linear_to_db(ambient_volume)
	ambient_sound.autoplay = false
	add_child(ambient_sound)

# Music management
func play_music(music_name: String, fade_in: bool = true):
	if not is_music_enabled:
		return

	if current_music == music_name and background_music.playing:
		return

	var music_resource = music_library.get(music_name, null)
	if not music_resource:
		print("Music not found: ", music_name)
		return

	if fade_in and background_music.playing:
		await fade_out_music()

	background_music.stream = music_resource
	current_music = music_name

	if fade_in:
		background_music.volume_db = -80
		background_music.play()
		fade_in_music()
	else:
		background_music.play()

	music_changed.emit(music_name)

func fade_out_music(duration: float = 1.0):
	if not background_music.playing:
		return

	var tween = get_tree().create_tween()
	tween.tween_method(_set_music_volume_db, background_music.volume_db, -80, duration)
	await tween.finished
	background_music.stop()

func fade_in_music(duration: float = 1.0):
	if not background_music.playing:
		return

	var target_volume = linear_to_db(music_volume)
	var tween = get_tree().create_tween()
	tween.tween_method(_set_music_volume_db, -80, target_volume, duration)

func _set_music_volume_db(volume_db: float):
	background_music.volume_db = volume_db

func stop_music(fade_out: bool = true):
	if fade_out:
		await fade_out_music()
	else:
		background_music.stop()
	current_music = ""

func pause_music():
	background_music.stream_paused = true

func resume_music():
	background_music.stream_paused = false

# Sound effects management
func play_sound_effect(sound_name: String, volume_multiplier: float = 1.0):
	if not is_sfx_enabled:
		return

	var sound_resource = sfx_library.get(sound_name, null)
	if not sound_resource:
		print("Sound effect not found: ", sound_name)
		return

	# Create a temporary AudioStreamPlayer for this sound effect
	var temp_player = AudioStreamPlayer.new()
	temp_player.bus = "SFX"
	temp_player.stream = sound_resource
	temp_player.volume_db = linear_to_db(sfx_volume * volume_multiplier)
	add_child(temp_player)

	temp_player.play()
	sound_effect_played.emit(sound_name)

	# Remove the player when sound finishes
	temp_player.finished.connect(_on_temp_sound_finished.bind(temp_player))

func _on_temp_sound_finished(player: AudioStreamPlayer):
	player.queue_free()

# Ambient sound management
func play_ambient_sound(sound_resource: AudioStream, loop: bool = true):
	if not is_ambient_enabled:
		return

	ambient_sound.stream = sound_resource
	if loop and sound_resource.has_method("set_loop"):
		sound_resource.set_loop(true)
	ambient_sound.play()

func stop_ambient_sound(fade_out: bool = true):
	if fade_out:
		var tween = get_tree().create_tween()
		tween.tween_property(ambient_sound, "volume_db", -80, 1.0)
		await tween.finished

	ambient_sound.stop()
	ambient_sound.volume_db = linear_to_db(ambient_volume)

# Volume controls
func set_music_volume(volume: float):
	music_volume = clamp(volume, 0.0, 1.0)
	background_music.volume_db = linear_to_db(music_volume) if music_volume > 0 else -80

func set_sfx_volume(volume: float):
	sfx_volume = clamp(volume, 0.0, 1.0)
	sound_effects.volume_db = linear_to_db(sfx_volume) if sfx_volume > 0 else -80

func set_ambient_volume(volume: float):
	ambient_volume = clamp(volume, 0.0, 1.0)
	ambient_sound.volume_db = linear_to_db(ambient_volume) if ambient_volume > 0 else -80

func get_music_volume() -> float:
	return music_volume

func get_sfx_volume() -> float:
	return sfx_volume

func get_ambient_volume() -> float:
	return ambient_volume

# Enable/disable controls
func set_music_enabled(enabled: bool):
	is_music_enabled = enabled
	if not enabled:
		stop_music(false)

func set_sfx_enabled(enabled: bool):
	is_sfx_enabled = enabled

func set_ambient_enabled(enabled: bool):
	is_ambient_enabled = enabled
	if not enabled:
		stop_ambient_sound(false)

# Library management
func register_music(name: String, resource: AudioStream):
	music_library[name] = resource

func register_sound_effect(name: String, resource: AudioStream):
	sfx_library[name] = resource

func get_current_music() -> String:
	return current_music

func is_music_playing() -> bool:
	return background_music.playing