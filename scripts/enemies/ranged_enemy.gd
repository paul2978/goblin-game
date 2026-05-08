extends CharacterBody2D

# ============================================================================
# CONSTANTS
# ============================================================================

const STATE_IDLE: StringName = &"idle"
const STATE_CHASE: StringName = &"chase"
const STATE_STRAFE: StringName = &"strafe"
const STATE_ATTACK: StringName = &"attack"
const STATE_RETREAT: StringName = &"retreat"
const XP_ORB_SCENE_PATH: String = "res://scenes/pickups/xp_orb.tscn"
const ELITE_BERSERKER: StringName = &"berserker"
const ELITE_TITAN: StringName = &"titan"
const ELITE_VOLTAIC: StringName = &"voltaic"
const PROJECTILE_OFFSET: Vector2 = Vector2(22.0, -15.0)
const IDLE_COLOR: Color = Color(0.28, 0.22, 0.50, 1.0)
const CHASE_COLOR: Color = Color(0.40, 0.34, 0.75, 1.0)
const STRAFE_COLOR: Color = Color(0.52, 0.50, 0.90, 1.0)
const ATTACK_COLOR: Color = Color(0.84, 0.74, 1.0, 1.0)
const RETREAT_COLOR: Color = Color(0.62, 0.24, 0.96, 1.0)
const BERSERKER_TINT: Color = Color(1.0, 0.54, 0.28, 1.0)
const TITAN_TINT: Color = Color(0.24, 0.18, 0.34, 1.0)
const VOLTAIC_TINT: Color = Color(0.54, 0.84, 1.0, 1.0)
const VOLTAIC_ATTACK_COLOR: Color = Color(0.94, 0.99, 1.0, 1.0)
const HIT_FLASH_COLOR: Color = Color(1.0, 1.0, 1.0, 1.0)
const PROC_KIND_SHOCK: StringName = &"shock"
const PROC_KIND_BURN: StringName = &"burn"
const PROC_KIND_CHAIN: StringName = &"chain"
const PROC_SHOCK_SECONDS: float = 0.60
const PROC_BURN_SECONDS: float = 1.00
const PROC_BURN_TICK_SECONDS: float = 0.34
const PROC_SHOCK_MOVE_MULTIPLIER: float = 0.84
const PROC_SHOCK_ATTACK_MULTIPLIER: float = 1.14
const PROC_BURN_DAMAGE_RATIO: float = 0.42
const PROC_CHAIN_RADIUS: float = 112.0
const PROC_CHAIN_DAMAGE_RATIO: float = 0.50
const PROC_SHOCK_TINT: Color = Color(0.58, 0.92, 1.0, 1.0)
const PROC_BURN_TINT: Color = Color(1.0, 0.66, 0.30, 1.0)
const PROC_CHAIN_TINT: Color = Color(0.80, 1.0, 0.90, 1.0)
const IDLE_TURN_MIN: float = 0.90
const IDLE_TURN_MAX: float = 2.10
const ATTACK_WINDUP_SECONDS: float = 0.22
const ATTACK_RECOVERY_SECONDS: float = 0.28
const STRAFE_TURN_SECONDS: float = 0.85
const ATTACK_AIM_SCALE: Vector2 = Vector2(1.14, 0.95)
const ATTACK_FLASH_SCALE: Vector2 = Vector2(1.18, 0.90)

# ============================================================================
# EXPORTED VARIABLES
# ============================================================================

@export var max_health: int = 2
@export var gravity: float = 1100.0
@export var jump_velocity: float = -290.0
@export var detection_radius: float = 340.0
@export var preferred_range: float = 200.0
@export var preferred_range_tolerance: float = 60.0
@export var retreat_range: float = 150.0
@export var move_speed: float = 70.0
@export var chase_speed: float = 108.0
@export var strafe_speed: float = 44.0
@export var retreat_speed: float = 96.0
@export var attack_damage: int = 6
@export var projectile_speed: float = 330.0
@export var attack_cooldown: float = 1.20
@export var projectile_xp_value: int = 4
@export var elite_health_bonus: int = 1
@export var elite_speed_bonus_multiplier: float = 1.18
@export var elite_attack_speed_bonus_multiplier: float = 0.82
@export var elite_scale_bonus: float = 1.10
@export var elite_projectile_speed_bonus_multiplier: float = 1.24
@export var elite_attack_damage_bonus: int = 1

