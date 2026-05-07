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
const PROJECTILE_SPEED_UPGRADE_ID: StringName = &"projectile_speed_up"
const PROJECTILE_PIERCE_UPGRADE_ID: StringName = &"projectile_pierce_up"
const JUMP_POWER_UPGRADE_ID: StringName = &"jump_power_up"
const CRIT_BURST_UPGRADE_ID: StringName = &"crit_burst_up"
const SPLIT_SHOT_UPGRADE_ID: StringName = &"split_shot_up"
const KILL_MOMENTUM_UPGRADE_ID: StringName = &"kill_momentum_up"
const BUILD_ID_BALANCED: StringName = &"balanced"
const BUILD_ID_MOBILITY: StringName = &"mobility"
const BUILD_ID_AGGRESSION: StringName = &"aggression"
const BUILD_ID_RANGED: StringName = &"ranged"
const BUILD_ID_MOMENTUM: StringName = &"momentum"
const BASE_XP_TO_NEXT_LEVEL: int = 8
const XP_PER_LEVEL_STEP: int = 4
const BASE_PROJECTILE_SPEED: float = 840.0
const BASE_PROJECTILE_CRIT_MULTIPLIER: float = 1.75
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
@export var sprint_speed: float = 340.0
@export var acceleration: float = 1500.0
@export var friction: float = 1900.0
@export var jump_velocity: float = -420.0
@export var gravity: float = 1200.0
@export var max_health: int = 100
@export var damage_upgrade_amount: int = 1
@export var attack_speed_upgrade_multiplier: float = 0.88
@export var move_speed_upgrade_amount: float = 24.0
@export var projectile_speed_upgrade_multiplier: float = 1.10
@export var projectile_pierce_upgrade_amount: int = 1
@export var jump_power_upgrade_amount: float = 28.0
@export var crit_burst_upgrade_amount: float = 0.08
@export var split_shot_upgrade_amount: float = 0.18
@export var kill_momentum_upgrade_duration: float = 1.60
@export var kill_momentum_move_speed_bonus: float = 32.0
@export var kill_momentum_attack_speed_multiplier: float = 0.90
@export var specialization_threshold: int = 3
@export var mobility_specialization_move_bonus: float = 14.0
@export var mobility_specialization_jump_bonus: float = 16.0
@export var aggression_specialization_damage_bonus: int = 1
@export var aggression_specialization_crit_bonus: float = 0.05
@export var ranged_specialization_speed_multiplier: float = 1.08
@export var ranged_specialization_pierce_bonus: int = 1
@export var momentum_specialization_duration_bonus: float = 0.24
@export var momentum_specialization_move_bonus: float = 8.0
@export var momentum_specialization_attack_speed_multiplier: float = 0.96

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
var _projectile_speed_multiplier: float = 1.0
var _projectile_pierce_bonus: int = 0
var _jump_velocity_bonus: float = 0.0
var _critical_chance_bonus: float = 0.0
var _split_shot_chance: float = 0.0
var _kill_momentum_unlocked: bool = false
var _kill_momentum_timer: float = 0.0
var _kill_momentum_flash_timer: float = 0.0
var _mobility_upgrade_score: int = 0
var _aggression_upgrade_score: int = 0
var _ranged_upgrade_score: int = 0
var _momentum_upgrade_score: int = 0
var _mobility_specialization_applied: bool = false
var _aggression_specialization_applied: bool = false
var _ranged_specialization_applied: bool = false
var _momentum_specialization_applied: bool = false
var _build_identity: StringName = BUILD_ID_BALANCED
var _upgrade_rng: RandomNumberGenerator = RandomNumberGenerator.new()
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
	_upgrade_rng.randomize()
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
	_update_proc_timers(delta)
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
	if _kill_momentum_timer > 0.0:
		walk_speed += kill_momentum_move_speed_bonus
		sprint_move_speed += kill_momentum_move_speed_bonus

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

	velocity.y = jump_velocity - _jump_velocity_bonus
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
	var base_damage: int = BASE_PROJECTILE_DAMAGE + _projectile_damage_bonus
	var is_critical: bool = _upgrade_rng.randf() < _current_critical_chance()

	if spawn_root.has_node("Gameplay"):
		spawn_root = spawn_root.get_node("Gameplay")

	projectile.setup_projectile(global_position + spawn_offset, _facing_direction)
	projectile.damage = base_damage
	projectile.speed = _current_projectile_speed()
	projectile.pierce = _current_projectile_pierce()
	projectile.critical = is_critical
	projectile.crit_multiplier = BASE_PROJECTILE_CRIT_MULTIPLIER
	spawn_root.add_child(projectile)

	if _split_shot_chance > 0.0 and _upgrade_rng.randf() < _split_shot_chance:
		_spawn_split_projectile(spawn_root, spawn_offset, base_damage)

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

