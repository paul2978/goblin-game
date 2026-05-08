extends CharacterBody2D

# ============================================================================
# CONSTANTS
# ============================================================================

const STATE_IDLE: StringName = &"idle"
const STATE_CHASE: StringName = &"chase"
const STATE_ATTACK: StringName = &"attack"
const STATE_RETREAT: StringName = &"retreat"
const XP_ORB_SCENE_PATH: String = "res://scenes/pickups/xp_orb.tscn"
const ELITE_BERSERKER: StringName = &"berserker"
const ELITE_TITAN: StringName = &"titan"
const ELITE_VOLTAIC: StringName = &"voltaic"
const IDLE_COLOR: Color = Color(1.0, 0.70, 0.18, 1.0)
const CHASE_COLOR: Color = Color(1.0, 0.82, 0.24, 1.0)
const ATTACK_COLOR: Color = Color(1.0, 0.95, 0.48, 1.0)
const RETREAT_COLOR: Color = Color(1.0, 0.55, 0.12, 1.0)
const BERSERKER_TINT: Color = Color(1.0, 0.58, 0.22, 1.0)
const TITAN_TINT: Color = Color(0.34, 0.24, 0.16, 1.0)
const VOLTAIC_TINT: Color = Color(0.56, 0.88, 1.0, 1.0)
const VOLTAIC_ATTACK_COLOR: Color = Color(0.96, 0.99, 1.0, 1.0)
const HIT_FLASH_COLOR: Color = Color(1.0, 1.0, 1.0, 1.0)
const SWARM_PROC_KIND_SHOCK: StringName = &"shock"
const SWARM_PROC_KIND_BURN: StringName = &"burn"
const SWARM_PROC_KIND_CHAIN: StringName = &"chain"
const SWARM_SHOCK_DURATION_SECONDS: float = 0.60
const SWARM_BURN_DURATION_SECONDS: float = 0.90
const SWARM_BURN_TICK_SECONDS: float = 0.30
const SWARM_SHOCK_MOVE_MULTIPLIER: float = 0.84
const SWARM_SHOCK_ATTACK_MULTIPLIER: float = 1.12
const SWARM_BURN_DAMAGE_RATIO: float = 0.40
const SWARM_CHAIN_RADIUS: float = 92.0
const SWARM_CHAIN_DAMAGE_RATIO: float = 0.48
const SWARM_SHOCK_TINT: Color = Color(0.58, 0.92, 1.0, 1.0)
const SWARM_BURN_TINT: Color = Color(1.0, 0.66, 0.30, 1.0)
const SWARM_CHAIN_TINT: Color = Color(0.80, 1.0, 0.90, 1.0)
const IDLE_TURN_MIN: float = 0.45
const IDLE_TURN_MAX: float = 1.05
const ATTACK_WINDUP_SECONDS: float = 0.06
const ATTACK_RECOVERY_SECONDS: float = 0.18
const RETREAT_SECONDS: float = 0.16
const ATTACK_TWITCH_SCALE: Vector2 = Vector2(1.12, 0.90)

# ============================================================================
# EXPORTED VARIABLES
# ============================================================================

@export var max_health: int = 2
@export var gravity: float = 1100.0
@export var jump_velocity: float = -360.0
@export var detection_radius: float = 260.0
@export var attack_range: float = 22.0
@export var move_speed: float = 112.0
@export var chase_speed: float = 180.0
@export var retreat_speed: float = 140.0
@export var attack_damage: int = 4
@export var attack_cooldown: float = 0.50
@export var blocked_jump_chance: float = 0.62
@export var xp_orb_value: int = 3
@export var elite_health_bonus: int = 1
@export var elite_speed_bonus_multiplier: float = 1.16
@export var elite_attack_speed_bonus_multiplier: float = 0.84
@export var elite_scale_bonus: float = 1.10
@export var elite_attack_damage_bonus: int = 1

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
var _retreat_timer: float = 0.0
var _hit_flash_timer: float = 0.0
var _death_flash_timer: float = 0.0
var _is_dying: bool = false
var _is_elite: bool = false
var _elite_type: StringName = &""
var _elite_modifiers_applied: bool = false
var _proc_shock_timer: float = 0.0
var _proc_burn_timer: float = 0.0
var _proc_burn_tick_timer: float = 0.0
var _proc_burn_damage: int = 0
var _proc_feedback_timer: float = 0.0
var _counterplay_chase_speed_multiplier: float = 1.0
var _counterplay_retreat_speed_multiplier: float = 1.0
var _counterplay_attack_cooldown_multiplier: float = 1.0
var _counterplay_attack_damage_bonus: int = 0
var _counterplay_attack_range_bonus: float = 0.0
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _player: Node2D = null
var _debug_timer: float = 0.0

