extends CharacterBody2D

# ============================================================================
# CONSTANTS
# ============================================================================

const FIRE_COOLDOWN_SECONDS: float = 0.16
const COYOTE_TIME_SECONDS: float = 0.12
const JUMP_BUFFER_SECONDS: float = 0.12
const JUMP_CUT_MULTIPLIER: float = 0.5
const PROJECTILE_SPAWN_OFFSET: Vector2 = Vector2(18.0, -20.0)
const LEVEL_UP_SELECTION_SCENE_PATH: String = "res://scenes/ui/level_up_selection.tscn"
const DAMAGE_UPGRADE_ID: StringName = &"damage_up"
const ATTACK_SPEED_UPGRADE_ID: StringName = &"attack_speed_up"
const MOVE_SPEED_UPGRADE_ID: StringName = &"move_speed_up"
const BASE_XP_TO_NEXT_LEVEL: int = 8
const XP_PER_LEVEL_STEP: int = 4
const DAMAGE_INVULNERABILITY_SECONDS: float = 0.70
const DAMAGE_FLASH_SECONDS: float = 0.12
const DEATH_FLASH_SECONDS: float = 0.18
const DEATH_RESTART_DELAY_SECONDS: float = 0.65
const INVULNERABILITY_BLINK_INTERVAL: float = 0.08
const LEVEL_UP_FLASH_SECONDS: float = 0.22
const LEVEL_UP_PULSE_SECONDS: float = 0.24
const CONTACT_KNOCKBACK_X: float = 180.0
const CONTACT_KNOCKBACK_Y: float = -180.0
const DEBUG_LABEL_OFFSET: Vector2 = Vector2(12.0, 12.0)
const NORMAL_TINT: Color = Color(1.0, 1.0, 1.0, 1.0)
const DAMAGE_TINT: Color = Color(1.0, 0.45, 0.45, 1.0)
const DAMAGE_FLASH_TINT: Color = Color(1.0, 0.88, 0.88, 1.0)
const INVULNERABLE_TINT: Color = Color(1.0, 0.55, 0.55, 1.0)
const DEATH_FLASH_TINT: Color = Color(1.0, 1.0, 1.0, 1.0)
const LEVEL_UP_TINT: Color = Color(1.0, 0.94, 0.45, 1.0)
const BASE_PROJECTILE_DAMAGE: int = 1

# ============================================================================
# EXPORTED VARIABLES
# ============================================================================

@export var move_speed: float = 220.0
@export var sprint_speed: float = 320.0
@export var acceleration: float = 1400.0
@export var friction: float = 1800.0
@export var jump_velocity: float = -420.0
@export var gravity: float = 1200.0
@export var max_health: int = 100
@export var damage_upgrade_amount: int = 1
@export var attack_speed_upgrade_multiplier: float = 0.88
@export var move_speed_upgrade_amount: float = 24.0

const INPUT_ACTIONS: Dictionary = {
	&"move_left": [KEY_A],
	&"move_right": [KEY_D],
	&"jump": [KEY_SPACE],
	&"sprint": [KEY_SHIFT],
	&"fire": [KEY_J]
}

# ============================================================================
# NODE REFERENCES
# ============================================================================

@onready var _sprite: Sprite2D = $Sprite2D
@onready var _collision_shape: CollisionShape2D = $CollisionShape2D

# ============================================================================
# RUNTIME VARIABLES
# ============================================================================

var _coyote_timer: float = 0.0
var _jump_buffer_timer: float = 0.0
var _jump_was_released: bool = false
var _health: int = 0
var _hurt_flash_timer: float = 0.0
var _invulnerability_timer: float = 0.0
var _invulnerability_blink_timer: float = 0.0
var _fire_cooldown_timer: float = 0.0
var _facing_direction: float = 1.0
var _death_flash_timer: float = 0.0
var _death_restart_timer: float = 0.0
var _is_dead: bool = false
var _current_level: int = 1
var _current_xp: int = 0
var _xp_to_next_level: int = BASE_XP_TO_NEXT_LEVEL
var _level_up_flash_timer: float = 0.0
var _level_up_pulse_timer: float = 0.0
var _pending_level_up_choices: int = 0
var _projectile_damage_bonus: int = 0
var _attack_speed_multiplier: float = 1.0
var _move_speed_bonus: float = 0.0
var _level_up_selection_ui: CanvasLayer = null
var _health_canvas_layer: CanvasLayer = null
var _health_label: Label = null

