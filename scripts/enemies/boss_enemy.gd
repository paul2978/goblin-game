extends "res://scripts/enemies/ranged_enemy.gd"

# ============================================================================
# CONSTANTS
# ============================================================================

const BOSS_ROLE_PURSUER: StringName = &"pursuer"
const BOSS_ROLE_CONTROL: StringName = &"control"
const BOSS_ROLE_SWARM: StringName = &"swarm"
const BOSS_SURVIVAL_STATE_BUILDUP: StringName = &"buildup"
const BOSS_SURVIVAL_STATE_PRESSURE: StringName = &"pressure"
const BOSS_SURVIVAL_STATE_CLIMAX: StringName = &"climax"
const STATE_HUNT: StringName = &"hunt"
const STATE_WINDUP: StringName = &"windup"
const STATE_CHARGE: StringName = &"charge"
const STATE_RECOVER: StringName = &"recover"
const HUNT_COLOR: Color = Color(0.28, 0.20, 0.44, 1.0)
const WINDUP_COLOR: Color = Color(0.93, 0.94, 1.0, 1.0)
const CHARGE_COLOR: Color = Color(1.0, 0.76, 0.46, 1.0)
const RECOVER_COLOR: Color = Color(0.48, 0.24, 0.60, 1.0)
const CONTROL_HUNT_COLOR: Color = Color(0.18, 0.44, 0.56, 1.0)
const CONTROL_WINDUP_COLOR: Color = Color(0.86, 0.97, 1.0, 1.0)
const CONTROL_CHARGE_COLOR: Color = Color(0.40, 0.90, 1.0, 1.0)
const CONTROL_RECOVER_COLOR: Color = Color(0.16, 0.30, 0.42, 1.0)
const SWARM_HUNT_COLOR: Color = Color(0.40, 0.64, 0.14, 1.0)
const SWARM_WINDUP_COLOR: Color = Color(0.92, 1.0, 0.60, 1.0)
const SWARM_CHARGE_COLOR: Color = Color(0.68, 1.0, 0.26, 1.0)
const SWARM_RECOVER_COLOR: Color = Color(0.20, 0.32, 0.12, 1.0)
const BOSS_PROC_KIND_SHOCK: StringName = &"shock"
const BOSS_PROC_KIND_BURN: StringName = &"burn"
const BOSS_PROC_KIND_CHAIN: StringName = &"chain"
const BOSS_SHOCK_DURATION_SECONDS: float = 0.50
const BOSS_BURN_DURATION_SECONDS: float = 0.90
const BOSS_BURN_TICK_SECONDS: float = 0.36
const BOSS_SHOCK_MOVE_MULTIPLIER: float = 0.88
const BOSS_SHOCK_ATTACK_MULTIPLIER: float = 1.10
const BOSS_BURN_DAMAGE_RATIO: float = 0.38
const BOSS_CHAIN_RADIUS: float = 116.0
const BOSS_CHAIN_DAMAGE_RATIO: float = 0.45
const BOSS_SHOCK_TINT: Color = Color(0.62, 0.94, 1.0, 1.0)
const BOSS_BURN_TINT: Color = Color(1.0, 0.70, 0.34, 1.0)
const BOSS_CHAIN_TINT: Color = Color(0.84, 1.0, 0.92, 1.0)
const PHASE_TWO_THRESHOLD: float = 0.66
const PHASE_THREE_THRESHOLD: float = 0.33

# ============================================================================
# EXPORTED VARIABLES
# ============================================================================