# ============================================================================
# GODOT LIFECYCLE
# ============================================================================

func _ready() -> void:
	add_to_group("enemy")
	add_to_group("swarm_enemy")
	_apply_elite_modifiers()
	_health = max_health
	if _is_elite:
		add_to_group("elite")
	_rng.randomize()
	_schedule_next_idle_turn()
	_update_raycast_direction()

func _physics_process(delta: float) -> void:
	_update_timers(delta)
	_update_proc_timers(delta)
	_update_visuals()

	if _is_dying:
		_update_death_state()
		return

	_refresh_player_reference()
	_update_ai_state()
	_apply_gravity(delta)
	_apply_movement()
	_handle_obstacles()
	move_and_slide()
	_resolve_contact_damage()
	_update_debug(delta)

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

	if _retreat_timer > 0.0:
		_state = STATE_RETREAT
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

	_state = STATE_IDLE
	_attack_pending = false
	_update_idle_direction()

func _update_idle_direction() -> void:
	if _idle_turn_timer > 0.0:
		return

	if _rng.randf() < 0.45:
		_idle_direction *= -1
	else:
		_idle_direction = 0

	_schedule_next_idle_turn()

func _schedule_next_idle_turn() -> void:
	_idle_turn_timer = _rng.randf_range(IDLE_TURN_MIN, IDLE_TURN_MAX)

func _desired_direction() -> int:
	if _player == null:
		return _idle_direction

	if _state == STATE_CHASE:
		return 1 if _player.global_position.x > global_position.x else -1

	if _state == STATE_RETREAT:
		return -1 if _player.global_position.x > global_position.x else 1

	if _state == STATE_ATTACK:
		return 0

	return _idle_direction

# ============================================================================
# MOVEMENT
# ============================================================================

func _update_timers(delta: float) -> void:
	_idle_turn_timer = max(_idle_turn_timer - delta, 0.0)
	_attack_cooldown_timer = max(_attack_cooldown_timer - delta, 0.0)
	_attack_windup_timer = max(_attack_windup_timer - delta, 0.0)
	_retreat_timer = max(_retreat_timer - delta, 0.0)
	_hit_flash_timer = max(_hit_flash_timer - delta, 0.0)
	_death_flash_timer = max(_death_flash_timer - delta, 0.0)

func _update_proc_timers(delta: float) -> void:
	_proc_shock_timer = max(_proc_shock_timer - delta, 0.0)
	_proc_burn_timer = max(_proc_burn_timer - delta, 0.0)
	_proc_feedback_timer = max(_proc_feedback_timer - delta, 0.0)

	if _proc_burn_timer <= 0.0:
		_proc_burn_tick_timer = 0.0
		return

	_proc_burn_tick_timer -= delta
	if _proc_burn_tick_timer > 0.0:
		return

	_proc_burn_tick_timer = SWARM_BURN_TICK_SECONDS
	if _proc_burn_damage > 0:
		take_projectile_hit(_proc_burn_damage, Vector2.ZERO)

func _apply_gravity(delta: float) -> void:
	if is_on_floor() and velocity.y > 0.0:
		velocity.y = 0.0
		return

	velocity.y += gravity * delta

func _apply_movement() -> void:
	var direction: int = _desired_direction()
	var target_speed: float = 0.0
	var acceleration: float = 24.0
	var proc_speed_multiplier: float = _current_proc_speed_multiplier()

	if _state == STATE_IDLE:
		target_speed = direction * move_speed * proc_speed_multiplier
		acceleration = 18.0
	elif _state == STATE_CHASE:
		target_speed = direction * chase_speed * _counterplay_chase_speed_multiplier * proc_speed_multiplier
		acceleration = 28.0
	elif _state == STATE_RETREAT:
		target_speed = direction * retreat_speed * _counterplay_retreat_speed_multiplier * proc_speed_multiplier
		acceleration = 30.0
	elif _state == STATE_ATTACK:
		if _attack_windup_timer > 0.0:
			target_speed = 0.0
			acceleration = 36.0
		elif _attack_cooldown_timer > 0.0:
			target_speed = 0.0
			acceleration = 24.0
		else:
			target_speed = direction * chase_speed * proc_speed_multiplier
			acceleration = 28.0

	velocity.x = move_toward(velocity.x, target_speed, acceleration)

	if direction != 0:
		_facing_direction = direction
		_update_raycast_direction()

	if _state == STATE_CHASE and is_on_floor() and _rng.randf() < 0.12:
		velocity.y = jump_velocity