# ============================================================================
# GODOT LIFECYCLE
# ============================================================================

func _ready() -> void:
	_health = max_health
	_xp_to_next_level = _xp_required_for_level(_current_level)
	add_to_group("player")
	_ensure_input_map()
	_create_debug_health_display()
	_update_debug_health_display()

func _physics_process(delta: float) -> void:
	if _is_dead:
		_update_death_state(delta)
		_update_player_visuals()
		_update_debug_health_display()
		return

	_update_damage_timers(delta)
	_update_jump_timers(delta)
	_apply_horizontal_movement(delta)
	_apply_gravity(delta)
	_try_start_jump()
	_apply_variable_jump_height()
	_update_fire_cooldown(delta)
	_handle_fire_input()
	move_and_slide()
	_refresh_floor_state()
	_update_player_visuals()
	_update_debug_health_display()

# ============================================================================
# INPUT
# ============================================================================

func _update_jump_timers(delta: float) -> void:
	_jump_was_released = Input.is_action_just_released(&"jump")

	if Input.is_action_just_pressed(&"jump"):
		_jump_buffer_timer = JUMP_BUFFER_SECONDS
	else:
		_jump_buffer_timer = max(_jump_buffer_timer - delta, 0.0)

	if is_on_floor():
		_coyote_timer = COYOTE_TIME_SECONDS
	else:
		_coyote_timer = max(_coyote_timer - delta, 0.0)

func _update_fire_cooldown(delta: float) -> void:
	_fire_cooldown_timer = max(_fire_cooldown_timer - delta, 0.0)

func _handle_fire_input() -> void:
	if not Input.is_action_just_pressed(&"fire"):
		return

	if _fire_cooldown_timer > 0.0:
		return

	_spawn_projectile()
	_fire_cooldown_timer = _current_fire_cooldown_duration()

# ============================================================================
# MOVEMENT
# ============================================================================

func _apply_horizontal_movement(delta: float) -> void:
	var input_axis: float = Input.get_axis(&"move_left", &"move_right")
	var walk_speed: float = move_speed + _move_speed_bonus
	var sprint_move_speed: float = sprint_speed + _move_speed_bonus
	var max_speed: float = sprint_move_speed if Input.is_action_pressed(&"sprint") else walk_speed
	var target_velocity_x: float = input_axis * max_speed

	if not is_zero_approx(input_axis):
		_facing_direction = sign(input_axis)
		velocity.x = move_toward(velocity.x, target_velocity_x, acceleration * delta)
		return

	velocity.x = move_toward(velocity.x, 0.0, friction * delta)

func _apply_gravity(delta: float) -> void:
	if is_on_floor() and velocity.y > 0.0:
		velocity.y = 0.0
		return

	velocity.y += gravity * delta

func _try_start_jump() -> void:
	if _jump_buffer_timer <= 0.0:
		return

	if _coyote_timer <= 0.0:
		return

	velocity.y = jump_velocity
	_jump_buffer_timer = 0.0
	_coyote_timer = 0.0

func _apply_variable_jump_height() -> void:
	if not _jump_was_released:
		return

	if velocity.y >= 0.0:
		return

	velocity.y *= JUMP_CUT_MULTIPLIER

func _refresh_floor_state() -> void:
	if is_on_floor():
		_coyote_timer = COYOTE_TIME_SECONDS

func _spawn_projectile() -> void:
	var projectile: Projectile = Projectile.new()
	var spawn_root: Node = get_tree().current_scene
	var spawn_offset: Vector2 = Vector2(
		PROJECTILE_SPAWN_OFFSET.x * _facing_direction,
		PROJECTILE_SPAWN_OFFSET.y
	)

	if spawn_root.has_node("Gameplay"):
		spawn_root = spawn_root.get_node("Gameplay")

	projectile.setup_projectile(global_position + spawn_offset, _facing_direction)
	projectile.damage = BASE_PROJECTILE_DAMAGE + _projectile_damage_bonus
	spawn_root.add_child(projectile)

# ============================================================================
# COMBAT
# ============================================================================

# ============================================================================
# HEALTH
# ============================================================================