@export var boss_health_bonus: int = 16
@export var boss_contact_damage_bonus: int = 6
@export var boss_xp_bonus: int = 8
@export var boss_hunt_speed_multiplier: float = 1.28
@export var boss_charge_speed_multiplier: float = 2.65
@export var boss_recovery_speed_multiplier: float = 0.58
@export var boss_charge_windup_seconds: float = 0.40
@export var boss_charge_seconds: float = 0.44
@export var boss_recovery_seconds: float = 0.72
@export var boss_charge_range: float = 170.0
@export var boss_contact_range: float = 52.0
@export var boss_phase_speed_bonus: float = 0.12
@export var boss_phase_damage_bonus: int = 2
@export var boss_phase_range_bonus: float = 18.0
@export var boss_phase_recovery_multiplier: float = 0.88
@export var boss_charge_jump_multiplier: float = 0.52
@export var boss_control_target_range: float = 208.0
@export var boss_control_close_range: float = 126.0
@export var boss_control_burst_seconds: float = 0.52
@export var boss_control_projectile_speed_multiplier: float = 0.78
@export var boss_control_projectile_lifetime: float = 2.15
@export var boss_control_lane_offset: float = 156.0
@export var boss_control_burst_count: int = 3
@export var boss_swarm_target_range: float = 190.0
@export var boss_swarm_close_range: float = 120.0
@export var boss_swarm_windup_seconds: float = 0.28
@export var boss_swarm_wave_seconds: float = 0.50
@export var boss_swarm_spawn_count: int = 2
@export var boss_swarm_spawn_count_bonus: int = 1
@export var boss_swarm_max_active_allies: int = 5
@export var boss_swarm_spawn_radius: float = 76.0

# ============================================================================
# RUNTIME VARIABLES
# ============================================================================

var _boss_role: StringName = BOSS_ROLE_PURSUER
var _boss_phase: int = 1
var _boss_intro_timer: float = 0.85
var _boss_charge_timer: float = 0.0
var _boss_recovery_timer: float = 0.0
var _boss_phase_flash_timer: float = 0.0
var _boss_phase_transition_timer: float = 0.0
var _boss_charge_direction: int = 1
var _boss_charge_has_hit: bool = false
var _boss_control_lane_direction: int = 1
var _boss_swarm_enemy_scene: PackedScene = null
var _boss_swarm_wave_direction: int = 1
var _boss_shock_timer: float = 0.0
var _boss_burn_timer: float = 0.0
var _boss_burn_tick_timer: float = 0.0
var _boss_burn_damage: int = 0
var _boss_feedback_timer: float = 0.0

# ============================================================================
# GODOT LIFECYCLE
# ============================================================================

func _ready() -> void:
	super._ready()
	add_to_group("boss")
	remove_from_group("ranged_enemy")

	max_health += boss_health_bonus
	attack_damage += boss_contact_damage_bonus
	projectile_xp_value += boss_xp_bonus
	_health = max_health
	_state = STATE_HUNT
	_boss_phase = 1
	_boss_intro_timer = 0.85
	_attack_cooldown_timer = 0.35
	_attack_primed = false
	_boss_control_lane_direction = 1
	_boss_swarm_wave_direction = 1
	_boss_swarm_enemy_scene = _load_swarm_enemy_scene()
	_update_raycast_direction()

# ============================================================================
# BOSS CONFIGURATION
# ============================================================================

func configure_boss(boss_role: StringName) -> void:
	if boss_role == &"":
		boss_role = BOSS_ROLE_PURSUER

	if boss_role != BOSS_ROLE_PURSUER and boss_role != BOSS_ROLE_CONTROL and boss_role != BOSS_ROLE_SWARM:
		return

	_boss_role = boss_role
	_boss_phase = 1
	_boss_swarm_wave_direction = 1
	_boss_phase_transition_timer = 0.0

func get_boss_role() -> StringName:
	return _boss_role

func get_boss_phase() -> int:
	return _boss_phase

func get_boss_survival_state() -> StringName:
	match _boss_phase:
		1:
			return BOSS_SURVIVAL_STATE_BUILDUP
		2:
			return BOSS_SURVIVAL_STATE_PRESSURE
		_:
			return BOSS_SURVIVAL_STATE_CLIMAX

# ============================================================================
# AI
# ============================================================================

func _update_timers(delta: float) -> void:
	super._update_timers(delta)
	_boss_intro_timer = max(_boss_intro_timer - delta, 0.0)
	_boss_charge_timer = max(_boss_charge_timer - delta, 0.0)
	_boss_recovery_timer = max(_boss_recovery_timer - delta, 0.0)
	_boss_phase_flash_timer = max(_boss_phase_flash_timer - delta, 0.0)
	_boss_phase_transition_timer = max(_boss_phase_transition_timer - delta, 0.0)
	_boss_shock_timer = max(_boss_shock_timer - delta, 0.0)
	_boss_burn_timer = max(_boss_burn_timer - delta, 0.0)
	_boss_feedback_timer = max(_boss_feedback_timer - delta, 0.0)

	if _boss_burn_timer <= 0.0:
		_boss_burn_tick_timer = 0.0
		return

	_boss_burn_tick_timer -= delta
	if _boss_burn_tick_timer > 0.0:
		return

	_boss_burn_tick_timer = BOSS_BURN_TICK_SECONDS
	if _boss_burn_damage > 0:
		take_projectile_hit(_boss_burn_damage, Vector2.ZERO)