func get_build_identity() -> StringName:
	return _build_identity

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
		_level_up_selection_ui.call("setup_selection", _current_level, _build_level_up_choices(), _build_identity)

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
		_record_build_specialization(upgrade_id)
		_refresh_build_identity()
		return

	if upgrade_id == ATTACK_SPEED_UPGRADE_ID:
		_attack_speed_multiplier *= attack_speed_upgrade_multiplier
		_record_build_specialization(upgrade_id)
		_refresh_build_identity()
		return

	if upgrade_id == MOVE_SPEED_UPGRADE_ID:
		_move_speed_bonus += move_speed_upgrade_amount
		_record_build_specialization(upgrade_id)
		_refresh_build_identity()
		return

	if upgrade_id == PROJECTILE_SPEED_UPGRADE_ID:
		_projectile_speed_multiplier *= projectile_speed_upgrade_multiplier
		_record_build_specialization(upgrade_id)
		_refresh_build_identity()
		return

	if upgrade_id == PROJECTILE_PIERCE_UPGRADE_ID:
		_projectile_pierce_bonus += projectile_pierce_upgrade_amount
		_record_build_specialization(upgrade_id)
		_refresh_build_identity()
		return

	if upgrade_id == JUMP_POWER_UPGRADE_ID:
		_jump_velocity_bonus += jump_power_upgrade_amount
		_record_build_specialization(upgrade_id)
		_refresh_build_identity()
		return

	if upgrade_id == CRIT_BURST_UPGRADE_ID:
		_critical_chance_bonus += crit_burst_upgrade_amount
		_record_build_specialization(upgrade_id)
		_refresh_build_identity()
		return

	if upgrade_id == SPLIT_SHOT_UPGRADE_ID:
		_split_shot_chance += split_shot_upgrade_amount
		_record_build_specialization(upgrade_id)
		_refresh_build_identity()
		return

	if upgrade_id == KILL_MOMENTUM_UPGRADE_ID:
		_kill_momentum_unlocked = true
		_kill_momentum_timer = max(_kill_momentum_timer, kill_momentum_upgrade_duration)
		_kill_momentum_flash_timer = max(_kill_momentum_flash_timer, 0.18)
		_record_build_specialization(upgrade_id)
		_refresh_build_identity()
		return

# ============================================================================
# UI
# ============================================================================

func _current_fire_cooldown_duration() -> float:
	var cooldown: float = FIRE_COOLDOWN_SECONDS * _attack_speed_multiplier
	if _kill_momentum_timer > 0.0:
		cooldown *= kill_momentum_attack_speed_multiplier

	return cooldown

func _current_projectile_speed() -> float:
	return BASE_PROJECTILE_SPEED * _projectile_speed_multiplier

func _current_projectile_pierce() -> int:
	return _projectile_pierce_bonus

func _current_critical_chance() -> float:
	return clamp(_critical_chance_bonus, 0.0, 0.45)

func _update_proc_timers(delta: float) -> void:
	_kill_momentum_timer = max(_kill_momentum_timer - delta, 0.0)
	_kill_momentum_flash_timer = max(_kill_momentum_flash_timer - delta, 0.0)

func _build_level_up_choices() -> Array:
	var available_choices: Array = _weighted_upgrade_pool()
	var selected_choices: Array = []
	var choice_count: int = min(3, available_choices.size())

	for choice_index: int in range(choice_count):
		var random_index: int = _upgrade_rng.randi_range(0, available_choices.size() - 1)
		selected_choices.append(available_choices[random_index])
		var selected_upgrade_id: StringName = available_choices[random_index]["id"]
		available_choices = _remove_upgrade_from_pool(available_choices, selected_upgrade_id)

	return selected_choices

func _weighted_upgrade_pool() -> Array:
	var upgrade_options: Array = _available_upgrade_options()
	var weighted_pool: Array = []
	var preferred_build_tags: Array = _preferred_build_tags()

	for option: Dictionary in upgrade_options:
		var weight: int = 1
		var option_tags: Array = option.get("tags", [])

		for build_tag: StringName in preferred_build_tags:
			if option_tags.has(build_tag):
				weight += 1

		for weight_index: int in range(weight):
			weighted_pool.append(option)

	return weighted_pool

