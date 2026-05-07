extends CharacterBody2D

# ============================================================================
# CONSTANTS
# ============================================================================

const STATE_IDLE: StringName = &"idle"
const STATE_CHASE: StringName = &"chase"
const STATE_ATTACK: StringName = &"attack"
const XP_ORB_SCENE_PATH: String = "res://scenes/pickups/xp_orb.tscn"
const ELITE_BERSERKER: StringName = &"berserker"
const ELITE_TITAN: StringName = &"titan"
const ELITE_VOLTAIC: StringName = &"voltaic"
const IDLE_COLOR: Color = Color(0.46, 0.16, 0.18, 1.0)
const CHASE_COLOR: Color = Color(0.95, 0.14, 0.16, 1.0)
const ATTACK_FLASH_COLOR: Color = Color(1.0, 0.92, 0.92, 1.0)
const BERSERKER_TINT: Color = Color(1.0, 0.54, 0.28, 1.0)
const TITAN_TINT: Color = Color(0.34, 0.22, 0.20, 1.0)
const VOLTAIC_TINT: Color = Color(0.54, 0.84, 1.0, 1.0)
const VOLTAIC_ATTACK_FLASH_COLOR: Color = Color(0.90, 0.99, 1.0, 1.0)
const HIT_FLASH_COLOR: Color = Color(1.0, 1.0, 1.0, 1.0)
const ATTACK_FLASH_TIME: float = 0.10
const ATTACK_WINDUP_SECONDS: float = 0.14
const ATTACK_RECOVERY_SECONDS: float = 0.20
const HIT_FLASH_TIME: float = 0.10
const DAMAGE_TINT_TIME: float = 0.14
const DEATH_FLASH_TIME: float = 0.12
const HIT_PUNCH_TIME: float = 0.10
const ATTACK_LEAN_SCALE: Vector2 = Vector2(1.10, 0.92)

# ============================================================================
# EXPORTED VARIABLES
# ============================================================================

@export var max_health: int = 3
@export var move_speed: float = 85.0
@export var chase_speed: float = 125.0
@export var gravity: float = 1100.0
@export var jump_velocity: float = -300.0
@export var detection_radius: float = 228.0
@export var lose_radius: float = 320.0
@export var attack_range: float = 26.0
@export var attack_damage: int = 8
@export var attack_cooldown: float = 0.9
@export var idle_turn_interval_min: float = 1.0
@export var idle_turn_interval_max: float = 2.4
@export var blocked_jump_chance: float = 0.35
@export var xp_orb_value: int = 4
@export var elite_health_bonus: int = 2
@export var elite_speed_bonus_multiplier: float = 1.18
@export var elite_attack_speed_bonus_multiplier: float = 0.72
@export var elite_scale_bonus: float = 1.12
@export var elite_attack_damage_bonus: int = 2
@export var elite_voltaic_attack_bonus: int = 1

# ============================================================================
# NODE REFERENCES
# ============================================================================

@onready var sprite: Sprite2D = $Sprite2D
@onready var wall_ray_cast: RayCast2D = $WallRayCast2D
@onready var ledge_ray_cast: RayCast2D = $LedgeRayCast2D

# ============================================================================
# RUNTIME VARIABLES
# ============================================================================

var _health: int = 0
var _state: StringName = STATE_IDLE
var _facing_direction: int = -1
var _idle_direction: int = -1
var _idle_turn_timer: float = 0.0
var _attack_cooldown_timer: float = 0.0
var _attack_windup_timer: float = 0.0
var _attack_pending: bool = false
var _attack_flash_timer: float = 0.0
var _hit_flash_timer: float = 0.0
var _damage_tint_timer: float = 0.0
var _death_flash_timer: float = 0.0
var _hit_punch_timer: float = 0.0
var _is_dying: bool = false
var _is_elite: bool = false
var _elite_type: StringName = &""
var _elite_modifiers_applied: bool = false
var _counterplay_move_speed_multiplier: float = 1.0
var _counterplay_chase_speed_multiplier: float = 1.0
var _counterplay_attack_cooldown_multiplier: float = 1.0
var _counterplay_attack_range_bonus: float = 0.0
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _player: Node2D = null

# ============================================================================
# GODOT LIFECYCLE
# ============================================================================

func _ready() -> void:
	add_to_group("enemy")
	add_to_group("melee_enemy")
	_apply_elite_modifiers()
	_health = max_health
	if _is_elite:
		add_to_group("elite")
	_rng.randomize()
	_schedule_next_idle_turn()
	_update_raycast_direction()