func _update_ai_state() -> void:
	if _player == null:
		_state = STATE_HUNT
		_attack_primed = false
		return

	_update_boss_phase()
	var distance_to_player: float = global_position.distance_to(_player.global_position)

	if _boss_intro_timer > 0.0:
		_state = STATE_HUNT
		_attack_primed = false
		_sync_facing_to_player()
		return

	if _boss_charge_timer > 0.0:
		_state = STATE_CHARGE
		return

	if _boss_recovery_timer > 0.0:
		_state = STATE_RECOVER
		_attack_primed = false
		_sync_facing_to_player()
		return

	if _boss_role == BOSS_ROLE_CONTROL:
		_update_control_ai_state(distance_to_player)
		return

	if _boss_role == BOSS_ROLE_SWARM:
		_update_swarm_ai_state(distance_to_player)
		return

	if _attack_cooldown_timer <= 0.0 and distance_to_player <= _current_charge_range():
		_state = STATE_WINDUP
		if not _attack_primed:
			_attack_primed = true
			_attack_windup_timer = boss_charge_windup_seconds
			_boss_charge_has_hit = false
		_sync_facing_to_player()
		return

	_state = STATE_HUNT
	_attack_primed = false
	_sync_facing_to_player()

func _update_swarm_ai_state(distance_to_player: float) -> void:
	var target_range: float = _current_swarm_target_range()
	var close_range: float = _current_swarm_close_range()

	if _attack_cooldown_timer <= 0.0 and distance_to_player <= target_range + 48.0:
		_state = STATE_WINDUP
		if not _attack_primed:
			_attack_primed = true
			_attack_windup_timer = boss_swarm_windup_seconds
			_boss_charge_has_hit = false
		_sync_facing_to_player()
		return

	if distance_to_player < close_range:
		_state = STATE_RECOVER
		_attack_primed = false
		_sync_facing_to_player()
		return

	_state = STATE_HUNT
	_attack_primed = false
	_sync_facing_to_player()

func _update_control_ai_state(distance_to_player: float) -> void:
	var target_range: float = _current_control_target_range()
	var close_range: float = _current_control_close_range()
	var distance_error: float = distance_to_player - target_range

	if _attack_cooldown_timer <= 0.0 and abs(distance_error) <= 56.0:
		_state = STATE_WINDUP
		if not _attack_primed:
			_attack_primed = true
			_attack_windup_timer = boss_charge_windup_seconds * 0.92
			_boss_charge_has_hit = false
		_sync_facing_to_player()
		return

	if distance_to_player < close_range:
		_state = STATE_RECOVER
		_attack_primed = false
		_sync_facing_to_player()
		return

	_state = STATE_HUNT
	_attack_primed = false
	_sync_facing_to_player()

func _desired_direction() -> int:
	if _player == null:
		return 0

	if _boss_role == BOSS_ROLE_CONTROL:
		return _desired_control_direction()

	if _boss_role == BOSS_ROLE_SWARM:
		return _desired_swarm_direction()

	if _state == STATE_CHARGE:
		return _boss_charge_direction

	return 1 if _player.global_position.x > global_position.x else -1

func _desired_control_direction() -> int:
	if _player == null:
		return 0

	var distance_to_player: float = global_position.distance_to(_player.global_position)
	var target_range: float = _current_control_target_range()
	var close_range: float = _current_control_close_range()

	if _state == STATE_WINDUP:
		return 0

	if _state == STATE_CHARGE:
		return -1 if _player.global_position.x > global_position.x else 1

	if distance_to_player < close_range:
		return -1 if _player.global_position.x > global_position.x else 1

	if distance_to_player > target_range + 40.0:
		return 1 if _player.global_position.x > global_position.x else -1

	return _boss_control_lane_direction