func _current_attack_range() -> float:
	return attack_range + _counterplay_attack_range_bonus

	if _state == STATE_RETREAT and is_on_floor() and _rng.randf() < 0.10:
		velocity.y = jump_velocity

	if _state == STATE_ATTACK and _attack_windup_timer > 0.0 and is_on_floor() and _rng.randf() < 0.20:
		velocity.y = jump_velocity

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

	if is_on_floor() and (hit_wall or no_floor_ahead) and _rng.randf() <= blocked_jump_chance:
		velocity.y = jump_velocity

func _update_raycast_direction() -> void:
	var horizontal_offset: float = 18.0 * _facing_direction
	wall_ray_cast.target_position = Vector2(horizontal_offset, 0.0)
	ledge_ray_cast.target_position = Vector2(16.0 * _facing_direction, 28.0)

# ============================================================================
# ATTACK
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

	var distance_to_player: float = global_position.distance_to(_player.global_position)
	if distance_to_player > attack_range:
		return

	if not _attack_pending:
		_attack_pending = true
		_attack_windup_timer = ATTACK_WINDUP_SECONDS
		_hit_flash_timer = max(_hit_flash_timer, ATTACK_WINDUP_SECONDS)
		return

	if _attack_windup_timer > 0.0:
		return

	if _player.has_method("apply_contact_damage"):
		_player.apply_contact_damage(attack_damage + _counterplay_attack_damage_bonus, global_position)

	_attack_cooldown_timer = attack_cooldown * _counterplay_attack_cooldown_multiplier * _current_proc_attack_cooldown_multiplier() + ATTACK_RECOVERY_SECONDS
	_attack_pending = false
	_retreat_timer = RETREAT_SECONDS
	_state = STATE_RETREAT
	velocity.x *= 0.35

func take_projectile_hit(damage: int, knockback: Vector2) -> void:
	if _is_dying:
		return

	_health = max(_health - damage, 0)
	velocity.x = knockback.x
	velocity.y = min(velocity.y, knockback.y * 0.25)
	_hit_flash_timer = 0.08

	if _health > 0:
		return

	_start_death_feedback()

func get_current_health() -> int:
	return _health

func _start_death_feedback() -> void:
	_is_dying = true
	_spawn_xp_orb()
	_death_flash_timer = 0.12
	velocity = Vector2.ZERO
	_collision_enabled(false)
	wall_ray_cast.enabled = false
	ledge_ray_cast.enabled = false

func apply_projectile_proc(proc_kind: StringName, proc_strength: int, source_position: Vector2) -> void:
	if _is_dying:
		return

	match proc_kind:
		SWARM_PROC_KIND_SHOCK:
			_proc_shock_timer = max(_proc_shock_timer, SWARM_SHOCK_DURATION_SECONDS + float(max(proc_strength - 1, 0)) * 0.06)
			_proc_feedback_timer = max(_proc_feedback_timer, 0.14)
		SWARM_PROC_KIND_BURN:
			_proc_burn_timer = max(_proc_burn_timer, SWARM_BURN_DURATION_SECONDS + float(max(proc_strength - 1, 0)) * 0.05)
			_proc_burn_damage = max(_proc_burn_damage, max(1, int(ceil(float(max(proc_strength, 1)) * SWARM_BURN_DAMAGE_RATIO))))
			_proc_burn_tick_timer = SWARM_BURN_TICK_SECONDS * 0.5
			_proc_feedback_timer = max(_proc_feedback_timer, 0.12)
		SWARM_PROC_KIND_CHAIN:
			_apply_chain_proc(source_position, max(1, int(ceil(float(max(proc_strength, 1)) * SWARM_CHAIN_DAMAGE_RATIO))))
			_proc_feedback_timer = max(_proc_feedback_timer, 0.10)
		_:
			pass

func _apply_chain_proc(source_position: Vector2, chain_damage: int) -> void:
	var nearest_enemy: Node2D = null
	var nearest_distance: float = SWARM_CHAIN_RADIUS

	for enemy_variant: Variant in get_tree().get_nodes_in_group("enemy"):
		var enemy_node: Node2D = enemy_variant as Node2D
		if enemy_node == null or enemy_node == self or not is_instance_valid(enemy_node):
			continue

		if enemy_node.is_in_group("boss"):
			continue

		var distance_to_enemy: float = enemy_node.global_position.distance_to(source_position)
		if distance_to_enemy > nearest_distance:
			continue

		nearest_distance = distance_to_enemy
		nearest_enemy = enemy_node

	if nearest_enemy == null or not nearest_enemy.has_method("take_projectile_hit"):
		return

	nearest_enemy.call("take_projectile_hit", chain_damage, Vector2.ZERO)

func _current_proc_speed_multiplier() -> float:
	if _proc_shock_timer <= 0.0:
		return 1.0

	return SWARM_SHOCK_MOVE_MULTIPLIER