func _remove_upgrade_from_pool(available_choices: Array, upgrade_id: StringName) -> Array:
	var filtered_choices: Array = []
	for option: Dictionary in available_choices:
		if option["id"] == upgrade_id:
			continue

		filtered_choices.append(option)

	return filtered_choices

func _preferred_build_tags() -> Array[StringName]:
	match _build_identity:
		BUILD_ID_MOBILITY:
			return [BUILD_ID_MOBILITY, BUILD_ID_MOMENTUM]
		BUILD_ID_AGGRESSION:
			return [BUILD_ID_AGGRESSION, BUILD_ID_MOMENTUM]
		BUILD_ID_RANGED:
			return [BUILD_ID_RANGED, BUILD_ID_AGGRESSION]
		BUILD_ID_MOMENTUM:
			return [BUILD_ID_MOMENTUM, BUILD_ID_MOBILITY]
		_:
			return [BUILD_ID_AGGRESSION, BUILD_ID_MOBILITY, BUILD_ID_RANGED, BUILD_ID_MOMENTUM]

func _record_build_specialization(upgrade_id: StringName) -> void:
	if upgrade_id == DAMAGE_UPGRADE_ID:
		_aggression_upgrade_score += 1
		return

	if upgrade_id == ATTACK_SPEED_UPGRADE_ID:
		_aggression_upgrade_score += 1
		_momentum_upgrade_score += 1
		return

	if upgrade_id == MOVE_SPEED_UPGRADE_ID:
		_mobility_upgrade_score += 1
		return

	if upgrade_id == PROJECTILE_SPEED_UPGRADE_ID:
		_ranged_upgrade_score += 1
		return

	if upgrade_id == PROJECTILE_PIERCE_UPGRADE_ID:
		_ranged_upgrade_score += 1
		return

	if upgrade_id == JUMP_POWER_UPGRADE_ID:
		_mobility_upgrade_score += 1
		return

	if upgrade_id == CRIT_BURST_UPGRADE_ID:
		_aggression_upgrade_score += 1
		_ranged_upgrade_score += 1
		return

	if upgrade_id == SPLIT_SHOT_UPGRADE_ID:
		_ranged_upgrade_score += 1
		_momentum_upgrade_score += 1
		return

	if upgrade_id == KILL_MOMENTUM_UPGRADE_ID:
		_momentum_upgrade_score += 1
		_mobility_upgrade_score += 1

func _refresh_build_identity() -> void:
	_apply_specialization_bonus()
	var dominant_score: int = _aggression_upgrade_score
	var dominant_identity: StringName = BUILD_ID_AGGRESSION
	var next_score: int = max(_mobility_upgrade_score, _ranged_upgrade_score)
	var momentum_score: int = _momentum_upgrade_score

	if _mobility_upgrade_score > dominant_score:
		dominant_score = _mobility_upgrade_score
		dominant_identity = BUILD_ID_MOBILITY
		next_score = max(_aggression_upgrade_score, max(_ranged_upgrade_score, _momentum_upgrade_score))
	elif _ranged_upgrade_score > dominant_score:
		dominant_score = _ranged_upgrade_score
		dominant_identity = BUILD_ID_RANGED
		next_score = max(_aggression_upgrade_score, max(_mobility_upgrade_score, _momentum_upgrade_score))
	elif momentum_score > dominant_score:
		dominant_score = momentum_score
		dominant_identity = BUILD_ID_MOMENTUM
		next_score = max(_aggression_upgrade_score, max(_mobility_upgrade_score, _ranged_upgrade_score))

	if dominant_score < specialization_threshold:
		_build_identity = BUILD_ID_BALANCED
		return

	if dominant_score - next_score < 1:
		_build_identity = BUILD_ID_BALANCED
		return

	_build_identity = dominant_identity