func _desired_swarm_direction() -> int:
	if _player == null:
		return 0

	var distance_to_player: float = global_position.distance_to(_player.global_position)
	var target_range: float = _current_swarm_target_range()
	var close_range: float = _current_swarm_close_range()

	if _state == STATE_WINDUP:
		return 0

	if _state == STATE_CHARGE:
		return 0

	if distance_to_player < close_range:
		return -1 if _player.global_position.x > global_position.x else 1

	if distance_to_player > target_range + 48.0:
		return 1 if _player.global_position.x > global_position.x else -1

	return _boss_swarm_wave_direction

func _update_boss_phase() -> void:
	var previous_phase: int = _boss_phase
	var health_ratio: float = 1.0
	if max_health > 0:
		health_ratio = float(_health) / float(max_health)

	if health_ratio <= PHASE_THREE_THRESHOLD:
		_boss_phase = 3
	elif health_ratio <= PHASE_TWO_THRESHOLD:
		_boss_phase = 2
	else:
		_boss_phase = 1

	if _boss_phase != previous_phase:
		_boss_phase_flash_timer = 0.28
		_boss_phase_transition_timer = 0.40

func _sync_facing_to_player() -> void:
	if _player == null:
		return

	_facing_direction = 1 if _player.global_position.x > global_position.x else -1
	_update_raycast_direction()

# ============================================================================
# MOVEMENT
# ============================================================================

func _apply_movement(_delta: float) -> void:
	var direction: int = _desired_direction()
	var phase_speed_multiplier: float = _current_phase_speed_multiplier()
	var proc_speed_multiplier: float = _current_proc_speed_multiplier()
	var intro_speed_multiplier: float = 1.0
	if _boss_intro_timer > 0.0:
		intro_speed_multiplier = 0.58

	if _boss_role == BOSS_ROLE_CONTROL:
		_apply_control_movement(direction, phase_speed_multiplier, intro_speed_multiplier)
		return

	if _boss_role == BOSS_ROLE_SWARM:
		_apply_swarm_movement(direction, phase_speed_multiplier, intro_speed_multiplier)
		return

	match _state:
		STATE_HUNT:
			var hunt_speed: float = chase_speed * boss_hunt_speed_multiplier * phase_speed_multiplier * _counterplay_chase_speed_multiplier * intro_speed_multiplier * proc_speed_multiplier
			velocity.x = move_toward(velocity.x, float(direction) * hunt_speed, 36.0)
		STATE_WINDUP:
			velocity.x = move_toward(velocity.x, 0.0, 72.0)
			velocity.y = move_toward(velocity.y, 0.0, 48.0)
		STATE_CHARGE:
			velocity.x = float(_boss_charge_direction) * _current_charge_speed()
		STATE_RECOVER:
			var recover_speed: float = chase_speed * boss_recovery_speed_multiplier * phase_speed_multiplier * _counterplay_chase_speed_multiplier * intro_speed_multiplier * proc_speed_multiplier
			velocity.x = move_toward(velocity.x, float(direction) * recover_speed, 28.0)

	if direction != 0:
		_facing_direction = direction
		_update_raycast_direction()

func _apply_swarm_movement(direction: int, phase_speed_multiplier: float, intro_speed_multiplier: float) -> void:
	var proc_speed_multiplier: float = _current_proc_speed_multiplier()
	match _state:
		STATE_HUNT:
			var target_distance: float = _current_swarm_target_range()
			var distance_to_player: float = 0.0
			if _player != null:
				distance_to_player = global_position.distance_to(_player.global_position)

			var pressure_speed: float = chase_speed * 0.76 * phase_speed_multiplier * _counterplay_chase_speed_multiplier * intro_speed_multiplier * proc_speed_multiplier
			if distance_to_player < _current_swarm_close_range():
				pressure_speed *= 1.14
			elif distance_to_player > target_distance + 48.0:
				pressure_speed *= 1.08
			velocity.x = move_toward(velocity.x, float(direction) * pressure_speed, 24.0)
		STATE_WINDUP:
			velocity.x = move_toward(velocity.x, 0.0, 88.0)
			velocity.y = move_toward(velocity.y, 0.0, 56.0)
		STATE_CHARGE:
			velocity.x = move_toward(velocity.x, 0.0, 32.0)
		STATE_RECOVER:
			var retreat_direction: int = -1 if _player != null and _player.global_position.x > global_position.x else 1
			var swarm_retreat_speed: float = chase_speed * 0.72 * phase_speed_multiplier * _counterplay_chase_speed_multiplier * intro_speed_multiplier * proc_speed_multiplier
			velocity.x = move_toward(velocity.x, float(retreat_direction) * swarm_retreat_speed, 24.0)

	if direction != 0:
		_facing_direction = direction
		_update_raycast_direction()