func _physics_process(delta: float) -> void:
	_update_timers(delta)
	_update_visuals()

	if _is_dying:
		_update_death_state()
		return

	_refresh_player_reference()
	_update_ai_state()
	_apply_gravity(delta)
	_apply_horizontal_movement()
	_handle_obstacles()
	move_and_slide()
	_resolve_contact_damage()

func _update_timers(delta: float) -> void:
	_idle_turn_timer = max(_idle_turn_timer - delta, 0.0)
	_attack_cooldown_timer = max(_attack_cooldown_timer - delta, 0.0)
	_attack_windup_timer = max(_attack_windup_timer - delta, 0.0)
	_attack_flash_timer = max(_attack_flash_timer - delta, 0.0)
	_hit_flash_timer = max(_hit_flash_timer - delta, 0.0)
	_damage_tint_timer = max(_damage_tint_timer - delta, 0.0)
	_death_flash_timer = max(_death_flash_timer - delta, 0.0)
	_hit_punch_timer = max(_hit_punch_timer - delta, 0.0)

# ============================================================================
# VISUALS
# ============================================================================

func _update_visuals() -> void:
	sprite.flip_h = _facing_direction > 0

	var horizontal_speed_ratio: float = clamp(abs(velocity.x) / max(chase_speed, 1.0), 0.0, 1.0)
	var punch_strength: float = 0.0
	if _hit_punch_timer > 0.0:
		punch_strength = _hit_punch_timer / HIT_PUNCH_TIME
	var attack_lean_strength: float = 0.0
	if _attack_windup_timer > 0.0:
		attack_lean_strength = clamp(_attack_windup_timer / ATTACK_WINDUP_SECONDS, 0.0, 1.0)

	sprite.scale = _apply_elite_scale(Vector2(
		1.0 + horizontal_speed_ratio * 0.08 + punch_strength * 0.18,
		1.0 - horizontal_speed_ratio * 0.05 - punch_strength * 0.10
	))
	if _state == STATE_ATTACK and _attack_windup_timer > 0.0:
		sprite.scale = Vector2(
			sprite.scale.x * lerp(1.0, ATTACK_LEAN_SCALE.x, attack_lean_strength),
			sprite.scale.y * lerp(1.0, ATTACK_LEAN_SCALE.y, attack_lean_strength)
		)
	sprite.self_modulate = _tint_elite_color(_current_visual_color())

func _current_visual_color() -> Color:
	if _death_flash_timer > 0.0:
		return HIT_FLASH_COLOR

	if _hit_flash_timer > 0.0:
		return HIT_FLASH_COLOR

	if _damage_tint_timer > 0.0:
		return Color(1.0, 0.74, 0.74, 1.0)

	if _state == STATE_ATTACK and _attack_windup_timer > 0.0:
		return Color(1.0, 0.98, 0.84, 1.0)

	if _attack_flash_timer > 0.0 or _state == STATE_ATTACK:
		if _elite_type == ELITE_VOLTAIC:
			return VOLTAIC_ATTACK_FLASH_COLOR
		return ATTACK_FLASH_COLOR

	if _state == STATE_CHASE:
		return CHASE_COLOR

	return IDLE_COLOR

# ============================================================================
# ELITE MODIFIERS
# ============================================================================

func configure_elite(elite_type: StringName) -> void:
	if elite_type == &"":
		return

	_is_elite = true
	_elite_type = elite_type

	if is_inside_tree() and not _elite_modifiers_applied:
		_apply_elite_modifiers()

func _apply_elite_modifiers() -> void:
	if not _is_elite or _elite_modifiers_applied:
		return

	_elite_modifiers_applied = true

	match _elite_type:
		ELITE_BERSERKER:
			max_health += elite_health_bonus
			move_speed *= elite_speed_bonus_multiplier
			chase_speed *= 1.24
			attack_damage += 1
			attack_cooldown *= elite_attack_speed_bonus_multiplier
		ELITE_TITAN:
			max_health += elite_health_bonus
			move_speed *= 0.82
			chase_speed *= 0.82
			attack_damage += 1
		ELITE_VOLTAIC:
			max_health += elite_health_bonus
			attack_damage += elite_voltaic_attack_bonus
			attack_cooldown *= 0.84
		_:
			_is_elite = false
			_elite_type = &""

# ============================================================================
# COUNTERPLAY
# ============================================================================