func _update_damage_timers(delta: float) -> void:
	_hurt_flash_timer = max(_hurt_flash_timer - delta, 0.0)
	_invulnerability_timer = max(_invulnerability_timer - delta, 0.0)
	_level_up_flash_timer = max(_level_up_flash_timer - delta, 0.0)
	_level_up_pulse_timer = max(_level_up_pulse_timer - delta, 0.0)

	if _invulnerability_timer <= 0.0:
		_invulnerability_blink_timer = 0.0
	else:
		_invulnerability_blink_timer += delta

func get_current_health() -> int:
	return _health

func get_max_health() -> int:
	return max_health

# ============================================================================
# XP
# ============================================================================

func collect_xp_orb(amount: int) -> void:
	if _is_dead:
		return

	_add_experience(amount)

func get_current_xp() -> int:
	return _current_xp

func get_xp_to_next_level() -> int:
	return _xp_to_next_level

func get_current_level() -> int:
	return _current_level

func _add_experience(amount: int) -> void:
	if amount <= 0:
		return

	_current_xp += amount
	_resolve_level_ups()

# ============================================================================
# LEVELING
# ============================================================================

func _resolve_level_ups() -> void:
	while _current_xp >= _xp_to_next_level:
		_current_xp -= _xp_to_next_level
		_current_level += 1
		_xp_to_next_level = _xp_required_for_level(_current_level)
		_level_up_flash_timer = LEVEL_UP_FLASH_SECONDS
		_level_up_pulse_timer = LEVEL_UP_PULSE_SECONDS
		_pending_level_up_choices += 1

	_try_show_level_up_selection()

func _xp_required_for_level(level: int) -> int:
	var level_offset: int = max(level - 1, 0)
	return BASE_XP_TO_NEXT_LEVEL + level_offset * XP_PER_LEVEL_STEP

# ============================================================================
# LEVEL UP
# ============================================================================

func _try_show_level_up_selection() -> void:
	if _pending_level_up_choices <= 0:
		return

	if _level_up_selection_ui != null:
		return

	if not FileAccess.file_exists(LEVEL_UP_SELECTION_SCENE_PATH):
		return

	var selection_scene: PackedScene = load(LEVEL_UP_SELECTION_SCENE_PATH)
	if selection_scene == null:
		return

	var selection_ui: CanvasLayer = selection_scene.instantiate() as CanvasLayer
	if selection_ui == null:
		return

	_level_up_selection_ui = selection_ui
	get_tree().current_scene.add_child(_level_up_selection_ui)

	if _level_up_selection_ui.has_signal("upgrade_selected"):
		_level_up_selection_ui.connect("upgrade_selected", Callable(self, "_on_upgrade_selected"))

	if _level_up_selection_ui.has_method("setup_selection"):
		_level_up_selection_ui.call("setup_selection", _current_level)

	get_tree().paused = true

# ============================================================================
# UPGRADES
# ============================================================================

func _on_upgrade_selected(upgrade_id: StringName) -> void:
	_apply_upgrade(upgrade_id)

	_pending_level_up_choices = max(_pending_level_up_choices - 1, 0)
	if _level_up_selection_ui != null:
		_level_up_selection_ui.queue_free()
		_level_up_selection_ui = null

	if _pending_level_up_choices > 0:
		get_tree().paused = false
		_try_show_level_up_selection()
		return

	get_tree().paused = false

func _apply_upgrade(upgrade_id: StringName) -> void:
	if upgrade_id == DAMAGE_UPGRADE_ID:
		_projectile_damage_bonus += damage_upgrade_amount
		return

	if upgrade_id == ATTACK_SPEED_UPGRADE_ID:
		_attack_speed_multiplier *= attack_speed_upgrade_multiplier
		return

	if upgrade_id == MOVE_SPEED_UPGRADE_ID:
		_move_speed_bonus += move_speed_upgrade_amount

# ============================================================================
# UI
# ============================================================================

func _current_fire_cooldown_duration() -> float:
	return FIRE_COOLDOWN_SECONDS * _attack_speed_multiplier

# ============================================================================
# GAME FLOW
# ============================================================================

# ============================================================================
# DAMAGE
# ============================================================================

func apply_contact_damage(amount: int, source_position: Vector2) -> void:
	if _is_dead:
		return

	if _invulnerability_timer > 0.0:
		return

	_health = max(_health - amount, 0)
	_hurt_flash_timer = DAMAGE_FLASH_SECONDS

	var knockback_direction: float = sign(global_position.x - source_position.x)
	if is_zero_approx(knockback_direction):
		knockback_direction = 1.0

	if _health <= 0:
		_start_death()
		return

	velocity.x = knockback_direction * CONTACT_KNOCKBACK_X
	velocity.y = min(velocity.y, CONTACT_KNOCKBACK_Y)
	_invulnerability_timer = DAMAGE_INVULNERABILITY_SECONDS
	_invulnerability_blink_timer = 0.0