func _apply_control_movement(direction: int, phase_speed_multiplier: float, intro_speed_multiplier: float) -> void:
	var proc_speed_multiplier: float = _current_proc_speed_multiplier()
	match _state:
		STATE_HUNT:
			var target_distance: float = _current_control_target_range()
			var distance_to_player: float = 0.0
			if _player != null:
				distance_to_player = global_position.distance_to(_player.global_position)

			var pressure_speed: float = chase_speed * 0.82 * phase_speed_multiplier * _counterplay_chase_speed_multiplier * intro_speed_multiplier * proc_speed_multiplier
			if distance_to_player < _current_control_close_range():
				pressure_speed *= 1.10
			elif distance_to_player > target_distance + 40.0:
				pressure_speed *= 1.05
			velocity.x = move_toward(velocity.x, float(direction) * pressure_speed, 28.0)
		STATE_WINDUP:
			velocity.x = move_toward(velocity.x, 0.0, 84.0)
			velocity.y = move_toward(velocity.y, 0.0, 50.0)
		STATE_CHARGE:
			velocity.x = move_toward(velocity.x, float(direction) * _current_control_burst_drift_speed(), 20.0)
		STATE_RECOVER:
			var retreat_direction: int = -1 if _player != null and _player.global_position.x > global_position.x else 1
			var control_retreat_speed: float = chase_speed * 0.78 * phase_speed_multiplier * _counterplay_chase_speed_multiplier * intro_speed_multiplier * proc_speed_multiplier
			velocity.x = move_toward(velocity.x, float(retreat_direction) * control_retreat_speed, 24.0)

	if direction != 0:
		_facing_direction = direction
		_update_raycast_direction()

func _resolve_ranged_attack() -> void:
	if _player == null:
		return

	if _boss_role == BOSS_ROLE_CONTROL:
		_resolve_control_attack()
		return

	if _boss_role == BOSS_ROLE_SWARM:
		_resolve_swarm_attack()
		return

	if _state == STATE_WINDUP:
		if _attack_windup_timer > 0.0:
			return

		_state = STATE_CHARGE
		_boss_charge_timer = boss_charge_seconds * _current_phase_attack_cadence_multiplier() * _current_proc_attack_cooldown_multiplier()
		_boss_charge_has_hit = false
		_boss_charge_direction = 1 if _player.global_position.x > global_position.x else -1
		_facing_direction = _boss_charge_direction
		_update_raycast_direction()
		if is_on_floor():
			velocity.y = min(velocity.y, jump_velocity * boss_charge_jump_multiplier)
		velocity.x = float(_boss_charge_direction) * _current_charge_speed()
		return

	if _state != STATE_CHARGE:
		return

	if _boss_charge_timer > 0.0:
		_apply_charge_contact()
		return

	_state = STATE_RECOVER
	_boss_recovery_timer = boss_recovery_seconds * _current_phase_recovery_multiplier() * _current_proc_attack_cooldown_multiplier()
	_attack_cooldown_timer = _boss_recovery_timer + 0.18
	_attack_primed = false
	_boss_charge_has_hit = false
	_boss_phase_flash_timer = 0.10

func _resolve_control_attack() -> void:
	if _state == STATE_WINDUP:
		if _attack_windup_timer > 0.0:
			return

		_state = STATE_CHARGE
		_boss_charge_timer = boss_control_burst_seconds * _current_phase_attack_cadence_multiplier() * _current_proc_attack_cooldown_multiplier()
		_boss_charge_has_hit = false
		_boss_control_lane_direction *= -1
		_spawn_control_projectiles()
		return

	if _state != STATE_CHARGE:
		return

	if _boss_charge_timer > 0.0:
		return

	_state = STATE_RECOVER
	_boss_recovery_timer = boss_recovery_seconds * _current_phase_recovery_multiplier() * 1.08 * _current_proc_attack_cooldown_multiplier()
	_attack_cooldown_timer = _boss_recovery_timer + 0.20
	_attack_primed = false
	_boss_phase_flash_timer = 0.08