# ============================================================================
# NODE REFERENCES
# ============================================================================

@onready var _sprite: Sprite2D = $Sprite2D
@onready var _wall_ray_cast: RayCast2D = $WallRayCast2D
@onready var _ledge_ray_cast: RayCast2D = $LedgeRayCast2D

# ============================================================================
# RUNTIME VARIABLES
# ============================================================================

var _health: int = 0
var _state: StringName = STATE_IDLE
var _facing_direction: int = -1
var _idle_direction: int = -1
var _strafe_direction: int = 1
var _idle_turn_timer: float = 0.0
var _strafe_turn_timer: float = 0.0
var _attack_cooldown_timer: float = 0.0
var _attack_windup_timer: float = 0.0
var _attack_primed: bool = false
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
var _counterplay_preferred_range_bonus: float = 0.0
var _counterplay_chase_speed_multiplier: float = 1.0
var _counterplay_strafe_speed_multiplier: float = 1.0
var _counterplay_retreat_speed_multiplier: float = 1.0
var _counterplay_projectile_speed_multiplier: float = 1.0
var _counterplay_attack_cooldown_multiplier: float = 1.0
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _player: Node2D = null

# ============================================================================
# GODOT LIFECYCLE
# ============================================================================

func _ready() -> void:
	add_to_group("enemy")
	add_to_group("ranged_enemy")
	_apply_elite_modifiers()
	_health = max_health
	if _is_elite:
		add_to_group("elite")
	_rng.randomize()
	_schedule_next_idle_turn()
	_schedule_next_strafe_turn()
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
	_apply_movement(delta)
	_handle_obstacles()
	move_and_slide()
	_resolve_ranged_attack()

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
		_attack_primed = false
		_update_idle_direction()
		return

	var distance_to_player: float = global_position.distance_to(_player.global_position)
	if distance_to_player > detection_radius:
		_state = STATE_IDLE
		_attack_primed = false
		_update_idle_direction()
		return

	if distance_to_player <= retreat_range:
		_state = STATE_RETREAT
		_attack_primed = false
		return

	var inside_preferred_band: bool = abs(distance_to_player - _effective_preferred_range()) <= preferred_range_tolerance
	if inside_preferred_band:
		if _attack_cooldown_timer <= 0.0:
			_state = STATE_ATTACK
			return

		_state = STATE_STRAFE
		_attack_primed = false
		return

	if distance_to_player > preferred_range:
		_state = STATE_CHASE
		_attack_primed = false
		return

	_state = STATE_STRAFE
	_attack_primed = false

func _update_idle_direction() -> void:
	if _idle_turn_timer > 0.0:
		return

	if _rng.randf() < 0.5:
		_idle_direction = -_idle_direction
	else:
		_idle_direction = 0

	_schedule_next_idle_turn()

func _schedule_next_idle_turn() -> void:
	_idle_turn_timer = _rng.randf_range(IDLE_TURN_MIN, IDLE_TURN_MAX)

func _schedule_next_strafe_turn() -> void:
	_strafe_turn_timer = STRAFE_TURN_SECONDS
	if _rng.randf() < 0.5:
		_strafe_direction = -1
	else:
		_strafe_direction = 1

func _desired_direction() -> int:
	if _player == null:
		return _idle_direction

	if _state == STATE_CHASE:
		return 1 if _player.global_position.x > global_position.x else -1

	if _state == STATE_RETREAT:
		return -1 if _player.global_position.x > global_position.x else 1

	if _state == STATE_STRAFE:
		return _strafe_direction

	if _state == STATE_ATTACK:
		return 0

	return _idle_direction