func _apply_specialization_bonus() -> void:
	if not _mobility_specialization_applied and _mobility_upgrade_score >= specialization_threshold:
		_mobility_specialization_applied = true
		_move_speed_bonus += mobility_specialization_move_bonus
		_jump_velocity_bonus += mobility_specialization_jump_bonus

	if not _aggression_specialization_applied and _aggression_upgrade_score >= specialization_threshold:
		_aggression_specialization_applied = true
		_projectile_damage_bonus += aggression_specialization_damage_bonus
		_critical_chance_bonus += aggression_specialization_crit_bonus

	if not _ranged_specialization_applied and _ranged_upgrade_score >= specialization_threshold:
		_ranged_specialization_applied = true
		_projectile_speed_multiplier *= ranged_specialization_speed_multiplier
		_projectile_pierce_bonus += ranged_specialization_pierce_bonus

	if not _momentum_specialization_applied and _momentum_upgrade_score >= specialization_threshold:
		_momentum_specialization_applied = true
		_move_speed_bonus += momentum_specialization_move_bonus
		_attack_speed_multiplier *= momentum_specialization_attack_speed_multiplier
		kill_momentum_upgrade_duration += momentum_specialization_duration_bonus
		kill_momentum_move_speed_bonus += momentum_specialization_move_bonus
		kill_momentum_attack_speed_multiplier *= momentum_specialization_attack_speed_multiplier

func _available_upgrade_options() -> Array:
	return [
		{
			"id": DAMAGE_UPGRADE_ID,
			"title": "Damage Up",
			"description": "Projectiles hit harder.",
			"tags": [BUILD_ID_AGGRESSION]
		},
		{
			"id": ATTACK_SPEED_UPGRADE_ID,
			"title": "Attack Speed Up",
			"description": "Fire more often.",
			"tags": [BUILD_ID_AGGRESSION, BUILD_ID_MOMENTUM]
		},
		{
			"id": MOVE_SPEED_UPGRADE_ID,
			"title": "Move Speed Up",
			"description": "Run and sprint faster.",
			"tags": [BUILD_ID_MOBILITY]
		},
		{
			"id": PROJECTILE_SPEED_UPGRADE_ID,
			"title": "Projectile Speed Up",
			"description": "Shots travel faster.",
			"tags": [BUILD_ID_RANGED]
		},
		{
			"id": PROJECTILE_PIERCE_UPGRADE_ID,
			"title": "Projectile Pierce Up",
			"description": "Shots pass through one extra enemy.",
			"tags": [BUILD_ID_RANGED]
		},
		{
			"id": JUMP_POWER_UPGRADE_ID,
			"title": "Jump Power Up",
			"description": "Gain more vertical escape.",
			"tags": [BUILD_ID_MOBILITY]
		},
		{
			"id": CRIT_BURST_UPGRADE_ID,
			"title": "Crit Burst",
			"description": "Shots sometimes strike harder.",
			"tags": [BUILD_ID_AGGRESSION, BUILD_ID_RANGED]
		},
		{
			"id": SPLIT_SHOT_UPGRADE_ID,
			"title": "Split Shot",
			"description": "Shots occasionally split.",
			"tags": [BUILD_ID_RANGED, BUILD_ID_MOMENTUM]
		},
		{
			"id": KILL_MOMENTUM_UPGRADE_ID,
			"title": "Kill Momentum",
			"description": "Kills briefly boost speed.",
			"tags": [BUILD_ID_MOMENTUM, BUILD_ID_MOBILITY]
		}
	]

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
	if _kill_momentum_flash_timer > 0.0:
		sprite_scale += Vector2.ONE * 0.08

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

	if _kill_momentum_flash_timer > 0.0:
		_sprite.self_modulate = Color(0.76, 0.92, 1.0, 1.0)
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
	health_text += "\nBD: %s" % String(_build_identity).capitalize()
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

func _spawn_split_projectile(spawn_root: Node, base_spawn_offset: Vector2, base_damage: int) -> void:
	var split_projectile: Projectile = Projectile.new()
	var split_offset: Vector2 = base_spawn_offset + Vector2(0.0, -6.0)
	var split_damage: int = max(1, int(floor(float(base_damage) * 0.60)))

	split_projectile.setup_projectile(global_position + split_offset, _facing_direction)
	split_projectile.damage = split_damage
	split_projectile.speed = _current_projectile_speed() * 0.92
	split_projectile.pierce = _current_projectile_pierce()
	split_projectile.critical = false
	split_projectile.split_variant = true
	split_projectile.crit_multiplier = BASE_PROJECTILE_CRIT_MULTIPLIER
	spawn_root.add_child(split_projectile)

func on_enemy_killed(_enemy_position: Vector2) -> void:
	if _is_dead:
		return

	if not _kill_momentum_unlocked:
		return

	_kill_momentum_timer = max(_kill_momentum_timer, kill_momentum_upgrade_duration)
	_kill_momentum_flash_timer = max(_kill_momentum_flash_timer, 0.16)