func configure_counterplay(player_build_identity: StringName) -> void:
	_counterplay_move_speed_multiplier = 1.0
	_counterplay_chase_speed_multiplier = 1.0
	_counterplay_attack_cooldown_multiplier = 1.0
	_counterplay_attack_range_bonus = 0.0

	match player_build_identity:
		&"mobility":
			_counterplay_move_speed_multiplier = 1.03
			_counterplay_chase_speed_multiplier = 1.06
			_counterplay_attack_cooldown_multiplier = 0.97
			_counterplay_attack_range_bonus = 2.0
		&"aggression":
			_counterplay_move_speed_multiplier = 1.04
			_counterplay_chase_speed_multiplier = 1.05
			_counterplay_attack_cooldown_multiplier = 0.95
			_counterplay_attack_range_bonus = 4.0
		&"ranged":
			_counterplay_move_speed_multiplier = 1.02
			_counterplay_chase_speed_multiplier = 1.07
			_counterplay_attack_cooldown_multiplier = 0.96
			_counterplay_attack_range_bonus = 3.0
		&"momentum":
			_counterplay_move_speed_multiplier = 1.03
			_counterplay_chase_speed_multiplier = 1.05
			_counterplay_attack_cooldown_multiplier = 0.94
			_counterplay_attack_range_bonus = 2.0

# ============================================================================
# SCALING
# ============================================================================

func _elite_scale_multiplier() -> Vector2:
	if not _is_elite:
		return Vector2.ONE

	match _elite_type:
		ELITE_TITAN:
			return Vector2.ONE * elite_scale_bonus
		ELITE_BERSERKER:
			return Vector2(1.04, 1.02)
		ELITE_VOLTAIC:
			return Vector2(1.02, 1.02)
		_:
			return Vector2.ONE

func _apply_elite_scale(base_scale: Vector2) -> Vector2:
	var elite_scale: Vector2 = _elite_scale_multiplier()
	return Vector2(base_scale.x * elite_scale.x, base_scale.y * elite_scale.y)

func _elite_tint_color() -> Color:
	if not _is_elite:
		return Color.WHITE

	match _elite_type:
		ELITE_BERSERKER:
			return BERSERKER_TINT
		ELITE_TITAN:
			return TITAN_TINT
		ELITE_VOLTAIC:
			return VOLTAIC_TINT
		_:
			return Color.WHITE

func _tint_elite_color(base_color: Color) -> Color:
	var tint_color: Color = _elite_tint_color()
	return Color(
		base_color.r * tint_color.r,
		base_color.g * tint_color.g,
		base_color.b * tint_color.b,
		base_color.a * tint_color.a
	)

# ============================================================================
# AI
# ============================================================================

func _refresh_player_reference() -> void:
	if is_instance_valid(_player):
		return

	_player = get_tree().get_first_node_in_group("player") as Node2D

func _update_ai_state() -> void:
	if _player == null:
		_state = STATE_IDLE
		_update_idle_direction()
		return

	var distance_to_player: float = global_position.distance_to(_player.global_position)
	if distance_to_player <= _current_attack_range():
		if _attack_cooldown_timer <= 0.0 or _state == STATE_ATTACK:
			_state = STATE_ATTACK
		else:
			_state = STATE_CHASE
		return

	if distance_to_player <= detection_radius:
		_state = STATE_CHASE
		_attack_pending = false
		return

	if distance_to_player >= lose_radius:
		_state = STATE_IDLE
		_attack_pending = false

	_update_idle_direction()

func _update_idle_direction() -> void:
	if _state != STATE_IDLE:
		return

	if _idle_turn_timer > 0.0:
		return

	if _rng.randf() < 0.35:
		_idle_direction = 0
	else:
		_idle_direction *= -1

	_schedule_next_idle_turn()

func _schedule_next_idle_turn() -> void:
	_idle_turn_timer = _rng.randf_range(idle_turn_interval_min, idle_turn_interval_max)

func _desired_direction() -> int:
	if _state == STATE_CHASE and _player != null:
		return 1 if _player.global_position.x > global_position.x else -1

	if _state == STATE_ATTACK and _player != null:
		if _attack_windup_timer > 0.0 or _attack_cooldown_timer > 0.0:
			return 0

		return 1 if _player.global_position.x > global_position.x else -1

	return _idle_direction

# ============================================================================
# MOVEMENT
# ============================================================================

func _apply_gravity(delta: float) -> void:
	if is_on_floor() and velocity.y > 0.0:
		velocity.y = 0.0
		return

	velocity.y += gravity * delta