func _resolve_swarm_attack() -> void:
	if _state == STATE_WINDUP:
		if _attack_windup_timer > 0.0:
			return

		_state = STATE_CHARGE
		_boss_charge_timer = boss_swarm_wave_seconds * _current_phase_attack_cadence_multiplier() * _current_proc_attack_cooldown_multiplier()
		_boss_charge_has_hit = false
		_boss_swarm_wave_direction *= -1
		_spawn_swarm_reinforcements()
		return

	if _state != STATE_CHARGE:
		return

	if _boss_charge_timer > 0.0:
		return

	_state = STATE_RECOVER
	_boss_recovery_timer = boss_recovery_seconds * _current_phase_recovery_multiplier() * 1.12 * _current_proc_attack_cooldown_multiplier()
	_attack_cooldown_timer = _boss_recovery_timer + 0.24
	_attack_primed = false
	_boss_phase_flash_timer = 0.08

func _spawn_control_projectiles() -> void:
	if _player == null:
		return

	var spawn_root: Node = get_tree().current_scene
	if spawn_root != null and spawn_root.has_node("Gameplay"):
		spawn_root = spawn_root.get_node("Gameplay")

	var burst_count: int = clampi(boss_control_burst_count + max(_boss_phase - 1, 0), boss_control_burst_count, boss_control_burst_count + 2)
	var phase_bonus: int = max(_boss_phase - 1, 0)
	var projectile_damage: int = _current_charge_damage()
	var control_projectile_speed: float = projectile_speed * boss_control_projectile_speed_multiplier * (1.0 + float(phase_bonus) * 0.05)
	var target_shift: float = boss_control_lane_offset + float(phase_bonus) * 16.0

	for index: int in range(burst_count):
		var vertical_step: float = 0.0
		match index:
			0:
				vertical_step = 0.0
			1:
				vertical_step = -44.0
			2:
				vertical_step = 44.0
			_:
				vertical_step = 0.0

		var lane_direction: int = _boss_control_lane_direction
		if index == 2:
			lane_direction *= -1

		var spawn_offset: Vector2 = Vector2(28.0 * float(lane_direction), -12.0 + vertical_step * 0.15)
		var target_position: Vector2 = _player.global_position + Vector2(target_shift * float(lane_direction), vertical_step)
		var projectile: EnemyProjectile = EnemyProjectile.new()
		projectile.speed = control_projectile_speed
		projectile.lifetime = boss_control_projectile_lifetime + float(phase_bonus) * 0.12
		projectile.damage = projectile_damage
		projectile.setup_projectile(global_position + spawn_offset, target_position)

		if spawn_root != null:
			spawn_root.add_child(projectile)

func _spawn_swarm_reinforcements() -> void:
	if _boss_swarm_enemy_scene == null or _player == null:
		return

	var active_swarm_count: int = get_tree().get_nodes_in_group("swarm_enemy").size()
	if active_swarm_count >= boss_swarm_max_active_allies:
		return

	var spawn_root: Node = get_tree().current_scene
	if spawn_root != null and spawn_root.has_node("Gameplay"):
		spawn_root = spawn_root.get_node("Gameplay")

	var phase_bonus: int = max(_boss_phase - 1, 0)
	var spawn_count: int = clampi(boss_swarm_spawn_count + phase_bonus * boss_swarm_spawn_count_bonus, 1, 4)
	var base_offset: float = boss_swarm_spawn_radius + float(phase_bonus) * 10.0

	for index: int in range(spawn_count):
		if active_swarm_count + index >= boss_swarm_max_active_allies:
			break

		var lane_multiplier: int = -1 if index % 2 == 0 else 1
		var ring_multiplier: int = 1 if index < 2 else -1
		var spawn_offset: Vector2 = Vector2(float(lane_multiplier) * base_offset, float(ring_multiplier) * 12.0)
		var swarm_instance: Node2D = _boss_swarm_enemy_scene.instantiate() as Node2D
		if swarm_instance == null:
			continue

		if swarm_instance.has_method("configure_counterplay"):
			swarm_instance.call("configure_counterplay", _current_player_build_identity())

		if spawn_root != null:
			swarm_instance.position = spawn_root.to_local(global_position + spawn_offset)
		else:
			swarm_instance.global_position = global_position + spawn_offset
		spawn_root.add_child(swarm_instance)