# ============================================================================
# MOVEMENT
# ============================================================================

func _update_timers(delta: float) -> void:
	_idle_turn_timer = max(_idle_turn_timer - delta, 0.0)
	_strafe_turn_timer = max(_strafe_turn_timer - delta, 0.0)
	_attack_cooldown_timer = max(_attack_cooldown_timer - delta, 0.0)
	_attack_windup_timer = max(_attack_windup_timer - delta, 0.0)
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

	_proc_burn_tick_timer = PROC_BURN_TICK_SECONDS
	if _proc_burn_damage > 0:
		take_projectile_hit(_proc_burn_damage, Vector2.ZERO)

func _apply_gravity(delta: float) -> void:
	if is_on_floor() and velocity.y > 0.0:
		velocity.y = 0.0
		return

	velocity.y += gravity * delta

func _apply_movement(delta: float) -> void:
	var direction: int = _desired_direction()
	var target_speed: float = 0.0
	var proc_speed_multiplier: float = _current_proc_speed_multiplier()

	if _state == STATE_IDLE:
		target_speed = direction * move_speed * proc_speed_multiplier
	elif _state == STATE_CHASE:
		target_speed = direction * chase_speed * _counterplay_chase_speed_multiplier * proc_speed_multiplier
	elif _state == STATE_STRAFE:
		target_speed = direction * strafe_speed * _counterplay_strafe_speed_multiplier * proc_speed_multiplier
	elif _state == STATE_RETREAT:
		target_speed = direction * retreat_speed * _counterplay_retreat_speed_multiplier * proc_speed_multiplier

	velocity.x = move_toward(velocity.x, target_speed, 14.0)

	if direction != 0:
		_facing_direction = direction
		_update_raycast_direction()

	if _state == STATE_STRAFE and _strafe_turn_timer <= 0.0:
		_schedule_next_strafe_turn()

	if _state == STATE_ATTACK:
		velocity.x = move_toward(velocity.x, 0.0, 40.0 * delta)
		velocity.y = move_toward(velocity.y, 0.0, 40.0 * delta)

func _handle_obstacles() -> void:
	if _facing_direction == 0:
		return

	var hit_wall: bool = _wall_ray_cast.is_colliding()
	var no_floor_ahead: bool = not _ledge_ray_cast.is_colliding()
	if not hit_wall and not no_floor_ahead:
		return

	_facing_direction *= -1
	_idle_direction = _facing_direction
	_strafe_direction = _facing_direction
	_update_raycast_direction()
	_schedule_next_idle_turn()
	_schedule_next_strafe_turn()

	if is_on_floor() and hit_wall and _rng.randf() <= 0.25:
		velocity.y = jump_velocity

func _update_raycast_direction() -> void:
	var horizontal_offset: float = 18.0 * _facing_direction
	_wall_ray_cast.target_position = Vector2(horizontal_offset, 0.0)
	_ledge_ray_cast.target_position = Vector2(16.0 * _facing_direction, 28.0)

# ============================================================================
# RANGED COMBAT
# ============================================================================

func _resolve_ranged_attack() -> void:
	if _player == null:
		return

	if _state != STATE_ATTACK:
		return

	if not _attack_primed:
		_attack_primed = true
		_attack_windup_timer = ATTACK_WINDUP_SECONDS
		_play_world_audio_cue("ranged_windup", 0.9)
		return

	if _attack_windup_timer > 0.0:
		return

	_fire_projectile()
	_attack_cooldown_timer = attack_cooldown * _counterplay_attack_cooldown_multiplier * _current_proc_attack_cooldown_multiplier() + ATTACK_RECOVERY_SECONDS
	_attack_primed = false
	_state = STATE_STRAFE

func _fire_projectile() -> void:
	var projectile: EnemyProjectile = EnemyProjectile.new()
	var spawn_root: Node = get_tree().current_scene
	var spawn_offset: Vector2 = Vector2(
		PROJECTILE_OFFSET.x * _facing_direction,
		PROJECTILE_OFFSET.y
	)

	if spawn_root.has_node("Gameplay"):
		spawn_root = spawn_root.get_node("Gameplay")

	projectile.setup_projectile(global_position + spawn_offset, _player.global_position)
	projectile.speed = projectile_speed * _counterplay_projectile_speed_multiplier
	projectile.damage = attack_damage
	spawn_root.add_child(projectile)