func _apply_horizontal_movement() -> void:
	var direction: int = _desired_direction()
	var target_speed: float = 0.0
	var acceleration: float = 14.0
	var move_speed_value: float = move_speed * _counterplay_move_speed_multiplier
	var chase_speed_value: float = chase_speed * _counterplay_chase_speed_multiplier

	if _state == STATE_CHASE:
		target_speed = direction * chase_speed_value
	elif _state == STATE_IDLE:
		target_speed = direction * move_speed_value
	elif _state == STATE_ATTACK:
		if _attack_windup_timer > 0.0:
			target_speed = 0.0
			acceleration = 24.0
		elif _attack_cooldown_timer > 0.0:
			target_speed = 0.0
			acceleration = 20.0
		else:
			target_speed = direction * chase_speed
	else:
		target_speed = direction * move_speed

	velocity.x = move_toward(velocity.x, target_speed, acceleration)

	if direction != 0:
		_facing_direction = direction
		_update_raycast_direction()

func _handle_obstacles() -> void:
	if _is_dying:
		return

	if _facing_direction == 0:
		return

	var hit_wall: bool = wall_ray_cast.is_colliding()
	var no_floor_ahead: bool = not ledge_ray_cast.is_colliding()
	if not hit_wall and not no_floor_ahead:
		return

	_facing_direction *= -1
	_idle_direction = _facing_direction
	_update_raycast_direction()
	_schedule_next_idle_turn()

	if is_on_floor() and hit_wall and _rng.randf() <= blocked_jump_chance:
		velocity.y = jump_velocity

func _current_attack_range() -> float:
	return attack_range + _counterplay_attack_range_bonus

func _update_raycast_direction() -> void:
	var horizontal_offset: float = 18.0 * _facing_direction
	wall_ray_cast.target_position = Vector2(horizontal_offset, 0.0)
	ledge_ray_cast.target_position = Vector2(16.0 * _facing_direction, 28.0)

# ============================================================================
# COMBAT
# ============================================================================

func _resolve_contact_damage() -> void:
	if _is_dying:
		return

	if _state != STATE_ATTACK:
		return

	if _attack_cooldown_timer > 0.0:
		return

	if _player == null:
		return

	if not _player.is_in_group("player"):
		return

	var distance_to_player: float = global_position.distance_to(_player.global_position)
	if distance_to_player > _current_attack_range():
		return

	if not _attack_pending:
		_attack_pending = true
		_attack_windup_timer = ATTACK_WINDUP_SECONDS
		_attack_flash_timer = ATTACK_FLASH_TIME
		_hit_punch_timer = max(_hit_punch_timer, HIT_PUNCH_TIME * 0.6)
		return

	if _attack_windup_timer > 0.0:
		return

	if _player.has_method("apply_contact_damage"):
		_player.apply_contact_damage(attack_damage, global_position)

	_attack_cooldown_timer = ATTACK_RECOVERY_SECONDS + attack_cooldown * _counterplay_attack_cooldown_multiplier
	_attack_pending = false
	_attack_flash_timer = ATTACK_FLASH_TIME
	_hit_flash_timer = HIT_FLASH_TIME

func take_projectile_hit(damage: int, knockback: Vector2) -> void:
	if _is_dying:
		return

	_health = max(_health - damage, 0)
	velocity.x = knockback.x
	velocity.y = min(velocity.y, knockback.y * 0.2)
	_hit_flash_timer = HIT_FLASH_TIME
	_damage_tint_timer = DAMAGE_TINT_TIME
	_hit_punch_timer = HIT_PUNCH_TIME

	if _health > 0:
		return

	_start_death_feedback()

func get_current_health() -> int:
	return _health

func _start_death_feedback() -> void:
	_is_dying = true
	_spawn_xp_orb()
	_death_flash_timer = DEATH_FLASH_TIME
	velocity = Vector2.ZERO
	_collision_enabled(false)
	wall_ray_cast.enabled = false
	ledge_ray_cast.enabled = false

func _spawn_xp_orb() -> void:
	if not FileAccess.file_exists(XP_ORB_SCENE_PATH):
		return

	var orb_scene: PackedScene = load(XP_ORB_SCENE_PATH)
	if orb_scene == null:
		return

	var orb_instance: Node = orb_scene.instantiate()
	if orb_instance == null:
		return

	var spawn_parent: Node = get_parent()
	if spawn_parent == null:
		spawn_parent = get_tree().current_scene

	spawn_parent.add_child(orb_instance)

	if orb_instance.has_method("setup_orb"):
		orb_instance.setup_orb(global_position, xp_orb_value)

func _update_death_state() -> void:
	if _death_flash_timer > 0.0:
		return

	queue_free()

func _collision_enabled(enabled: bool) -> void:
	var collision_shape: CollisionShape2D = get_node_or_null("CollisionShape2D") as CollisionShape2D
	if collision_shape == null:
		return

	collision_shape.disabled = not enabled
