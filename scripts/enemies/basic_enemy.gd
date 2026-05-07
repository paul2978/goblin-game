extends CharacterBody2D

# ============================================================================
# CONSTANTS
# ============================================================================

const STATE_IDLE: StringName = &"idle"
const STATE_CHASE: StringName = &"chase"
const STATE_ATTACK: StringName = &"attack"
const IDLE_COLOR: Color = Color(0.46, 0.16, 0.18, 1.0)
const CHASE_COLOR: Color = Color(0.95, 0.14, 0.16, 1.0)
const ATTACK_FLASH_COLOR: Color = Color(1.0, 0.92, 0.92, 1.0)
const HIT_FLASH_COLOR: Color = Color(1.0, 1.0, 1.0, 1.0)
const ATTACK_FLASH_TIME: float = 0.10
const HIT_FLASH_TIME: float = 0.08

# ============================================================================
# EXPORTED VARIABLES
# ============================================================================

@export var move_speed: float = 85.0
@export var chase_speed: float = 125.0
@export var gravity: float = 1100.0
@export var jump_velocity: float = -300.0
@export var detection_radius: float = 240.0
@export var lose_radius: float = 320.0
@export var attack_range: float = 26.0
@export var attack_damage: int = 8
@export var attack_cooldown: float = 0.9
@export var idle_turn_interval_min: float = 1.0
@export var idle_turn_interval_max: float = 2.4
@export var blocked_jump_chance: float = 0.35

# ============================================================================
# NODE REFERENCES
# ============================================================================

@onready var sprite: Sprite2D = $Sprite2D
@onready var wall_ray_cast: RayCast2D = $WallRayCast2D
@onready var ledge_ray_cast: RayCast2D = $LedgeRayCast2D

# ============================================================================
# RUNTIME VARIABLES
# ============================================================================

var _state: StringName = STATE_IDLE
var _facing_direction: int = -1
var _idle_direction: int = -1
var _idle_turn_timer: float = 0.0
var _attack_cooldown_timer: float = 0.0
var _attack_flash_timer: float = 0.0
var _hit_flash_timer: float = 0.0
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _player: Node2D = null

# ============================================================================
# GODOT LIFECYCLE
# ============================================================================

func _ready() -> void:
	add_to_group("enemy")
	_rng.randomize()
	_schedule_next_idle_turn()
	_update_raycast_direction()

func _physics_process(delta: float) -> void:
	_update_timers(delta)
	_refresh_player_reference()
	_update_ai_state()
	_apply_gravity(delta)
	_apply_horizontal_movement()
	_handle_obstacles()
	move_and_slide()
	_resolve_contact_damage()
	_update_visuals()

func _update_timers(delta: float) -> void:
	_idle_turn_timer = max(_idle_turn_timer - delta, 0.0)
	_attack_cooldown_timer = max(_attack_cooldown_timer - delta, 0.0)
	_attack_flash_timer = max(_attack_flash_timer - delta, 0.0)
	_hit_flash_timer = max(_hit_flash_timer - delta, 0.0)

# ============================================================================
# VISUALS
# ============================================================================

func _update_visuals() -> void:
	sprite.flip_h = _facing_direction > 0

	var horizontal_speed_ratio: float = clamp(abs(velocity.x) / max(chase_speed, 1.0), 0.0, 1.0)
	sprite.scale = Vector2(1.0 + horizontal_speed_ratio * 0.08, 1.0 - horizontal_speed_ratio * 0.05)
	sprite.self_modulate = _current_visual_color()

func _current_visual_color() -> Color:
	if _hit_flash_timer > 0.0:
		return HIT_FLASH_COLOR

	if _attack_flash_timer > 0.0 or _state == STATE_ATTACK:
		return ATTACK_FLASH_COLOR

	if _state == STATE_CHASE:
		return CHASE_COLOR

	return IDLE_COLOR

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
	if distance_to_player <= attack_range:
		_state = STATE_ATTACK
		return

	if distance_to_player <= detection_radius:
		_state = STATE_CHASE
		return

	if distance_to_player >= lose_radius:
		_state = STATE_IDLE

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

	if _state == STATE_CHASE:
		target_speed = direction * chase_speed
	elif _state == STATE_IDLE:
		target_speed = direction * move_speed

	velocity.x = move_toward(velocity.x, target_speed, 14.0)

	if direction != 0:
		_facing_direction = direction
		_update_raycast_direction()

func _handle_obstacles() -> void:
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

func _update_raycast_direction() -> void:
	var horizontal_offset: float = 18.0 * _facing_direction
	wall_ray_cast.target_position = Vector2(horizontal_offset, 0.0)
	ledge_ray_cast.target_position = Vector2(16.0 * _facing_direction, 28.0)

# ============================================================================
# COMBAT
# ============================================================================

func _resolve_contact_damage() -> void:
	if _attack_cooldown_timer > 0.0:
		return

	for slide_index: int in range(get_slide_collision_count()):
		var collision: KinematicCollision2D = get_slide_collision(slide_index)
		var collider: Object = collision.get_collider()
		if collider == null:
			continue

		if not collider.is_in_group("player"):
			continue

		if collider.has_method("apply_contact_damage"):
			collider.apply_contact_damage(attack_damage, global_position)

		_attack_cooldown_timer = attack_cooldown
		_attack_flash_timer = ATTACK_FLASH_TIME
		_hit_flash_timer = HIT_FLASH_TIME
		_state = STATE_ATTACK
		return