func _current_proc_attack_cooldown_multiplier() -> float:
	if _proc_shock_timer <= 0.0:
		return 1.0

	return SWARM_SHOCK_ATTACK_MULTIPLIER

func _blend_proc_color(base_color: Color, proc_color: Color, blend_amount: float) -> Color:
	return base_color.lerp(proc_color, blend_amount)

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

# ============================================================================
# VISUALS
# ============================================================================

func _update_visuals() -> void:
	sprite.flip_h = _facing_direction > 0

	var speed_ratio: float = clamp(abs(velocity.x) / max(chase_speed, 1.0), 0.0, 1.0)
	var base_scale: Vector2 = Vector2(
		1.0 + speed_ratio * 0.10,
		1.0 - speed_ratio * 0.06
	)
	if _state == STATE_ATTACK and _attack_windup_timer > 0.0:
		var windup_ratio: float = clamp(_attack_windup_timer / ATTACK_WINDUP_SECONDS, 0.0, 1.0)
		base_scale = Vector2(
			base_scale.x * lerp(1.0, ATTACK_TWITCH_SCALE.x, windup_ratio),
			base_scale.y * lerp(1.0, ATTACK_TWITCH_SCALE.y, windup_ratio)
		)
	elif _state == STATE_ATTACK and _attack_cooldown_timer > 0.0:
		base_scale = Vector2(base_scale.x * 1.08, base_scale.y * 0.95)

	sprite.scale = _apply_elite_scale(base_scale)
	sprite.self_modulate = _tint_elite_color(_current_visual_color())

func _current_visual_color() -> Color:
	if _death_flash_timer > 0.0:
		return HIT_FLASH_COLOR

	if _hit_flash_timer > 0.0:
		return HIT_FLASH_COLOR

	if _state == STATE_ATTACK and _attack_windup_timer > 0.0:
		return Color(1.0, 0.96, 0.38, 1.0)

	if _state == STATE_ATTACK:
		if _elite_type == ELITE_VOLTAIC:
			return VOLTAIC_ATTACK_COLOR
		return ATTACK_COLOR

	if _state == STATE_RETREAT:
		return RETREAT_COLOR

	if _proc_burn_timer > 0.0:
		return _blend_proc_color(IDLE_COLOR, SWARM_BURN_TINT, 0.20)

	if _proc_shock_timer > 0.0:
		return _blend_proc_color(IDLE_COLOR, SWARM_SHOCK_TINT, 0.18)

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
			chase_speed *= elite_speed_bonus_multiplier
			retreat_speed *= elite_speed_bonus_multiplier
			attack_cooldown *= elite_attack_speed_bonus_multiplier
			attack_damage += 1
		ELITE_TITAN:
			max_health += elite_health_bonus * 2
			move_speed *= 0.82
			chase_speed *= 0.82
			retreat_speed *= 0.86
		ELITE_VOLTAIC:
			max_health += elite_health_bonus
			attack_damage += elite_attack_damage_bonus
			attack_cooldown *= 0.88
		_:
			_is_elite = false
			_elite_type = &""

# ============================================================================
# COUNTERPLAY
# ============================================================================

func configure_counterplay(player_build_identity: StringName) -> void:
	_counterplay_chase_speed_multiplier = 1.0
	_counterplay_retreat_speed_multiplier = 1.0
	_counterplay_attack_cooldown_multiplier = 1.0
	_counterplay_attack_damage_bonus = 0
	_counterplay_attack_range_bonus = 0.0

	match player_build_identity:
		&"mobility":
			_counterplay_chase_speed_multiplier = 1.08
			_counterplay_retreat_speed_multiplier = 1.04
			_counterplay_attack_range_bonus = 2.0
		&"aggression":
			_counterplay_chase_speed_multiplier = 1.04
			_counterplay_attack_cooldown_multiplier = 0.94
			_counterplay_attack_damage_bonus = 1
		&"ranged":
			_counterplay_chase_speed_multiplier = 1.09
			_counterplay_retreat_speed_multiplier = 1.02
			_counterplay_attack_range_bonus = 2.0
		&"momentum":
			_counterplay_chase_speed_multiplier = 1.06
			_counterplay_attack_cooldown_multiplier = 0.92
			_counterplay_attack_damage_bonus = 1

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
			return Vector2(1.03, 1.03)
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
# DEBUG
# ============================================================================

func _update_debug(delta: float) -> void:
	_debug_timer -= delta
	if _debug_timer > 0.0:
		return

	_debug_timer = 4.0
	print(
		"SwarmEnemy state=%s health=%d speed=%.2f retreat=%.2f elite=%s" % [
			_state,
			_health,
			abs(velocity.x),
			_retreat_timer,
			_elite_type
		]
	)