func _current_player_build_identity() -> StringName:
	if _player != null and _player.has_method("get_build_identity"):
		return StringName(_player.call("get_build_identity"))

	return &"balanced"

func apply_projectile_proc(proc_kind: StringName, proc_strength: int, source_position: Vector2) -> void:
	if _is_dying:
		return

	match proc_kind:
		BOSS_PROC_KIND_SHOCK:
			_boss_shock_timer = max(_boss_shock_timer, BOSS_SHOCK_DURATION_SECONDS + float(max(proc_strength - 1, 0)) * 0.04)
			_boss_feedback_timer = max(_boss_feedback_timer, 0.12)
		BOSS_PROC_KIND_BURN:
			_boss_burn_timer = max(_boss_burn_timer, BOSS_BURN_DURATION_SECONDS + float(max(proc_strength - 1, 0)) * 0.04)
			_boss_burn_damage = max(_boss_burn_damage, max(1, int(ceil(float(max(proc_strength, 1)) * BOSS_BURN_DAMAGE_RATIO))))
			_boss_burn_tick_timer = BOSS_BURN_TICK_SECONDS * 0.5
			_boss_feedback_timer = max(_boss_feedback_timer, 0.10)
		BOSS_PROC_KIND_CHAIN:
			_apply_chain_proc(source_position, max(1, int(ceil(float(max(proc_strength, 1)) * BOSS_CHAIN_DAMAGE_RATIO))))
			_boss_feedback_timer = max(_boss_feedback_timer, 0.08)
		_:
			pass

func _apply_chain_proc(source_position: Vector2, chain_damage: int) -> void:
	var nearest_enemy: Node2D = null
	var nearest_distance: float = BOSS_CHAIN_RADIUS

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
	if _boss_shock_timer <= 0.0:
		return 1.0

	return BOSS_SHOCK_MOVE_MULTIPLIER

func _current_proc_attack_cooldown_multiplier() -> float:
	if _boss_shock_timer <= 0.0:
		return 1.0

	return BOSS_SHOCK_ATTACK_MULTIPLIER

func _current_control_target_range() -> float:
	return boss_control_target_range + float(max(_boss_phase - 1, 0)) * boss_phase_range_bonus

func _current_control_close_range() -> float:
	return boss_control_close_range + float(max(_boss_phase - 1, 0)) * 10.0

func _current_control_burst_drift_speed() -> float:
	return chase_speed * 0.28 * _current_phase_speed_multiplier() * _counterplay_chase_speed_multiplier

func _current_swarm_target_range() -> float:
	return boss_swarm_target_range + float(max(_boss_phase - 1, 0)) * 14.0

func _current_swarm_close_range() -> float:
	return boss_swarm_close_range + float(max(_boss_phase - 1, 0)) * 8.0

func _apply_charge_contact() -> void:
	if _boss_charge_has_hit or _player == null:
		return

	if global_position.distance_to(_player.global_position) > _current_charge_contact_range():
		return

	if not _player.has_method("apply_contact_damage"):
		return

	_player.call("apply_contact_damage", _current_charge_damage(), global_position)
	_boss_charge_has_hit = true

func _current_charge_speed() -> float:
	return chase_speed * boss_charge_speed_multiplier * _current_phase_speed_multiplier() * _counterplay_chase_speed_multiplier

func _current_charge_damage() -> int:
	return attack_damage + int(max(_boss_phase - 1, 0)) * boss_phase_damage_bonus

func _current_charge_range() -> float:
	return boss_charge_range + float(max(_boss_phase - 1, 0)) * boss_phase_range_bonus

func _current_charge_contact_range() -> float:
	return boss_contact_range + float(max(_boss_phase - 1, 0)) * 8.0

func _current_phase_speed_multiplier() -> float:
	return 1.0 + float(max(_boss_phase - 1, 0)) * boss_phase_speed_bonus

func _current_phase_recovery_multiplier() -> float:
	return max(0.70, 1.0 - float(max(_boss_phase - 1, 0)) * (1.0 - boss_phase_recovery_multiplier))

func _current_phase_attack_cadence_multiplier() -> float:
	match _boss_phase:
		1:
			return 1.0
		2:
			return 0.88
		_:
			return 0.76