# ============================================================================
# DEATH
# ============================================================================

func _start_death() -> void:
	_is_dead = true
	get_tree().paused = false

	if _level_up_selection_ui != null:
		_level_up_selection_ui.queue_free()
		_level_up_selection_ui = null

	_death_flash_timer = DEATH_FLASH_SECONDS
	_death_restart_timer = DEATH_RESTART_DELAY_SECONDS
	_invulnerability_timer = 0.0
	_invulnerability_blink_timer = 0.0
	velocity = Vector2.ZERO
	_collision_shape.disabled = true

func _update_death_state(delta: float) -> void:
	_death_flash_timer = max(_death_flash_timer - delta, 0.0)
	_death_restart_timer = max(_death_restart_timer - delta, 0.0)

	if _death_restart_timer > 0.0:
		return

	get_tree().reload_current_scene()

# ============================================================================
# VISUALS
# ============================================================================

func _update_player_visuals() -> void:
	var sprite_scale: Vector2 = Vector2.ONE
	if _level_up_pulse_timer > 0.0:
		var pulse_strength: float = _level_up_pulse_timer / LEVEL_UP_PULSE_SECONDS
		sprite_scale += Vector2.ONE * pulse_strength * 0.12

	_sprite.scale = sprite_scale

	if _is_dead:
		if _death_flash_timer > 0.0:
			_sprite.self_modulate = DEATH_FLASH_TINT
		else:
			_sprite.self_modulate = DAMAGE_TINT
		return

	if _hurt_flash_timer > 0.0:
		_sprite.self_modulate = DAMAGE_FLASH_TINT
		return

	if _level_up_flash_timer > 0.0:
		_sprite.self_modulate = LEVEL_UP_TINT
		return

	if _invulnerability_timer > 0.0:
		var blink_cycle_duration: float = INVULNERABILITY_BLINK_INTERVAL * 2.0
		var blink_cycle_time: float = fmod(_invulnerability_blink_timer, blink_cycle_duration)
		var use_blink_tint: bool = blink_cycle_time < INVULNERABILITY_BLINK_INTERVAL

		if use_blink_tint:
			_sprite.self_modulate = INVULNERABLE_TINT
		else:
			_sprite.self_modulate = NORMAL_TINT

		return

	_sprite.self_modulate = NORMAL_TINT

# ============================================================================
# DEBUG
# ============================================================================

func _create_debug_health_display() -> void:
	_health_canvas_layer = CanvasLayer.new()
	_health_canvas_layer.name = "HealthDebugCanvas"

	_health_label = Label.new()
	_health_label.name = "HealthLabel"
	_health_label.position = DEBUG_LABEL_OFFSET
	_health_label.text = ""

	_health_canvas_layer.add_child(_health_label)
	add_child(_health_canvas_layer)

func _update_debug_health_display() -> void:
	if _health_label == null:
		return

	var health_text: String = "HP: %d / %d\nXP: %d / %d\nLV: %d" % [
		_health,
		max_health,
		_current_xp,
		_xp_to_next_level,
		_current_level
	]
	if _is_dead:
		health_text += "\n[DEAD]"
	elif _pending_level_up_choices > 0:
		health_text += "\nUP: %d" % _pending_level_up_choices

	_health_label.text = health_text

func _ensure_input_map() -> void:
	for action_name: StringName in INPUT_ACTIONS.keys():
		if not InputMap.has_action(action_name):
			InputMap.add_action(action_name)

		for keycode_variant: Variant in INPUT_ACTIONS[action_name]:
			var keycode: Key = int(keycode_variant)
			if _action_has_key(action_name, keycode):
				continue

			var input_event: InputEventKey = InputEventKey.new()
			input_event.keycode = keycode
			input_event.physical_keycode = keycode
			InputMap.action_add_event(action_name, input_event)

func _action_has_key(action_name: StringName, keycode: Key) -> bool:
	for event: InputEvent in InputMap.action_get_events(action_name):
		if event is InputEventKey:
			var key_event: InputEventKey = event
			if key_event.physical_keycode == keycode or key_event.keycode == keycode:
				return true

	return false