func _effective_preferred_range() -> float:
	return preferred_range + _counterplay_preferred_range_bonus

# ============================================================================
# PROJECTILES
# ============================================================================

func take_projectile_hit(damage: int, knockback: Vector2) -> void:
	if _is_dying:
		return

	_health = max(_health - damage, 0)
	velocity.x = knockback.x
	velocity.y = min(velocity.y, knockback.y * 0.2)
	_hit_flash_timer = 0.10

	if _health > 0:
		return

	_start_death_feedback()

func get_current_health() -> int:
	return _health

func _start_death_feedback() -> void:
	_is_dying = true
	_attack_primed = false
	_spawn_xp_orb()
	_death_flash_timer = 0.12
	velocity = Vector2.ZERO
	_collision_enabled(false)
	_wall_ray_cast.enabled = false
	_ledge_ray_cast.enabled = false

func apply_projectile_proc(proc_kind: StringName, proc_strength: int, source_position: Vector2) -> void:
	if _is_dying:
		return

	match proc_kind:
		PROC_KIND_SHOCK:
			_proc_shock_timer = max(_proc_shock_timer, PROC_SHOCK_SECONDS + float(max(proc_strength - 1, 0)) * 0.06)
			_proc_feedback_timer = max(_proc_feedback_timer, 0.14)
		PROC_KIND_BURN:
			_proc_burn_timer = max(_proc_burn_timer, PROC_BURN_SECONDS + float(max(proc_strength - 1, 0)) * 0.05)
			_proc_burn_damage = max(_proc_burn_damage, max(1, int(ceil(float(max(proc_strength, 1)) * PROC_BURN_DAMAGE_RATIO))))
			_proc_burn_tick_timer = PROC_BURN_TICK_SECONDS * 0.5
			_proc_feedback_timer = max(_proc_feedback_timer, 0.12)
		PROC_KIND_CHAIN:
			_apply_chain_proc(source_position, max(1, int(ceil(float(max(proc_strength, 1)) * PROC_CHAIN_DAMAGE_RATIO))))
			_proc_feedback_timer = max(_proc_feedback_timer, 0.10)
		_:
			pass

func _apply_chain_proc(source_position: Vector2, chain_damage: int) -> void:
	var nearest_enemy: Node2D = null
	var nearest_distance: float = PROC_CHAIN_RADIUS

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

	return PROC_SHOCK_MOVE_MULTIPLIER

func _current_proc_attack_cooldown_multiplier() -> float:
	if _proc_shock_timer <= 0.0:
		return 1.0

	return PROC_SHOCK_ATTACK_MULTIPLIER

func _play_world_audio_cue(cue_name: String, intensity: float = 1.0) -> void:
	var current_scene: Node = get_tree().current_scene
	if current_scene == null or not is_instance_valid(current_scene):
		return

	if current_scene.has_method("play_world_audio_cue"):
		current_scene.call("play_world_audio_cue", cue_name, intensity)

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
		orb_instance.setup_orb(global_position, projectile_xp_value)

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
	var sprite_scale: Vector2 = Vector2.ONE
	if _state == STATE_STRAFE:
		sprite_scale += Vector2(0.05, 0.03)
	elif _state == STATE_ATTACK:
		sprite_scale += Vector2(0.08, 0.05)
		if _attack_windup_timer > 0.0:
			var windup_ratio: float = clamp(_attack_windup_timer / ATTACK_WINDUP_SECONDS, 0.0, 1.0)
			sprite_scale = Vector2(
				sprite_scale.x * lerp(1.0, ATTACK_AIM_SCALE.x, windup_ratio),
				sprite_scale.y * lerp(1.0, ATTACK_AIM_SCALE.y, windup_ratio)
			)
		elif _attack_cooldown_timer > 0.0:
			sprite_scale = Vector2(
				sprite_scale.x * ATTACK_FLASH_SCALE.x,
				sprite_scale.y * ATTACK_FLASH_SCALE.y
			)

	_sprite.flip_h = _facing_direction > 0
	_sprite.scale = _apply_elite_scale(sprite_scale)
	_sprite.self_modulate = _tint_elite_color(_current_visual_color())