# ============================================================================
# VISUALS
# ============================================================================

func _update_visuals() -> void:
	var sprite_scale: Vector2 = Vector2.ONE
	var sprite_color: Color = _current_visual_color()

	sprite_scale *= Vector2(1.0 + float(max(_boss_phase - 1, 0)) * 0.03, 1.0 + float(max(_boss_phase - 1, 0)) * 0.02)
	if _boss_phase_transition_timer > 0.0:
		sprite_scale *= Vector2(1.06, 1.04)

	match _state:
		STATE_WINDUP:
			sprite_scale *= Vector2(1.11, 0.93)
			if _boss_role == BOSS_ROLE_CONTROL:
				sprite_color = CONTROL_WINDUP_COLOR
			elif _boss_role == BOSS_ROLE_SWARM:
				sprite_color = SWARM_WINDUP_COLOR
			else:
				sprite_color = WINDUP_COLOR
		STATE_CHARGE:
			sprite_scale *= Vector2(1.18, 0.90)
			if _boss_role == BOSS_ROLE_CONTROL:
				sprite_color = CONTROL_CHARGE_COLOR
			elif _boss_role == BOSS_ROLE_SWARM:
				sprite_color = SWARM_CHARGE_COLOR
			else:
				sprite_color = CHARGE_COLOR
		STATE_RECOVER:
			sprite_scale *= Vector2(1.04, 0.98)
			if _boss_role == BOSS_ROLE_CONTROL:
				sprite_color = CONTROL_RECOVER_COLOR
			elif _boss_role == BOSS_ROLE_SWARM:
				sprite_color = SWARM_RECOVER_COLOR
			else:
				sprite_color = RECOVER_COLOR
		_:
			sprite_color = _current_visual_color()

	if _boss_intro_timer > 0.0:
		sprite_scale *= Vector2(0.98, 0.98)

	if _boss_phase_flash_timer > 0.0:
		sprite_color = sprite_color.lerp(Color.WHITE, 0.35)
	if _boss_phase_transition_timer > 0.0:
		sprite_color = sprite_color.lerp(Color.WHITE, 0.20)

	if _boss_burn_timer > 0.0:
		sprite_color = sprite_color.lerp(BOSS_BURN_TINT, 0.18)
	if _boss_shock_timer > 0.0:
		sprite_color = sprite_color.lerp(BOSS_SHOCK_TINT, 0.14)

	if _hit_flash_timer > 0.0 or _death_flash_timer > 0.0:
		sprite_color = Color.WHITE

	_sprite.flip_h = _facing_direction > 0
	_sprite.scale = sprite_scale
	_sprite.self_modulate = _tint_elite_color(sprite_color)

func _current_visual_color() -> Color:
	if _boss_role == BOSS_ROLE_CONTROL:
		if _boss_phase >= 3:
			return Color(0.20, 0.88, 1.0, 1.0)

		if _boss_phase == 2:
			return Color(0.24, 0.70, 0.86, 1.0)

		return CONTROL_HUNT_COLOR

	if _boss_role == BOSS_ROLE_SWARM:
		if _boss_phase >= 3:
			return Color(0.72, 1.0, 0.34, 1.0)

		if _boss_phase == 2:
			return Color(0.54, 0.82, 0.18, 1.0)

		return SWARM_HUNT_COLOR

	if _boss_phase >= 3:
		return Color(0.58, 0.22, 0.18, 1.0)

	if _boss_phase == 2:
		return Color(0.48, 0.24, 0.46, 1.0)

	return HUNT_COLOR

# ============================================================================
# DAMAGE AND REWARDS
# ============================================================================

func take_projectile_hit(damage: int, knockback: Vector2) -> void:
	if _is_dying:
		return

	_health = max(_health - damage, 0)
	velocity.x = knockback.x * 0.35
	velocity.y = min(velocity.y, knockback.y * 0.18)
	_hit_flash_timer = 0.12
	_update_boss_phase()

	if _health > 0:
		return

	_start_death_feedback()

func _load_swarm_enemy_scene() -> PackedScene:
	if not FileAccess.file_exists("res://scenes/enemies/swarm_enemy.tscn"):
		return null

	return load("res://scenes/enemies/swarm_enemy.tscn")