func _current_visual_color() -> Color:
	if _death_flash_timer > 0.0:
		return HIT_FLASH_COLOR

	if _hit_flash_timer > 0.0:
		return HIT_FLASH_COLOR

	if _state == STATE_ATTACK and _attack_windup_timer > 0.0:
		return Color(0.96, 0.97, 1.0, 1.0)

	if _state == STATE_ATTACK:
		if _elite_type == ELITE_VOLTAIC:
			return VOLTAIC_ATTACK_COLOR
		return ATTACK_COLOR

	if _state == STATE_RETREAT:
		return RETREAT_COLOR

	if _state == STATE_STRAFE:
		return STRAFE_COLOR

	if _state == STATE_CHASE:
		return CHASE_COLOR

	if _proc_burn_timer > 0.0:
		return _blend_proc_color(IDLE_COLOR, PROC_BURN_TINT, 0.20)

	if _proc_shock_timer > 0.0:
		return _blend_proc_color(IDLE_COLOR, PROC_SHOCK_TINT, 0.18)

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
			chase_speed *= elite_speed_bonus_multiplier
			strafe_speed *= elite_speed_bonus_multiplier
			retreat_speed *= elite_speed_bonus_multiplier
			attack_cooldown *= elite_attack_speed_bonus_multiplier
		ELITE_TITAN:
			max_health += elite_health_bonus * 2
			chase_speed *= 0.84
			strafe_speed *= 0.84
			retreat_speed *= 0.90
		ELITE_VOLTAIC:
			max_health += elite_health_bonus
			projectile_speed *= elite_projectile_speed_bonus_multiplier
			attack_damage += elite_attack_damage_bonus
			attack_cooldown *= 0.90
		_:
			_is_elite = false
			_elite_type = &""

# ============================================================================
# COUNTERPLAY
# ============================================================================

func configure_counterplay(player_build_identity: StringName) -> void:
	_counterplay_preferred_range_bonus = 0.0
	_counterplay_chase_speed_multiplier = 1.0
	_counterplay_strafe_speed_multiplier = 1.0
	_counterplay_retreat_speed_multiplier = 1.0
	_counterplay_projectile_speed_multiplier = 1.0
	_counterplay_attack_cooldown_multiplier = 1.0

	match player_build_identity:
		&"mobility":
			_counterplay_preferred_range_bonus = 16.0
			_counterplay_chase_speed_multiplier = 1.03
			_counterplay_strafe_speed_multiplier = 1.05
			_counterplay_retreat_speed_multiplier = 1.04
			_counterplay_projectile_speed_multiplier = 1.05
		&"aggression":
			_counterplay_preferred_range_bonus = 8.0
			_counterplay_chase_speed_multiplier = 1.04
			_counterplay_strafe_speed_multiplier = 1.02
			_counterplay_projectile_speed_multiplier = 1.04
			_counterplay_attack_cooldown_multiplier = 0.96
		&"ranged":
			_counterplay_preferred_range_bonus = 12.0
			_counterplay_chase_speed_multiplier = 1.02
			_counterplay_strafe_speed_multiplier = 1.06
			_counterplay_retreat_speed_multiplier = 1.05
			_counterplay_projectile_speed_multiplier = 1.08
		&"momentum":
			_counterplay_preferred_range_bonus = 6.0
			_counterplay_chase_speed_multiplier = 1.03
			_counterplay_strafe_speed_multiplier = 1.03
			_counterplay_projectile_speed_multiplier = 1.03
			_counterplay_attack_cooldown_multiplier = 0.97

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
