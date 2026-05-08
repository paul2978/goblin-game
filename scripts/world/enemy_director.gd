extends Node

# ============================================================================
# CONSTANTS
# ============================================================================

const DEBUG_PRINT_INTERVAL: float = 5.0
const SPAWN_COLLISION_SIZE: Vector2 = Vector2(20.0, 32.0)
const VIEW_MARGIN: Vector2 = Vector2(96.0, 64.0)
const SPAWN_BODY_OFFSET: Vector2 = Vector2(0.0, -16.0)
const RANGED_ENEMY_SCENE_PATH: String = "res://scenes/enemies/ranged_enemy.tscn"
const SWARM_ENEMY_SCENE_PATH: String = "res://scenes/enemies/swarm_enemy.tscn"
const MELEE_ENEMY_GROUP_NAME: StringName = &"melee_enemy"
const RANGED_ENEMY_GROUP_NAME: StringName = &"ranged_enemy"
const SWARM_ENEMY_GROUP_NAME: StringName = &"swarm_enemy"
const MELEE_ENEMY_WEIGHT: float = 0.60
const RANGED_ENEMY_WEIGHT: float = 0.25
const SWARM_ENEMY_WEIGHT: float = 0.15
const ELITE_BERSERKER: StringName = &"berserker"
const ELITE_TITAN: StringName = &"titan"
const ELITE_VOLTAIC: StringName = &"voltaic"
const WORLD_CHUNK_CATEGORY_PRESSURE: String = "pressure"
const WORLD_CHUNK_CATEGORY_RECOVERY: String = "recovery"
const WORLD_CHUNK_CATEGORY_TRAVERSAL: String = "traversal"
const WORLD_CHUNK_CATEGORY_CLIMAX: String = "climax"
const WORLD_ENCOUNTER_PROFILE_OPEN: String = "open"
const WORLD_ENCOUNTER_PROFILE_MIXED: String = "mixed"
const WORLD_ENCOUNTER_PROFILE_PRESSURE: String = "pressure"
const WORLD_ENCOUNTER_PROFILE_RECOVERY: String = "recovery"
const BOSS_ENEMY_SCENE_PATH: String = "res://scenes/enemies/boss_enemy.tscn"
const BOSS_STAGE_FINALE_PROGRESS_THRESHOLD: float = 0.58
const BOSS_STAGE_LATE_MAX_ACTIVE_ENEMIES: int = 2
const BOSS_STAGE_ENDLESS_MAX_ACTIVE_ENEMIES: int = 3
const BOSS_SUPPORT_INTERVAL_SECONDS: float = 7.5
const BOSS_SUPPORT_INTERVAL_VARIANCE_SECONDS: float = 2.0
const BOSS_ENCOUNTER_INTERVAL_MULTIPLIER: float = 1.18
const BOSS_MAX_ENEMY_PENALTY: int = 1
const BOSS_PRIMED_PRESSURE_BONUS: float = 0.22
const BOSS_ACTIVE_PRESSURE_BONUS: float = 0.78
const ELITE_BASE_CHANCE: float = 0.015
const ELITE_TIME_WEIGHT: float = 0.00016
const ELITE_PRESSURE_WEIGHT: float = 0.010
const ELITE_LEVEL_WEIGHT: float = 0.008
const ELITE_MAX_CHANCE: float = 0.14
const RECOVERY_PENALTY_CAP: float = 2.5
const COMBAT_INTENSITY_CAP: float = 4.0
const RECOVERY_STATE_THRESHOLD: float = 1.3
const LOW_PRESSURE_STATE_THRESHOLD: float = 2.8
const HIGH_PRESSURE_BURST_THRESHOLD: float = 4.0
const HIGH_PRESSURE_BURST_CHANCE: float = 0.35
const COMPOSITION_RECOVERY_INTERVAL_MULTIPLIER: float = 1.10
const COMPOSITION_BUILD_INTERVAL_MULTIPLIER: float = 1.02
const COMPOSITION_PRESSURE_INTERVAL_MULTIPLIER: float = 0.96
const COMPOSITION_SPIKE_INTERVAL_MULTIPLIER: float = 0.90
const RUN_STAGE_EARLY_SECONDS: float = 120.0
const RUN_STAGE_MID_SECONDS: float = 300.0
const RUN_STAGE_LATE_SECONDS: float = 540.0
const RUN_LOOP_CYCLE_SECONDS: float = 180.0
const RUN_LOOP_TRANSITION_SECONDS: float = 4.0
const RUN_LOOP_RELIEF_SECONDS: float = 5.0
const RUN_STAGE_EARLY_FINALE_WINDOW_SECONDS: float = 16.0
const RUN_STAGE_MID_FINALE_WINDOW_SECONDS: float = 22.0
const RUN_STAGE_LATE_FINALE_WINDOW_SECONDS: float = 28.0
const RUN_STAGE_EARLY_INTERVAL_MULTIPLIER: float = 1.00
const RUN_STAGE_MID_INTERVAL_MULTIPLIER: float = 0.92
const RUN_STAGE_LATE_INTERVAL_MULTIPLIER: float = 0.84
const RUN_STAGE_ENDLESS_INTERVAL_MULTIPLIER: float = 0.76
const RUN_STAGE_EARLY_RECOVERY_GAIN_MULTIPLIER: float = 1.00
const RUN_STAGE_MID_RECOVERY_GAIN_MULTIPLIER: float = 0.92
const RUN_STAGE_LATE_RECOVERY_GAIN_MULTIPLIER: float = 0.80
const RUN_STAGE_ENDLESS_RECOVERY_GAIN_MULTIPLIER: float = 0.68
const RUN_STAGE_EARLY_RECOVERY_DECAY_MULTIPLIER: float = 1.00
const RUN_STAGE_MID_RECOVERY_DECAY_MULTIPLIER: float = 1.08
const RUN_STAGE_LATE_RECOVERY_DECAY_MULTIPLIER: float = 1.18
const RUN_STAGE_ENDLESS_RECOVERY_DECAY_MULTIPLIER: float = 1.30
const RUN_STAGE_EARLY_ELITE_MULTIPLIER: float = 1.00
const RUN_STAGE_MID_ELITE_MULTIPLIER: float = 1.08
const RUN_STAGE_LATE_ELITE_MULTIPLIER: float = 1.18
const RUN_STAGE_ENDLESS_ELITE_MULTIPLIER: float = 1.28
const RUN_STAGE_TRANSITION_SECONDS: float = 3.0
const RUN_STAGE_TRANSITION_INTERVAL_MULTIPLIER: float = 1.20
const RUN_STAGE_TRANSITION_MAX_ENEMY_PENALTY: int = 2
const RUN_STAGE_TRANSITION_PRESSURE_RELIEF: float = 0.70
const RUN_STAGE_EARLY_SPAWN_BURST_CHANCE: float = 0.18
const RUN_STAGE_MID_SPAWN_BURST_CHANCE: float = 0.24
const RUN_STAGE_LATE_SPAWN_BURST_CHANCE: float = 0.32
const RUN_STAGE_ENDLESS_SPAWN_BURST_CHANCE: float = 0.40
const RUN_STAGE_EARLY_BUILD_THRESHOLD: float = 2.8
const RUN_STAGE_MID_BUILD_THRESHOLD: float = 2.5
const RUN_STAGE_LATE_BUILD_THRESHOLD: float = 2.2
const RUN_STAGE_ENDLESS_BUILD_THRESHOLD: float = 2.0
const RUN_STAGE_EARLY_PRESSURE_THRESHOLD: float = 4.6
const RUN_STAGE_MID_PRESSURE_THRESHOLD: float = 4.3
const RUN_STAGE_LATE_PRESSURE_THRESHOLD: float = 4.0
const RUN_STAGE_ENDLESS_PRESSURE_THRESHOLD: float = 3.7
const RUN_STAGE_EARLY_FINALE_PRESSURE_BONUS: float = 0.55
const RUN_STAGE_MID_FINALE_PRESSURE_BONUS: float = 0.75
const RUN_STAGE_LATE_FINALE_PRESSURE_BONUS: float = 0.95
const RUN_STAGE_EARLY_FINALE_INTERVAL_MULTIPLIER: float = 0.90
const RUN_STAGE_MID_FINALE_INTERVAL_MULTIPLIER: float = 0.86
const RUN_STAGE_LATE_FINALE_INTERVAL_MULTIPLIER: float = 0.82
const RUN_STAGE_EARLY_FINALE_MAX_ENEMY_BONUS: int = 1
const RUN_STAGE_MID_FINALE_MAX_ENEMY_BONUS: int = 1
const RUN_STAGE_LATE_FINALE_MAX_ENEMY_BONUS: int = 2
const RUN_STAGE_EARLY_FINALE_ELITE_MULTIPLIER: float = 1.06
const RUN_STAGE_MID_FINALE_ELITE_MULTIPLIER: float = 1.12
const RUN_STAGE_LATE_FINALE_ELITE_MULTIPLIER: float = 1.18
const RUN_LOOP_TRANSITION_INTERVAL_MULTIPLIER: float = 1.12
const RUN_LOOP_TRANSITION_MAX_ENEMY_PENALTY: int = 1
const RUN_LOOP_TRANSITION_PRESSURE_RELIEF: float = 0.80
const RUN_LOOP_PRESSURE_STEP: float = 0.14
const RUN_LOOP_PRESSURE_PROGRESS_STEP: float = 0.20
const RUN_LOOP_MAX_ENEMY_BONUS_STEP: int = 1
const RUN_LOOP_ELITE_MULTIPLIER_STEP: float = 0.05
const RUN_LOOP_SPAWN_BURST_STEP: float = 0.03
const RECOVERY_WINDOW_SECONDS: float = 2.0
const RECOVERY_WINDOW_INTERVAL_MULTIPLIER: float = 1.14
const RECOVERY_WINDOW_MAX_ENEMY_PENALTY: int = 1
const RECOVERY_WINDOW_PRESSURE_RELIEF: float = 0.50
const LANDMARK_EVENT_BASE_COOLDOWN: float = 54.0
const LANDMARK_EVENT_ELAPSED_SECONDS_STEP: float = 90.0
const LANDMARK_EVENT_TRIGGER_PRESSURE: float = 3.8
const LANDMARK_EVENT_DURATION_SECONDS: float = 6.5
const LANDMARK_EVENT_RELIEF_SECONDS: float = 3.0
const LANDMARK_EVENT_REWARD_RELIEF: float = 0.65
const LANDMARK_EVENT_SWARM_INTERVAL_MULTIPLIER: float = 0.84
const LANDMARK_EVENT_ELITE_INTERVAL_MULTIPLIER: float = 0.90
const LANDMARK_EVENT_MELEE_INTERVAL_MULTIPLIER: float = 0.92
const LANDMARK_EVENT_SWARM_BURST_MULTIPLIER: float = 1.40
const LANDMARK_EVENT_ELITE_BURST_MULTIPLIER: float = 1.24
const LANDMARK_EVENT_MELEE_BURST_MULTIPLIER: float = 1.12
const LANDMARK_EVENT_MAX_ENEMY_BONUS: int = 1

# ============================================================================
# EXPORTED VARIABLES
# ============================================================================

@export var base_spawn_interval: float = 4.5
@export var minimum_spawn_interval: float = 1.8
@export var base_max_enemies: int = 6
@export var max_enemy_cap: int = 12
@export var min_spawn_distance_from_player: float = 320.0
@export var pressure_time_rate: float = 0.015
@export var pressure_enemy_weight: float = 0.18
@export var pressure_level_weight: float = 0.22
@export var combat_intensity_gain_rate: float = 0.28
@export var combat_intensity_decay_rate: float = 0.20
@export var recovery_gain_rate: float = 0.16
@export var recovery_decay_rate: float = 0.28
@export var burst_cooldown_seconds: float = 12.0

# ============================================================================
# RUNTIME VARIABLES
# ============================================================================

var _elapsed_time: float = 0.0
var _spawn_timer: float = 0.0
var _debug_timer: float = 0.0
var _pressure: float = 0.0
var _recent_combat_intensity: float = 0.0
var _recovery_pressure_buffer: float = 0.0
var _burst_timer: float = 0.0
var _last_active_enemy_count: int = 0
var _player_level: int = 1
var _player_build_identity: StringName = &"balanced"
var _pacing_state: String = "recovery"
var _encounter_composition: String = "recovery"
var _ecology_layer_state: String = "mixed"
var _run_stage: String = "early"
var _stage_transition_timer: float = 0.0
var _stage_transition_label: String = "none"
var _run_loop_index: int = 0
var _run_loop_transition_timer: float = 0.0
var _run_loop_transition_label: String = "none"
var _run_loop_relief_timer: float = 0.0
var _stage_finale_timer: float = 0.0
var _stage_finale_label: String = "none"
var _tempo_relief_timer: float = 0.0
var _landmark_event_timer: float = 0.0
var _landmark_event_cooldown_timer: float = 0.0
var _landmark_event_type: String = "none"
var _world_chunk_pool_name: String = "none"
var _world_encounter_profile_name: String = "mixed"
var _world_chunk_category_sequence: Array[String] = []
var _world_chunk_ecology_counts: Dictionary = {}
var _boss_enemy_scene: PackedScene = null
var _boss_spawned: bool = false
var _boss_encounter_state: String = "none"
var _boss_role: StringName = &""
var _boss_support_timer: float = 0.0
var _last_spawn_zone_root: Node2D = null
var _gameplay_root: Node2D = null
var _enemy_spawn_root: Node2D = null
var _spawn_zones_root: Node2D = null
var _melee_spawn_zone_root: Node2D = null
var _mixed_spawn_zone_root: Node2D = null
var _ranged_spawn_zone_root: Node2D = null
var _enemy_scene: PackedScene = null
var _ranged_enemy_scene: PackedScene = null
var _swarm_enemy_scene: PackedScene = null
var _player: Node2D = null
var _spawn_shape: RectangleShape2D = RectangleShape2D.new()
var _debug_layer: CanvasLayer = null
var _debug_label: Label = null

# ============================================================================
# GODOT LIFECYCLE
# ============================================================================

func setup(gameplay_root: Node2D, enemy_spawn_root: Node2D, enemy_scene: PackedScene, spawn_zones_root: Node2D) -> void:
	_gameplay_root = gameplay_root
	_enemy_spawn_root = enemy_spawn_root
	_spawn_zones_root = spawn_zones_root
	_enemy_scene = enemy_scene
	_ranged_enemy_scene = _load_ranged_enemy_scene()
	_swarm_enemy_scene = _load_swarm_enemy_scene()
	_boss_enemy_scene = _load_boss_enemy_scene()
	if _spawn_zones_root != null:
		_melee_spawn_zone_root = _spawn_zones_root.get_node_or_null("Melee") as Node2D
		_mixed_spawn_zone_root = _spawn_zones_root.get_node_or_null("Mixed") as Node2D
		_ranged_spawn_zone_root = _spawn_zones_root.get_node_or_null("Ranged") as Node2D
	_spawn_shape.size = SPAWN_COLLISION_SIZE
	_spawn_timer = base_spawn_interval
	_debug_timer = DEBUG_PRINT_INTERVAL
	_setup_debug_ui()

func configure_world_chunk_profile(pool_name: String, encounter_profile_name: String, chunk_categories: Array[String], ecology_counts: Dictionary) -> void:
	_world_chunk_pool_name = pool_name
	_world_encounter_profile_name = encounter_profile_name
	_world_chunk_category_sequence = chunk_categories.duplicate()
	_world_chunk_ecology_counts = ecology_counts.duplicate()

func _physics_process(delta: float) -> void:
	if _gameplay_root == null or _enemy_spawn_root == null or _enemy_scene == null:
		return

	_update_player_reference()
	_update_director(delta)
	_try_spawn_enemy()
	_update_debug(delta)

# ============================================================================
# PRESSURE
# ============================================================================

func _update_player_reference() -> void:
	if is_instance_valid(_player):
		if _player.has_method("get_build_identity"):
			_player_build_identity = StringName(_player.call("get_build_identity"))
		return

	_player = get_tree().get_first_node_in_group("player") as Node2D
	if _player != null and _player.has_method("get_current_level"):
		_player_level = int(_player.call("get_current_level"))
	if _player != null and _player.has_method("get_build_identity"):
		_player_build_identity = StringName(_player.call("get_build_identity"))

func _update_director(delta: float) -> void:
	_elapsed_time += delta
	var active_enemy_count: int = _active_enemy_count()
	var enemy_deaths: int = max(_last_active_enemy_count - active_enemy_count, 0)
	var previous_run_stage: String = _run_stage
	_run_stage = _current_run_stage()
	_update_stage_transition(delta, previous_run_stage, _run_stage, active_enemy_count)
	_update_combat_pressure(delta, active_enemy_count, enemy_deaths)
	_update_recovery_pressure(delta, active_enemy_count, enemy_deaths)
	_update_tempo_relief(delta, active_enemy_count, enemy_deaths)
	_update_stage_finale(delta)
	_update_boss_encounter(delta, active_enemy_count)
	_update_run_loops(delta, active_enemy_count)
	_update_landmark_events(delta, active_enemy_count, enemy_deaths)
	_player_level = _current_player_level()
	_pressure = _compute_pressure(active_enemy_count)
	_pacing_state = _current_pacing_state(active_enemy_count)
	_encounter_composition = _current_encounter_composition(active_enemy_count)
	_ecology_layer_state = _current_ecology_layer_state(active_enemy_count)
	_spawn_timer -= delta
	_burst_timer = max(_burst_timer - delta, 0.0)
	_last_active_enemy_count = active_enemy_count

func _update_combat_pressure(delta: float, active_enemy_count: int, enemy_deaths: int) -> void:
	var combat_decay_multiplier: float = _current_run_stage_combat_decay_multiplier()
	var combat_gain_multiplier: float = _current_run_stage_combat_gain_multiplier()
	_recent_combat_intensity = max(_recent_combat_intensity - delta * combat_intensity_decay_rate * combat_decay_multiplier, 0.0)
	if active_enemy_count >= 3:
		_recent_combat_intensity = min(_recent_combat_intensity + delta * combat_intensity_gain_rate * combat_gain_multiplier, COMBAT_INTENSITY_CAP)

	if active_enemy_count >= 5:
		_recent_combat_intensity = min(_recent_combat_intensity + delta * 0.12 * combat_gain_multiplier, COMBAT_INTENSITY_CAP)

	if enemy_deaths > 0:
		_recent_combat_intensity = max(_recent_combat_intensity - float(enemy_deaths) * 0.12 * combat_decay_multiplier, 0.0)

func _update_recovery_pressure(delta: float, active_enemy_count: int, enemy_deaths: int) -> void:
	var recovery_gain_multiplier: float = _current_run_stage_recovery_gain_multiplier()
	var recovery_decay_multiplier: float = _current_run_stage_recovery_decay_multiplier()
	if active_enemy_count <= 1:
		_recovery_pressure_buffer = min(_recovery_pressure_buffer + delta * recovery_gain_rate * recovery_gain_multiplier, RECOVERY_PENALTY_CAP)
	else:
		_recovery_pressure_buffer = max(_recovery_pressure_buffer - delta * recovery_decay_rate * recovery_decay_multiplier, 0.0)

	if enemy_deaths > 0:
		_recovery_pressure_buffer = min(_recovery_pressure_buffer + float(enemy_deaths) * 0.16 * recovery_decay_multiplier, RECOVERY_PENALTY_CAP)

func _update_tempo_relief(delta: float, active_enemy_count: int, enemy_deaths: int) -> void:
	_tempo_relief_timer = max(_tempo_relief_timer - delta, 0.0)

	if enemy_deaths <= 0:
		return

	if active_enemy_count > 2:
		return

	_tempo_relief_timer = max(_tempo_relief_timer, RECOVERY_WINDOW_SECONDS)

# ============================================================================
# FINALE ENCOUNTERS
# ============================================================================

func _update_stage_finale(delta: float) -> void:
	_stage_finale_timer = max(_stage_finale_timer - delta, 0.0)
	if _stage_finale_timer > 0.0:
		_stage_finale_label = _current_stage_finale_label(_stage_finale_timer)
		return

	var stage_end_time: float = _current_run_stage_end_time()
	var finale_window: float = _current_stage_finale_window_seconds()
	if stage_end_time <= 0.0 or finale_window <= 0.0:
		_stage_finale_label = "none"
		return

	var time_until_stage_end: float = max(stage_end_time - _elapsed_time, 0.0)
	if time_until_stage_end > finale_window:
		_stage_finale_label = "none"
		return

	_stage_finale_timer = time_until_stage_end
	_stage_finale_label = _current_stage_finale_label(_stage_finale_timer)

# ============================================================================
# BOSS ENCOUNTERS
# ============================================================================

func _update_boss_encounter(delta: float, active_enemy_count: int) -> void:
	_boss_support_timer = max(_boss_support_timer - delta, 0.0)

	if _active_boss_count() <= 0 and _boss_encounter_state == "active":
		_boss_encounter_state = "cleared"
		_boss_support_timer = 0.0
		_grant_boss_victory_reward()
		_tempo_relief_timer = max(_tempo_relief_timer, RUN_LOOP_RELIEF_SECONDS)
		_recovery_pressure_buffer = max(_recovery_pressure_buffer - 0.6, 0.0)
		_recent_combat_intensity = max(_recent_combat_intensity - 0.5, 0.0)

	if _boss_spawned:
		return

	if _run_stage != "late" and _run_stage != "endless":
		if not _boss_spawned and _boss_encounter_state != "cleared":
			_boss_encounter_state = "none"
		return

	if _run_loop_transition_timer > 0.0:
		if not _boss_spawned and _boss_encounter_state != "cleared":
			_boss_encounter_state = "none"
		return

	if _stage_finale_timer <= 0.0:
		if not _boss_spawned and _boss_encounter_state != "cleared":
			_boss_encounter_state = "none"
		return

	if _current_stage_finale_progress() < BOSS_STAGE_FINALE_PROGRESS_THRESHOLD:
		return

	if active_enemy_count > _current_boss_max_active_enemies():
		_boss_encounter_state = "primed"
		_spawn_timer = min(_spawn_timer, 0.20)
		return

	_boss_encounter_state = "primed"
	_spawn_timer = min(_spawn_timer, 0.20)

func _current_boss_max_active_enemies() -> int:
	match _run_stage:
		"endless":
			return BOSS_STAGE_ENDLESS_MAX_ACTIVE_ENEMIES
		_:
			return BOSS_STAGE_LATE_MAX_ACTIVE_ENEMIES

func _try_spawn_boss() -> bool:
	if _boss_enemy_scene == null:
		return false

	if _boss_spawned or _boss_encounter_state != "primed":
		return false

	if _spawn_timer > 0.0:
		return false

	if _active_boss_count() > 0:
		return false

	if _active_enemy_count() > _current_boss_max_active_enemies():
		return false

	var boss_instance: Node2D = _boss_enemy_scene.instantiate() as Node2D
	if boss_instance == null:
		return false

	_boss_role = _current_boss_role()
	if boss_instance.has_method("configure_boss"):
		boss_instance.call("configure_boss", _boss_role)
	if boss_instance.has_method("configure_counterplay"):
		boss_instance.call("configure_counterplay", _current_player_build_identity())

	boss_instance.position = _gameplay_root.to_local(_current_boss_spawn_position())
	_gameplay_root.add_child(boss_instance)
	_boss_spawned = true
	_boss_encounter_state = "active"
	_boss_support_timer = BOSS_SUPPORT_INTERVAL_SECONDS
	_recent_combat_intensity = max(_recent_combat_intensity - 0.25, 0.0)
	_recovery_pressure_buffer = max(_recovery_pressure_buffer - 0.40, 0.0)
	_landmark_event_timer = max(_landmark_event_timer - 1.5, 0.0)
	return true

func _try_spawn_boss_support() -> bool:
	if _boss_encounter_state != "active":
		return false

	if _boss_support_timer > 0.0:
		return false

	if _active_boss_count() <= 0:
		return false

	if _active_enemy_count() >= _current_max_enemies():
		return false

	var support_scene: PackedScene = _current_boss_support_scene()
	if support_scene == null:
		return false

	var support_instance: Node2D = support_scene.instantiate() as Node2D
	if support_instance == null:
		return false

	if support_instance.has_method("configure_counterplay"):
		support_instance.call("configure_counterplay", _current_player_build_identity())

	support_instance.position = _gameplay_root.to_local(_current_boss_support_position())
	_gameplay_root.add_child(support_instance)
	_boss_support_timer = BOSS_SUPPORT_INTERVAL_SECONDS + randf_range(0.5, BOSS_SUPPORT_INTERVAL_VARIANCE_SECONDS)
	return true

func _current_boss_support_scene() -> PackedScene:
	match _current_boss_role():
		&"swarm":
			if _swarm_enemy_scene != null:
				return _swarm_enemy_scene
		&"control":
			if _ranged_enemy_scene != null:
				return _ranged_enemy_scene
		_:
			pass

	return _enemy_scene

func _grant_boss_victory_reward() -> void:
	if _player == null or not is_instance_valid(_player):
		return

	if not _player.has_method("apply_boss_victory_reward"):
		return

	_player.call("apply_boss_victory_reward", _run_stage, _boss_role)

func _current_boss_spawn_position() -> Vector2:
	var arena_center: Node2D = _gameplay_root.get_node_or_null("FutureHooks/CombatArenas/Arena_Center") as Node2D
	if arena_center != null:
		return arena_center.global_position

	if _player != null:
		return _player.global_position + Vector2(160.0, 0.0)

	return Vector2.ZERO

func _current_boss_support_position() -> Vector2:
	var boss_node: Node2D = _current_active_boss_node()
	if boss_node != null:
		return boss_node.global_position + Vector2(randf_range(-120.0, 120.0), randf_range(-24.0, 24.0))

	return _current_boss_spawn_position() + Vector2(randf_range(-96.0, 96.0), 0.0)

func _current_active_boss_node() -> Node2D:
	var boss_nodes: Array = get_tree().get_nodes_in_group("boss")
	for boss_node_variant: Variant in boss_nodes:
		var boss_node: Node2D = boss_node_variant as Node2D
		if boss_node != null and is_instance_valid(boss_node):
			return boss_node

	return null

func _active_boss_count() -> int:
	return get_tree().get_nodes_in_group("boss").size()

# ============================================================================
# RUN LOOPS
# ============================================================================

func _update_run_loops(delta: float, active_enemy_count: int) -> void:
	_run_loop_transition_timer = max(_run_loop_transition_timer - delta, 0.0)
	_run_loop_relief_timer = max(_run_loop_relief_timer - delta, 0.0)
	if _run_loop_transition_timer <= 0.0:
		_run_loop_transition_label = "none"

	if _run_stage != "endless":
		_run_loop_index = 0
		_run_loop_transition_timer = 0.0
		_run_loop_transition_label = "none"
		_run_loop_relief_timer = 0.0
		return

	var current_run_loop_index: int = _current_run_loop_index()
	if current_run_loop_index == _run_loop_index:
		return

	_run_loop_index = current_run_loop_index
	_run_loop_transition_timer = RUN_LOOP_TRANSITION_SECONDS
	_run_loop_transition_label = "loop_%d" % _run_loop_index
	_run_loop_relief_timer = RUN_LOOP_RELIEF_SECONDS
	_recent_combat_intensity = max(_recent_combat_intensity - 0.65, 0.0)
	_recovery_pressure_buffer = max(_recovery_pressure_buffer - 0.55, 0.0)
	_burst_timer = 0.0

	if active_enemy_count <= 3:
		_tempo_relief_timer = max(_tempo_relief_timer, RUN_LOOP_RELIEF_SECONDS)

# ============================================================================
# LANDMARK EVENTS
# ============================================================================

func _update_landmark_events(delta: float, active_enemy_count: int, enemy_deaths: int) -> void:
	_landmark_event_timer = max(_landmark_event_timer - delta, 0.0)
	_landmark_event_cooldown_timer = max(_landmark_event_cooldown_timer - delta, 0.0)

	if _stage_finale_timer > 0.0:
		return

	if _boss_encounter_state == "active" or _boss_encounter_state == "primed":
		return

	if _run_loop_transition_timer > 0.0:
		return

	if _landmark_event_timer > 0.0:
		return

	if _landmark_event_cooldown_timer > 0.0:
		return

	if _pressure < LANDMARK_EVENT_TRIGGER_PRESSURE:
		return

	if active_enemy_count > max(2, int(floor(float(_current_max_enemies()) * 0.75))):
		return

	if enemy_deaths <= 0 and _recent_combat_intensity < 1.0:
		return

	var event_type: String = _select_landmark_event_type(active_enemy_count)
	if event_type == "none":
		return

	_landmark_event_type = event_type
	_landmark_event_timer = LANDMARK_EVENT_DURATION_SECONDS
	_landmark_event_cooldown_timer = LANDMARK_EVENT_BASE_COOLDOWN + float(int(floor(_elapsed_time / LANDMARK_EVENT_ELAPSED_SECONDS_STEP))) * 3.0
	_tempo_relief_timer = max(_tempo_relief_timer, LANDMARK_EVENT_RELIEF_SECONDS)
	_recovery_pressure_buffer = min(_recovery_pressure_buffer + LANDMARK_EVENT_REWARD_RELIEF, RECOVERY_PENALTY_CAP)

# ============================================================================
# STAGE TRANSITIONS
# ============================================================================

func _update_stage_transition(delta: float, previous_run_stage: String, current_run_stage: String, active_enemy_count: int) -> void:
	_stage_transition_timer = max(_stage_transition_timer - delta, 0.0)
	if _stage_transition_timer <= 0.0:
		_stage_transition_label = "none"

	if previous_run_stage == current_run_stage:
		return

	_stage_transition_timer = RUN_STAGE_TRANSITION_SECONDS
	_stage_transition_label = "%s_to_%s" % [previous_run_stage, current_run_stage]

	if is_instance_valid(_player) and _player.has_method("apply_stage_transition_reward"):
		_player.call("apply_stage_transition_reward", current_run_stage)

	if active_enemy_count <= 3:
		_tempo_relief_timer = max(_tempo_relief_timer, RUN_STAGE_TRANSITION_SECONDS)
		_recovery_pressure_buffer = min(_recovery_pressure_buffer + 0.35, RECOVERY_PENALTY_CAP)

func _select_landmark_event_type(active_enemy_count: int) -> String:
	var roll: float = randf()
	var swarm_bias: float = 0.0
	var elite_bias: float = 0.0
	var melee_bias: float = 0.0

	if _swarm_enemy_scene != null:
		swarm_bias = 0.30
	if _current_elite_cap() > 1:
		elite_bias = 0.24
	if active_enemy_count <= 4:
		melee_bias = 0.20

	if _run_stage == "late" or _run_stage == "endless":
		swarm_bias += 0.10
		elite_bias += 0.06

	match _ecology_layer_state:
		"swarm_lane":
			swarm_bias += 0.10
		"anchor":
			elite_bias += 0.05
		"rush":
			melee_bias += 0.10
		"layered":
			swarm_bias += 0.04
			elite_bias += 0.04

	var total_bias: float = swarm_bias + elite_bias + melee_bias
	if total_bias <= 0.0:
		return "none"

	if roll < swarm_bias:
		return "swarm_surge"

	if roll < swarm_bias + elite_bias:
		return "elite_push"

	if roll < total_bias:
		return "melee_rush"

	return "none"

# ============================================================================
# PACING
# ============================================================================

func _compute_pressure(active_enemy_count: int) -> float:
	var elapsed_pressure: float = _elapsed_time * pressure_time_rate
	var enemy_pressure: float = float(active_enemy_count) * pressure_enemy_weight
	var level_pressure: float = float(max(_player_level - 1, 0)) * pressure_level_weight
	var intensity_pressure: float = _recent_combat_intensity
	var finale_pressure: float = _current_stage_finale_pressure_bonus()
	var loop_pressure: float = _current_run_loop_pressure_bonus()
	var boss_pressure: float = _current_boss_pressure_bonus()
	var recovery_relief: float = _recovery_pressure_buffer
	var tempo_relief: float = 0.0
	var loop_relief: float = 0.0
	if _tempo_relief_timer > 0.0:
		tempo_relief = RECOVERY_WINDOW_PRESSURE_RELIEF
	if _landmark_event_timer > 0.0:
		tempo_relief += LANDMARK_EVENT_REWARD_RELIEF
	if _stage_transition_timer > 0.0:
		tempo_relief += RUN_STAGE_TRANSITION_PRESSURE_RELIEF
	if _run_loop_transition_timer > 0.0:
		loop_relief += RUN_LOOP_TRANSITION_PRESSURE_RELIEF
	if _run_loop_relief_timer > 0.0:
		loop_relief += 0.30

	var total_pressure: float = elapsed_pressure + enemy_pressure + level_pressure + intensity_pressure + finale_pressure + loop_pressure + boss_pressure - recovery_relief - tempo_relief - loop_relief
	return max(total_pressure, 0.0)

func _current_player_level() -> int:
	if _player != null and _player.has_method("get_current_level"):
		return int(_player.call("get_current_level"))

	return 1

func _current_player_build_identity() -> StringName:
	if _player != null and _player.has_method("get_build_identity"):
		return StringName(_player.call("get_build_identity"))

	return _player_build_identity

func _current_player_build_archetype() -> StringName:
	if _player != null and _player.has_method("get_build_archetype"):
		return StringName(_player.call("get_build_archetype"))

	return &"balanced"

func _current_build_role_multiplier(enemy_scene: PackedScene) -> float:
	if enemy_scene == null:
		return 1.0

	var build_identity: StringName = _current_player_build_identity()

	if build_identity == &"mobility":
		if enemy_scene == _ranged_enemy_scene:
			return 1.06
		if enemy_scene == _swarm_enemy_scene:
			return 1.08
		return 0.98

	if build_identity == &"aggression":
		if enemy_scene == _enemy_scene:
			return 1.05
		if enemy_scene == _ranged_enemy_scene:
			return 1.00
		return 0.98

	if build_identity == &"ranged":
		if enemy_scene == _swarm_enemy_scene:
			return 1.08
		if enemy_scene == _ranged_enemy_scene:
			return 0.98
		return 1.02

	if build_identity == &"momentum":
		if enemy_scene == _swarm_enemy_scene:
			return 1.06
		if enemy_scene == _ranged_enemy_scene:
			return 1.00
		return 1.00

	return 1.0

func _current_build_spawn_burst_multiplier() -> float:
	var build_identity: StringName = _current_player_build_identity()

	if build_identity == &"mobility":
		return 1.03

	if build_identity == &"aggression":
		return 0.98

	if build_identity == &"ranged":
		return 1.05

	if build_identity == &"momentum":
		return 1.01

	return 1.0

func _current_landmark_enemy_multiplier(enemy_scene: PackedScene) -> float:
	if _landmark_event_timer <= 0.0 or enemy_scene == null:
		return 1.0

	match _landmark_event_type:
		"swarm_surge":
			if enemy_scene == _swarm_enemy_scene:
				return LANDMARK_EVENT_SWARM_BURST_MULTIPLIER
			if enemy_scene == _ranged_enemy_scene:
				return 0.92
			return 0.96
		"elite_push":
			if enemy_scene == _ranged_enemy_scene:
				return LANDMARK_EVENT_ELITE_BURST_MULTIPLIER
			if enemy_scene == _swarm_enemy_scene:
				return 0.94
			return 0.98
		"melee_rush":
			if enemy_scene == _enemy_scene:
				return LANDMARK_EVENT_MELEE_BURST_MULTIPLIER
			if enemy_scene == _ranged_enemy_scene:
				return 0.90
			return 0.96
		_:
			return 1.0

func _current_build_archetype_multiplier(enemy_scene: PackedScene) -> float:
	if enemy_scene == null:
		return 1.0

	var build_archetype: StringName = _current_player_build_archetype()

	match build_archetype:
		&"mobility":
			if enemy_scene == _ranged_enemy_scene:
				return 1.06
			if enemy_scene == _swarm_enemy_scene:
				return 1.04
			return 0.98
		&"pressure":
			if enemy_scene == _enemy_scene:
				return 1.06
			if enemy_scene == _swarm_enemy_scene:
				return 1.02
			return 0.98
		&"control":
			if enemy_scene == _ranged_enemy_scene:
				return 1.06
			if enemy_scene == _enemy_scene:
				return 0.98
			return 1.00
		&"swarm_clear":
			if enemy_scene == _swarm_enemy_scene:
				return 1.05
			if enemy_scene == _ranged_enemy_scene:
				return 1.03
			return 0.99
		&"positioning":
			if enemy_scene == _ranged_enemy_scene:
				return 1.04
			if enemy_scene == _enemy_scene:
				return 1.02
			return 1.00
		&"momentum":
			if enemy_scene == _swarm_enemy_scene:
				return 1.04
			if enemy_scene == _enemy_scene:
				return 1.02
			return 1.00
		_:
			return 1.0

func _active_enemy_count() -> int:
	return get_tree().get_nodes_in_group("enemy").size()

func _role_enemy_count(group_name: StringName) -> int:
	return get_tree().get_nodes_in_group(group_name).size()

func _current_spawn_interval() -> float:
	var pressure_factor: float = 1.0 + _pressure * 0.20
	var pacing_factor: float = _spawn_pacing_factor()
	var composition_factor: float = _encounter_spawn_factor()
	var stage_factor: float = _current_run_stage_interval_multiplier()
	var loop_factor: float = _current_run_loop_interval_multiplier()
	var boss_factor: float = _current_boss_spawn_interval_multiplier()
	var recovery_factor: float = _current_recovery_window_interval_multiplier()
	var landmark_factor: float = _current_landmark_interval_multiplier()
	var transition_factor: float = _current_stage_transition_interval_multiplier()
	var interval: float = base_spawn_interval / pressure_factor
	interval *= pacing_factor
	interval *= composition_factor
	interval *= stage_factor
	interval *= loop_factor
	interval *= boss_factor
	interval *= recovery_factor
	interval *= landmark_factor
	interval *= transition_factor
	return max(minimum_spawn_interval, interval)

func _current_max_enemies() -> int:
	var time_bonus: int = int(floor(_elapsed_time / 45.0))
	var level_bonus: int = int(floor(float(max(_player_level - 1, 0)) * 0.5))
	var pressure_bonus: int = int(floor(_pressure * 0.75))
	var stage_bonus: int = _current_run_stage_max_enemy_bonus()
	var loop_bonus: int = _current_run_loop_max_enemy_bonus()
	var finale_bonus: int = _current_stage_finale_max_enemy_bonus()
	var boss_penalty: int = _current_boss_max_enemy_penalty()
	var recovery_penalty: int = 0
	if _tempo_relief_timer > 0.0:
		recovery_penalty = RECOVERY_WINDOW_MAX_ENEMY_PENALTY
	var landmark_bonus: int = _current_landmark_max_enemy_bonus()
	var transition_penalty: int = _current_stage_transition_max_enemy_penalty()
	var loop_transition_penalty: int = _current_run_loop_transition_max_enemy_penalty()

	return clampi(base_max_enemies + time_bonus + level_bonus + pressure_bonus + stage_bonus + loop_bonus + finale_bonus + landmark_bonus - recovery_penalty - transition_penalty - loop_transition_penalty - boss_penalty, base_max_enemies, max_enemy_cap)

func _current_pacing_state(active_enemy_count: int) -> String:
	var pressure_threshold: float = _current_run_stage_pressure_threshold()

	if _landmark_event_timer > 0.0:
		return "spike"

	if _stage_transition_timer > 0.0:
		return "transition"

	if _run_loop_transition_timer > 0.0:
		return "loop_transition"

	if _boss_encounter_state == "active":
		return "boss"

	if _stage_finale_timer > 0.0:
		var finale_progress: float = _current_stage_finale_progress()
		if finale_progress < 0.25 and active_enemy_count <= 1 and _pressure < pressure_threshold:
			return "recovery"

		if finale_progress < 0.55 and active_enemy_count <= 2 and _pressure < pressure_threshold:
			return "pressure"

		return "finale"

	if _tempo_relief_timer > 0.0 and active_enemy_count <= 2 and _pressure < pressure_threshold:
		return "recovery"

	if active_enemy_count <= 1 and _pressure < RECOVERY_STATE_THRESHOLD:
		return "recovery"

	if _pressure < LOW_PRESSURE_STATE_THRESHOLD:
		return "low"

	if _pressure < pressure_threshold:
		return "pressure"

	return "high"

# ============================================================================
# ESCALATION
# ============================================================================

func _spawn_pacing_factor() -> float:
	match _pacing_state:
		"transition":
			return 1.18
		"loop_transition":
			return 1.14
		"boss":
			return 1.22
		"finale":
			return 0.86
		"recovery":
			return 1.25
		"low":
			return 1.05
		"pressure":
			return 0.90
		"high":
			return 0.72
		_:
			return 1.0

func _encounter_spawn_factor() -> float:
	if _landmark_event_timer > 0.0:
		return _current_landmark_spawn_multiplier()

	if _run_loop_transition_timer > 0.0:
		return RUN_LOOP_TRANSITION_INTERVAL_MULTIPLIER

	if _boss_encounter_state == "active":
		return BOSS_ENCOUNTER_INTERVAL_MULTIPLIER

	if _stage_finale_timer > 0.0:
		return _current_stage_finale_spawn_multiplier()

	var world_profile_factor: float = _current_world_chunk_spawn_interval_multiplier()

	match _encounter_composition:
		"transition":
			return 1.10 * world_profile_factor
		"recovery":
			return COMPOSITION_RECOVERY_INTERVAL_MULTIPLIER * world_profile_factor
		"build":
			return COMPOSITION_BUILD_INTERVAL_MULTIPLIER * world_profile_factor
		"pressure":
			return COMPOSITION_PRESSURE_INTERVAL_MULTIPLIER * world_profile_factor
		"spike":
			return COMPOSITION_SPIKE_INTERVAL_MULTIPLIER * world_profile_factor
		_:
			return world_profile_factor

func _current_recovery_window_interval_multiplier() -> float:
	if _tempo_relief_timer <= 0.0:
		return 1.0

	return RECOVERY_WINDOW_INTERVAL_MULTIPLIER

func _current_stage_transition_interval_multiplier() -> float:
	if _stage_transition_timer <= 0.0:
		return 1.0

	return RUN_STAGE_TRANSITION_INTERVAL_MULTIPLIER

func _current_world_chunk_spawn_interval_multiplier() -> float:
	match _world_encounter_profile_name:
		"recovery":
			return 1.06
		"open":
			return 1.04
		"pressure":
			return 0.94
		_:
			return 1.0

func _current_world_chunk_spawn_burst_multiplier() -> float:
	match _world_encounter_profile_name:
		"recovery":
			return 0.92
		"open":
			return 0.95
		"pressure":
			return 1.08
		_:
			return 1.0

func _current_world_chunk_enemy_weight_multiplier(enemy_scene: PackedScene) -> float:
	var archetype_multiplier: float = _current_build_archetype_multiplier(enemy_scene)
	var ecology_multiplier: float = _current_ecology_layer_multiplier(enemy_scene)

	if enemy_scene == _ranged_enemy_scene:
		match _world_encounter_profile_name:
			"pressure":
				return 1.18 * archetype_multiplier * ecology_multiplier
			"open":
				return 0.92 * archetype_multiplier * ecology_multiplier
			"recovery":
				return 0.90 * archetype_multiplier * ecology_multiplier
			_:
				return 1.0 * archetype_multiplier * ecology_multiplier

	if enemy_scene == _swarm_enemy_scene:
		match _world_encounter_profile_name:
			"pressure":
				return 1.12 * archetype_multiplier * ecology_multiplier
			"open":
				return 0.88 * archetype_multiplier * ecology_multiplier
			"recovery":
				return 0.86 * archetype_multiplier * ecology_multiplier
			_:
				return 1.0 * archetype_multiplier * ecology_multiplier

	match _world_encounter_profile_name:
		"recovery":
			return 1.08 * archetype_multiplier * ecology_multiplier
		"open":
			return 1.05 * archetype_multiplier * ecology_multiplier
		"pressure":
			return 0.96 * archetype_multiplier * ecology_multiplier
		_:
			return 1.0 * archetype_multiplier * ecology_multiplier

func _current_ecology_layer_state(active_enemy_count: int) -> String:
	var melee_score: int = _role_enemy_count(MELEE_ENEMY_GROUP_NAME) + int(_world_chunk_ecology_counts.get("melee", 0))
	var ranged_score: int = _role_enemy_count(RANGED_ENEMY_GROUP_NAME) + int(_world_chunk_ecology_counts.get("ranged", 0))
	var swarm_score: int = _role_enemy_count(SWARM_ENEMY_GROUP_NAME) + int(_world_chunk_ecology_counts.get("swarm", 0))
	var open_score: int = int(_world_chunk_ecology_counts.get("open", 0))
	var total_layer_score: int = melee_score + ranged_score + swarm_score

	if active_enemy_count <= 1 or _pressure < RECOVERY_STATE_THRESHOLD:
		return "recovery"

	if swarm_score >= melee_score + ranged_score and active_enemy_count >= 4:
		return "swarm_lane"

	if ranged_score >= melee_score and ranged_score >= swarm_score and active_enemy_count >= 3:
		return "anchor"

	if melee_score >= ranged_score + swarm_score and active_enemy_count >= 3:
		return "rush"

	if melee_score > 0 and ranged_score > 0 and swarm_score > 0:
		return "layered"

	if open_score >= 3 and total_layer_score <= 2:
		return "open"

	return "mixed"

func _current_ecology_layer_multiplier(enemy_scene: PackedScene) -> float:
	if enemy_scene == null:
		return 1.0

	match _ecology_layer_state:
		"swarm_lane":
			if enemy_scene == _swarm_enemy_scene:
				return 1.16
			if enemy_scene == _ranged_enemy_scene:
				return 1.06
			return 0.96
		"anchor":
			if enemy_scene == _ranged_enemy_scene:
				return 1.16
			if enemy_scene == _swarm_enemy_scene:
				return 1.04
			return 0.97
		"rush":
			if enemy_scene == _enemy_scene:
				return 1.14
			if enemy_scene == _ranged_enemy_scene:
				return 0.96
			return 1.00
		"layered":
			if enemy_scene == _enemy_scene:
				return 1.04
			if enemy_scene == _ranged_enemy_scene or enemy_scene == _swarm_enemy_scene:
				return 1.08
			return 1.00
		"open":
			if enemy_scene == _enemy_scene:
				return 1.06
			if enemy_scene == _swarm_enemy_scene:
				return 0.94
			return 1.00
		_:
			return 1.0

func _current_world_chunk_elite_multiplier() -> float:
	match _world_encounter_profile_name:
		"pressure":
			return 1.08
		"recovery":
			return 0.96
		"open":
			return 0.98
		_:
			return 1.0

func _current_run_loop_index() -> int:
	if _run_stage != "endless":
		return 0

	var endless_elapsed: float = max(_elapsed_time - RUN_STAGE_LATE_SECONDS, 0.0)
	return int(floor(endless_elapsed / RUN_LOOP_CYCLE_SECONDS))

func _current_run_loop_progress() -> float:
	if _run_stage != "endless":
		return 0.0

	var endless_elapsed: float = max(_elapsed_time - RUN_STAGE_LATE_SECONDS, 0.0)
	var loop_elapsed: float = endless_elapsed - float(_current_run_loop_index()) * RUN_LOOP_CYCLE_SECONDS
	return clamp(loop_elapsed / RUN_LOOP_CYCLE_SECONDS, 0.0, 1.0)

func _current_run_loop_interval_multiplier() -> float:
	if _run_stage != "endless":
		return 1.0

	return clamp(1.0 - float(_run_loop_index) * 0.015, 0.88, 1.0)

func _current_run_loop_pressure_bonus() -> float:
	if _run_stage != "endless":
		return 0.0

	var loop_progress: float = _current_run_loop_progress()
	var loop_index_bonus: float = float(_run_loop_index) * RUN_LOOP_PRESSURE_STEP
	var loop_progress_bonus: float = loop_progress * RUN_LOOP_PRESSURE_PROGRESS_STEP
	return loop_index_bonus + loop_progress_bonus

func _current_run_loop_spawn_multiplier() -> float:
	if _run_stage != "endless":
		return 1.0

	var loop_progress: float = _current_run_loop_progress()
	var loop_index_bonus: float = float(_run_loop_index) * RUN_LOOP_SPAWN_BURST_STEP
	return max(0.84, 1.0 - loop_index_bonus - loop_progress * 0.04)

func _current_run_loop_max_enemy_bonus() -> int:
	if _run_stage != "endless":
		return 0

	return int(floor(float(_run_loop_index) * float(RUN_LOOP_MAX_ENEMY_BONUS_STEP) * 0.5))

func _current_run_loop_elite_multiplier() -> float:
	if _run_stage != "endless":
		return 1.0

	return 1.0 + float(_run_loop_index) * RUN_LOOP_ELITE_MULTIPLIER_STEP

func _current_boss_spawn_interval_multiplier() -> float:
	if _boss_encounter_state != "active":
		return 1.0

	return BOSS_ENCOUNTER_INTERVAL_MULTIPLIER

func _current_boss_pressure_bonus() -> float:
	match _boss_encounter_state:
		"primed":
			return BOSS_PRIMED_PRESSURE_BONUS
		"active":
			return BOSS_ACTIVE_PRESSURE_BONUS
		_:
			return 0.0

func _current_boss_max_enemy_penalty() -> int:
	if _boss_encounter_state != "active":
		return 0

	return BOSS_MAX_ENEMY_PENALTY

func _current_boss_role() -> StringName:
	var recovery_count: int = int(_world_chunk_ecology_counts.get(WORLD_CHUNK_CATEGORY_RECOVERY, 0))
	var traversal_count: int = int(_world_chunk_ecology_counts.get(WORLD_CHUNK_CATEGORY_TRAVERSAL, 0))
	var pressure_count: int = int(_world_chunk_ecology_counts.get(WORLD_CHUNK_CATEGORY_PRESSURE, 0))
	var swarm_count: int = int(_world_chunk_ecology_counts.get("swarm", 0))
	var ranged_count: int = int(_world_chunk_ecology_counts.get("ranged", 0))
	var melee_count: int = int(_world_chunk_ecology_counts.get("melee", 0))
	var active_swarm_count: int = _role_enemy_count(SWARM_ENEMY_GROUP_NAME)
	var active_ranged_count: int = _role_enemy_count(RANGED_ENEMY_GROUP_NAME)
	var active_melee_count: int = _role_enemy_count(MELEE_ENEMY_GROUP_NAME)

	if active_swarm_count >= max(active_ranged_count + 1, active_melee_count) or (swarm_count >= ranged_count + 1 and swarm_count >= melee_count and (_encounter_composition == "pressure" or _encounter_composition == "spike" or _encounter_composition == "finale")):
		return &"swarm"

	if active_ranged_count >= active_melee_count or ranged_count > melee_count or pressure_count + ranged_count >= recovery_count + traversal_count + melee_count:
		return &"control"

	return &"pursuer"

func get_boss_encounter_state() -> String:
	return _boss_encounter_state

func get_boss_encounter_role() -> StringName:
	return _current_boss_role()

func get_boss_encounter_phase() -> int:
	var boss_node: Node2D = _current_active_boss_node()
	if boss_node != null and boss_node.has_method("get_boss_phase"):
		return int(boss_node.call("get_boss_phase"))

	return 0

func get_boss_survival_state() -> StringName:
	var boss_node: Node2D = _current_active_boss_node()
	if boss_node != null and boss_node.has_method("get_boss_survival_state"):
		return StringName(boss_node.call("get_boss_survival_state"))

	return &"none"

func _current_run_loop_label() -> String:
	if _run_stage != "endless":
		return "none"

	if _run_loop_transition_timer > 0.0:
		return _run_loop_transition_label

	return "loop_%d" % _run_loop_index

func _current_stage_finale_window_seconds() -> float:
	match _run_stage:
		"early":
			return RUN_STAGE_EARLY_FINALE_WINDOW_SECONDS
		"mid":
			return RUN_STAGE_MID_FINALE_WINDOW_SECONDS
		"late":
			return RUN_STAGE_LATE_FINALE_WINDOW_SECONDS
		_:
			return 0.0

func _current_run_stage_end_time() -> float:
	match _run_stage:
		"early":
			return RUN_STAGE_EARLY_SECONDS
		"mid":
			return RUN_STAGE_MID_SECONDS
		"late":
			return RUN_STAGE_LATE_SECONDS
		_:
			return 0.0

func _current_stage_finale_progress() -> float:
	var finale_window: float = _current_stage_finale_window_seconds()
	if finale_window <= 0.0 or _stage_finale_timer <= 0.0:
		return 0.0

	return clamp(1.0 - (_stage_finale_timer / finale_window), 0.0, 1.0)

func _current_stage_finale_label(remaining_seconds: float) -> String:
	var finale_window: float = _current_stage_finale_window_seconds()
	if finale_window <= 0.0 or remaining_seconds <= 0.0:
		return "none"

	var finale_progress: float = clamp(1.0 - (remaining_seconds / finale_window), 0.0, 1.0)
	if finale_progress >= 0.72:
		return "climax"

	if finale_progress >= 0.34:
		return "pressure"

	return "buildup"

func _current_stage_finale_pressure_bonus() -> float:
	var finale_progress: float = _current_stage_finale_progress()
	if finale_progress <= 0.0:
		return 0.0

	match _run_stage:
		"early":
			return finale_progress * RUN_STAGE_EARLY_FINALE_PRESSURE_BONUS
		"mid":
			return finale_progress * RUN_STAGE_MID_FINALE_PRESSURE_BONUS
		"late":
			return finale_progress * RUN_STAGE_LATE_FINALE_PRESSURE_BONUS
		_:
			return 0.0

func _current_stage_finale_spawn_multiplier() -> float:
	var finale_progress: float = _current_stage_finale_progress()
	if finale_progress <= 0.0:
		return 1.0

	match _run_stage:
		"early":
			return 1.0 - finale_progress * (1.0 - RUN_STAGE_EARLY_FINALE_INTERVAL_MULTIPLIER)
		"mid":
			return 1.0 - finale_progress * (1.0 - RUN_STAGE_MID_FINALE_INTERVAL_MULTIPLIER)
		"late":
			return 1.0 - finale_progress * (1.0 - RUN_STAGE_LATE_FINALE_INTERVAL_MULTIPLIER)
		_:
			return 1.0

func _current_stage_finale_max_enemy_bonus() -> int:
	var finale_progress: float = _current_stage_finale_progress()
	if finale_progress <= 0.0:
		return 0

	match _run_stage:
		"early":
			return int(floor(finale_progress * float(RUN_STAGE_EARLY_FINALE_MAX_ENEMY_BONUS)))
		"mid":
			return int(floor(finale_progress * float(RUN_STAGE_MID_FINALE_MAX_ENEMY_BONUS)))
		"late":
			return int(floor(finale_progress * float(RUN_STAGE_LATE_FINALE_MAX_ENEMY_BONUS)))
		_:
			return 0

func _current_stage_finale_elite_multiplier() -> float:
	var finale_progress: float = _current_stage_finale_progress()
	if finale_progress <= 0.0:
		return 1.0

	match _run_stage:
		"early":
			return 1.0 + finale_progress * (RUN_STAGE_EARLY_FINALE_ELITE_MULTIPLIER - 1.0)
		"mid":
			return 1.0 + finale_progress * (RUN_STAGE_MID_FINALE_ELITE_MULTIPLIER - 1.0)
		"late":
			return 1.0 + finale_progress * (RUN_STAGE_LATE_FINALE_ELITE_MULTIPLIER - 1.0)
		_:
			return 1.0

func _current_stage_transition_max_enemy_penalty() -> int:
	if _stage_transition_timer <= 0.0:
		return 0

	return RUN_STAGE_TRANSITION_MAX_ENEMY_PENALTY

func _current_run_loop_transition_max_enemy_penalty() -> int:
	if _run_loop_transition_timer <= 0.0:
		return 0

	return RUN_LOOP_TRANSITION_MAX_ENEMY_PENALTY

func _current_landmark_interval_multiplier() -> float:
	if _landmark_event_timer <= 0.0:
		return 1.0

	match _landmark_event_type:
		"swarm_surge":
			return LANDMARK_EVENT_SWARM_INTERVAL_MULTIPLIER
		"elite_push":
			return LANDMARK_EVENT_ELITE_INTERVAL_MULTIPLIER
		"melee_rush":
			return LANDMARK_EVENT_MELEE_INTERVAL_MULTIPLIER
		_:
			return 1.0

func _current_landmark_spawn_multiplier() -> float:
	match _landmark_event_type:
		"swarm_surge":
			return 0.92
		"elite_push":
			return 0.98
		"melee_rush":
			return 0.95
		_:
			return 1.0

func _current_landmark_max_enemy_bonus() -> int:
	if _landmark_event_timer <= 0.0:
		return 0

	match _landmark_event_type:
		"swarm_surge":
			return LANDMARK_EVENT_MAX_ENEMY_BONUS
		"elite_push":
			return 0
		"melee_rush":
			return 0
		_:
			return 0

func _current_run_stage() -> String:
	if _elapsed_time < RUN_STAGE_EARLY_SECONDS:
		return "early"

	if _elapsed_time < RUN_STAGE_MID_SECONDS:
		return "mid"

	if _elapsed_time < RUN_STAGE_LATE_SECONDS:
		return "late"

	return "endless"

func get_run_stage() -> String:
	return _run_stage

func get_pacing_state() -> String:
	return _pacing_state

func get_encounter_composition() -> String:
	return _encounter_composition

func get_pressure() -> float:
	return _pressure

func get_landmark_event_type() -> String:
	return _landmark_event_type

func get_stage_finale_state() -> String:
	return _stage_finale_label

func get_stage_finale_progress() -> float:
	return _current_stage_finale_progress()

func get_run_loop_index() -> int:
	return _run_loop_index

func get_run_loop_state() -> String:
	if _run_stage != "endless":
		return "none"

	if _run_loop_transition_timer > 0.0:
		return "loop_transition"

	return _current_run_loop_label()

func get_run_loop_progress() -> float:
	return _current_run_loop_progress()

func _current_run_stage_interval_multiplier() -> float:
	match _run_stage:
		"early":
			return RUN_STAGE_EARLY_INTERVAL_MULTIPLIER
		"mid":
			return RUN_STAGE_MID_INTERVAL_MULTIPLIER
		"late":
			return RUN_STAGE_LATE_INTERVAL_MULTIPLIER
		"endless":
			return RUN_STAGE_ENDLESS_INTERVAL_MULTIPLIER
		_:
			return 1.0

func _current_run_stage_recovery_gain_multiplier() -> float:
	match _run_stage:
		"early":
			return RUN_STAGE_EARLY_RECOVERY_GAIN_MULTIPLIER
		"mid":
			return RUN_STAGE_MID_RECOVERY_GAIN_MULTIPLIER
		"late":
			return RUN_STAGE_LATE_RECOVERY_GAIN_MULTIPLIER
		"endless":
			return RUN_STAGE_ENDLESS_RECOVERY_GAIN_MULTIPLIER
		_:
			return 1.0

func _current_run_stage_recovery_decay_multiplier() -> float:
	match _run_stage:
		"early":
			return RUN_STAGE_EARLY_RECOVERY_DECAY_MULTIPLIER
		"mid":
			return RUN_STAGE_MID_RECOVERY_DECAY_MULTIPLIER
		"late":
			return RUN_STAGE_LATE_RECOVERY_DECAY_MULTIPLIER
		"endless":
			return RUN_STAGE_ENDLESS_RECOVERY_DECAY_MULTIPLIER
		_:
			return 1.0

func _current_run_stage_combat_gain_multiplier() -> float:
	return _current_run_stage_recovery_gain_multiplier()

func _current_run_stage_combat_decay_multiplier() -> float:
	return _current_run_stage_recovery_decay_multiplier()

func _current_run_stage_max_enemy_bonus() -> int:
	match _run_stage:
		"early":
			return 0
		"mid":
			return 1
		"late":
			return 2
		"endless":
			return 3
		_:
			return 0

# ============================================================================
# SPAWNING
# ============================================================================

func _try_spawn_enemy() -> void:
	if _player == null:
		return

	if _spawn_timer > 0.0:
		return

	if _try_spawn_boss():
		_spawn_timer = _current_spawn_interval()
		return

	if _boss_encounter_state == "active":
		if _try_spawn_boss_support():
			_spawn_timer = _current_spawn_interval()
		else:
			_spawn_timer = max(_current_spawn_interval(), base_spawn_interval * 1.10)
		return

	if _active_enemy_count() >= _current_max_enemies():
		_spawn_timer = _current_spawn_interval()
		return

	var enemy_scene: PackedScene = _select_enemy_scene()
	if enemy_scene == null:
		return

	var spawned_any_enemy: bool = false
	var spawn_group_size: int = _current_spawn_group_size(enemy_scene)
	for spawn_index: int in range(spawn_group_size):
		if _active_enemy_count() >= _current_max_enemies():
			break

		var spawn_scene: PackedScene = enemy_scene
		if spawn_index > 0:
			spawn_scene = _select_followup_enemy_scene(enemy_scene)

		var spawn_marker: Marker2D = _pick_spawn_marker(spawn_scene)
		if spawn_marker == null:
			continue

		var enemy_instance: Node2D = spawn_scene.instantiate() as Node2D
		if enemy_instance == null:
			continue

		if spawn_index == 0:
			var elite_type: StringName = _select_elite_type_for_spawn(spawn_scene)
			if elite_type != &"" and enemy_instance.has_method("configure_elite"):
				enemy_instance.call("configure_elite", elite_type)

		if enemy_instance.has_method("configure_counterplay"):
			enemy_instance.call("configure_counterplay", _current_player_build_identity())

		enemy_instance.position = _gameplay_root.to_local(spawn_marker.global_position)
		_gameplay_root.add_child(enemy_instance)
		spawned_any_enemy = true

	if spawned_any_enemy:
		_spawn_timer = _current_spawn_interval()
	else:
		_spawn_timer = max(_current_spawn_interval(), base_spawn_interval * 0.75)

func _select_followup_enemy_scene(primary_scene: PackedScene) -> PackedScene:
	var melee_count: int = _role_enemy_count(MELEE_ENEMY_GROUP_NAME)
	var ranged_count: int = _role_enemy_count(RANGED_ENEMY_GROUP_NAME)
	var swarm_count: int = _role_enemy_count(SWARM_ENEMY_GROUP_NAME)
	var current_state: String = _encounter_composition
	var active_enemy_count: int = _active_enemy_count()
	var build_multiplier: float = _current_build_role_multiplier(primary_scene)
	var landmark_multiplier: float = _current_landmark_enemy_multiplier(primary_scene)
	var ecology_multiplier: float = _current_world_chunk_enemy_weight_multiplier(primary_scene)

	if primary_scene == _swarm_enemy_scene:
		if current_state == "spike" and _active_enemy_count() >= 4 and swarm_count < 2 and randf() < build_multiplier * landmark_multiplier * ecology_multiplier * 0.5:
			return _swarm_enemy_scene

		return _enemy_scene

	if primary_scene == _ranged_enemy_scene:
		if current_state == "spike" and _swarm_enemy_scene != null and _active_enemy_count() >= 5 and swarm_count < 2 and randf() < 0.35 * build_multiplier * landmark_multiplier * ecology_multiplier:
			return _swarm_enemy_scene

		return _enemy_scene

	if current_state == "recovery":
		return _enemy_scene

	if current_state == "build":
		if _ranged_enemy_scene != null and ranged_count < melee_count and randf() < 0.55 * _current_build_role_multiplier(_ranged_enemy_scene) * landmark_multiplier * ecology_multiplier:
			return _ranged_enemy_scene

		return _enemy_scene

	if current_state == "pressure":
		if _ranged_enemy_scene != null and ranged_count < melee_count and randf() < 0.60 * _current_build_role_multiplier(_ranged_enemy_scene) * landmark_multiplier * ecology_multiplier:
			return _ranged_enemy_scene

		if _swarm_enemy_scene != null and active_enemy_count >= 4 and swarm_count < max(1, int(floor(float(active_enemy_count) * 0.25))) and randf() < 0.16 * _current_build_role_multiplier(_swarm_enemy_scene) * landmark_multiplier * ecology_multiplier:
			return _swarm_enemy_scene

		return _enemy_scene

	if current_state == "spike":
		if _swarm_enemy_scene != null and active_enemy_count >= 4 and swarm_count < max(1, int(floor(float(active_enemy_count) * 0.25))) and randf() < 0.38 * _current_build_role_multiplier(_swarm_enemy_scene) * landmark_multiplier * ecology_multiplier:
			return _swarm_enemy_scene

		if _ranged_enemy_scene != null and ranged_count <= melee_count and randf() < 0.30 * _current_build_role_multiplier(_ranged_enemy_scene) * landmark_multiplier * ecology_multiplier:
			return _ranged_enemy_scene

		return _enemy_scene

	if current_state == "finale":
		if _swarm_enemy_scene != null and active_enemy_count >= 4 and swarm_count < 2 and randf() < 0.26 * _current_build_role_multiplier(_swarm_enemy_scene) * landmark_multiplier * ecology_multiplier:
			return _swarm_enemy_scene

		if _ranged_enemy_scene != null and ranged_count <= melee_count and randf() < 0.68 * _current_build_role_multiplier(_ranged_enemy_scene) * landmark_multiplier * ecology_multiplier:
			return _ranged_enemy_scene

		return _enemy_scene

	return _enemy_scene

func _select_enemy_scene() -> PackedScene:
	if _ranged_enemy_scene == null and _swarm_enemy_scene == null:
		return _enemy_scene

	var current_state: String = _encounter_composition
	var melee_count: int = _role_enemy_count(MELEE_ENEMY_GROUP_NAME)
	var ranged_count: int = _role_enemy_count(RANGED_ENEMY_GROUP_NAME)
	var swarm_count: int = _role_enemy_count(SWARM_ENEMY_GROUP_NAME)
	var active_enemy_count: int = _active_enemy_count()
	var roll: float = randf()
	var melee_weight: float = MELEE_ENEMY_WEIGHT * _current_build_role_multiplier(_enemy_scene) * _current_world_chunk_enemy_weight_multiplier(_enemy_scene)
	var ranged_weight: float = 0.0
	var swarm_weight: float = 0.0
	var landmark_melee_multiplier: float = _current_landmark_enemy_multiplier(_enemy_scene)
	if _ranged_enemy_scene != null:
		ranged_weight = RANGED_ENEMY_WEIGHT * _current_build_role_multiplier(_ranged_enemy_scene) * _current_landmark_enemy_multiplier(_ranged_enemy_scene) * _current_world_chunk_enemy_weight_multiplier(_ranged_enemy_scene)
	if _swarm_enemy_scene != null:
		swarm_weight = SWARM_ENEMY_WEIGHT * _current_build_role_multiplier(_swarm_enemy_scene) * _current_landmark_enemy_multiplier(_swarm_enemy_scene) * _current_world_chunk_enemy_weight_multiplier(_swarm_enemy_scene)
	melee_weight *= landmark_melee_multiplier
	var total_weight: float = melee_weight + ranged_weight + swarm_weight

	if current_state == "recovery":
		return _enemy_scene

	if current_state == "build":
		if active_enemy_count <= 2:
			return _enemy_scene

		if melee_count <= ranged_count + swarm_count:
			return _enemy_scene

		if _ranged_enemy_scene != null and ranged_count == 0 and roll < 0.25 * _current_build_role_multiplier(_ranged_enemy_scene) * _current_world_chunk_enemy_weight_multiplier(_ranged_enemy_scene):
			return _ranged_enemy_scene

		return _enemy_scene

	if current_state == "pressure":
		if melee_count <= 1:
			return _enemy_scene

		if _ranged_enemy_scene != null and ranged_count < max(1, int(floor(float(melee_count) * 0.5))) and roll < 0.55 * _current_build_role_multiplier(_ranged_enemy_scene) * _current_world_chunk_enemy_weight_multiplier(_ranged_enemy_scene):
			return _ranged_enemy_scene

		if _swarm_enemy_scene != null and active_enemy_count >= 4 and swarm_count < max(1, int(floor(float(active_enemy_count) * 0.25))) and roll < 0.16 * _current_build_role_multiplier(_swarm_enemy_scene) * _current_world_chunk_enemy_weight_multiplier(_swarm_enemy_scene):
			return _swarm_enemy_scene

		return _enemy_scene

	if current_state == "spike":
		if _swarm_enemy_scene != null and active_enemy_count >= 4 and swarm_count < max(1, int(floor(float(active_enemy_count) * 0.25))) and roll < 0.38 * _current_build_role_multiplier(_swarm_enemy_scene) * _current_world_chunk_enemy_weight_multiplier(_swarm_enemy_scene):
			return _swarm_enemy_scene

		if _ranged_enemy_scene != null and ranged_count <= melee_count and roll < 0.78 * _current_build_role_multiplier(_ranged_enemy_scene) * _current_world_chunk_enemy_weight_multiplier(_ranged_enemy_scene):
			return _ranged_enemy_scene

		return _enemy_scene

	if current_state == "finale":
		if active_enemy_count <= 1:
			return _enemy_scene

		if _swarm_enemy_scene != null and active_enemy_count >= 4 and swarm_count < max(1, int(floor(float(active_enemy_count) * 0.25))) and roll < 0.28 * _current_build_role_multiplier(_swarm_enemy_scene) * _current_world_chunk_enemy_weight_multiplier(_swarm_enemy_scene):
			return _swarm_enemy_scene

		if _ranged_enemy_scene != null and ranged_count <= melee_count and roll < 0.72 * _current_build_role_multiplier(_ranged_enemy_scene) * _current_world_chunk_enemy_weight_multiplier(_ranged_enemy_scene):
			return _ranged_enemy_scene

		return _enemy_scene

	if roll < melee_weight:
		return _enemy_scene

	if _ranged_enemy_scene != null and roll < melee_weight + ranged_weight:
		return _ranged_enemy_scene

	if _swarm_enemy_scene != null and roll < total_weight:
		return _swarm_enemy_scene

	return _enemy_scene

func _load_ranged_enemy_scene() -> PackedScene:
	if not FileAccess.file_exists(RANGED_ENEMY_SCENE_PATH):
		return null

	var ranged_scene: PackedScene = load(RANGED_ENEMY_SCENE_PATH)
	return ranged_scene

func _load_swarm_enemy_scene() -> PackedScene:
	if not FileAccess.file_exists(SWARM_ENEMY_SCENE_PATH):
		return null

	var swarm_scene: PackedScene = load(SWARM_ENEMY_SCENE_PATH)
	return swarm_scene

func _load_boss_enemy_scene() -> PackedScene:
	if not FileAccess.file_exists(BOSS_ENEMY_SCENE_PATH):
		return null

	var boss_scene: PackedScene = load(BOSS_ENEMY_SCENE_PATH)
	return boss_scene

# ============================================================================
# ELITE MODIFIERS
# ============================================================================

func _select_elite_type_for_spawn(enemy_scene: PackedScene) -> StringName:
	if _active_elite_count() >= _current_elite_cap():
		return &""

	var elite_chance: float = _current_elite_chance()
	if randf() > elite_chance:
		return &""

	if enemy_scene == _ranged_enemy_scene:
		return _select_ranged_elite_type()

	if enemy_scene == _swarm_enemy_scene:
		return _select_swarm_elite_type()

	return _select_melee_elite_type()

func _current_elite_chance() -> float:
	var time_bonus: float = _elapsed_time * ELITE_TIME_WEIGHT
	var pressure_bonus: float = _pressure * ELITE_PRESSURE_WEIGHT
	var level_bonus: float = float(max(_player_level - 1, 0)) * ELITE_LEVEL_WEIGHT
	var stage_multiplier: float = _current_run_stage_elite_multiplier()
	var loop_multiplier: float = _current_run_loop_elite_multiplier()
	var finale_multiplier: float = _current_stage_finale_elite_multiplier()
	var ecology_multiplier: float = _current_world_chunk_elite_multiplier()
	var landmark_multiplier: float = 1.0
	if _landmark_event_timer > 0.0 and _landmark_event_type == "elite_push":
		landmark_multiplier = 1.35

	return clamp((ELITE_BASE_CHANCE + time_bonus + pressure_bonus + level_bonus) * stage_multiplier * loop_multiplier * finale_multiplier * ecology_multiplier * landmark_multiplier, 0.0, ELITE_MAX_CHANCE)

func _current_run_stage_elite_multiplier() -> float:
	match _run_stage:
		"early":
			return RUN_STAGE_EARLY_ELITE_MULTIPLIER
		"mid":
			return RUN_STAGE_MID_ELITE_MULTIPLIER
		"late":
			return RUN_STAGE_LATE_ELITE_MULTIPLIER
		"endless":
			return RUN_STAGE_ENDLESS_ELITE_MULTIPLIER
		_:
			return 1.0

func _current_encounter_composition(active_enemy_count: int) -> String:
	if _pacing_state == "recovery" or _recovery_pressure_buffer >= 1.0:
		return "recovery"

	if _run_loop_transition_timer > 0.0:
		return "transition"

	if _boss_encounter_state == "active":
		return "boss"

	var build_threshold: float = _current_run_stage_build_threshold()
	var pressure_threshold: float = _current_run_stage_pressure_threshold()
	var finale_progress: float = _current_stage_finale_progress()

	if finale_progress > 0.55:
		if active_enemy_count <= 1 and _recent_combat_intensity < 0.8:
			return "pressure"

		return "finale"

	if _pressure < build_threshold:
		if active_enemy_count <= 2 and _recent_combat_intensity < 0.8:
			return "recovery"

		return "build"

	if _pressure < pressure_threshold:
		if _recent_combat_intensity < 1.1 and active_enemy_count <= max(2, int(floor(float(_current_max_enemies()) * 0.5))):
			return "build"

		return "pressure"

	return "spike"

func _current_run_stage_build_threshold() -> float:
	match _run_stage:
		"early":
			return RUN_STAGE_EARLY_BUILD_THRESHOLD
		"mid":
			return RUN_STAGE_MID_BUILD_THRESHOLD
		"late":
			return RUN_STAGE_LATE_BUILD_THRESHOLD
		"endless":
			return RUN_STAGE_ENDLESS_BUILD_THRESHOLD
		_:
			return RUN_STAGE_EARLY_BUILD_THRESHOLD

func _current_run_stage_pressure_threshold() -> float:
	match _run_stage:
		"early":
			return RUN_STAGE_EARLY_PRESSURE_THRESHOLD
		"mid":
			return RUN_STAGE_MID_PRESSURE_THRESHOLD
		"late":
			return RUN_STAGE_LATE_PRESSURE_THRESHOLD
		"endless":
			return RUN_STAGE_ENDLESS_PRESSURE_THRESHOLD
		_:
			return RUN_STAGE_EARLY_PRESSURE_THRESHOLD

func _current_elite_cap() -> int:
	return clampi(1 + int(floor(_elapsed_time / 300.0)), 1, 3)

func _active_elite_count() -> int:
	return get_tree().get_nodes_in_group("elite").size()

func _select_melee_elite_type() -> StringName:
	var roll: float = randf()
	if roll < 0.50:
		return ELITE_BERSERKER

	if roll < 0.85:
		return ELITE_TITAN

	return ELITE_VOLTAIC

func _select_ranged_elite_type() -> StringName:
	var roll: float = randf()
	if roll < 0.45:
		return ELITE_VOLTAIC

	if roll < 0.80:
		return ELITE_BERSERKER

	return ELITE_TITAN

func _select_swarm_elite_type() -> StringName:
	var roll: float = randf()
	if roll < 0.55:
		return ELITE_BERSERKER

	if roll < 0.88:
		return ELITE_TITAN

	return ELITE_VOLTAIC

func _current_spawn_group_size(enemy_scene: PackedScene) -> int:
	var current_state: String = _encounter_composition
	var active_enemy_count: int = _active_enemy_count()
	var stage_burst_chance: float = _current_run_stage_spawn_burst_chance() * _current_build_spawn_burst_multiplier() * _current_world_chunk_spawn_burst_multiplier()
	var landmark_burst_multiplier: float = 1.0
	if _landmark_event_timer > 0.0:
		landmark_burst_multiplier = _current_landmark_spawn_multiplier()

	if current_state == "recovery":
		return 1

	if current_state == "build":
		if active_enemy_count <= 2 and randf() < stage_burst_chance * 0.6 * landmark_burst_multiplier:
			return 2

		return 1

	if current_state == "pressure":
		if enemy_scene == _swarm_enemy_scene and _burst_timer <= 0.0 and active_enemy_count >= 4 and randf() < stage_burst_chance * landmark_burst_multiplier:
			_burst_timer = burst_cooldown_seconds * 0.75
			return 2

		if enemy_scene == _ranged_enemy_scene and randf() < (stage_burst_chance + 0.10) * landmark_burst_multiplier:
			return 2

		if randf() < stage_burst_chance * landmark_burst_multiplier:
			return 2

		return 1

	if current_state == "spike":
		if enemy_scene == _swarm_enemy_scene and _burst_timer <= 0.0 and active_enemy_count >= 4 and randf() < min(stage_burst_chance + 0.12, 0.55) * landmark_burst_multiplier:
			_burst_timer = burst_cooldown_seconds * 0.75
			return 2

		if _burst_timer <= 0.0 and randf() < max(stage_burst_chance, HIGH_PRESSURE_BURST_CHANCE) * landmark_burst_multiplier:
			_burst_timer = burst_cooldown_seconds
			return 2

		return 1

	if current_state == "finale":
		if enemy_scene == _swarm_enemy_scene and _burst_timer <= 0.0 and active_enemy_count >= 4 and randf() < min(stage_burst_chance + 0.10, 0.50) * landmark_burst_multiplier:
			_burst_timer = burst_cooldown_seconds * 0.85
			return 2

		if _burst_timer <= 0.0 and randf() < min(max(stage_burst_chance + 0.08, HIGH_PRESSURE_BURST_CHANCE), 0.48) * landmark_burst_multiplier:
			_burst_timer = burst_cooldown_seconds * 0.90
			return 2

		return 1

	if _pacing_state == "high" and _pressure >= HIGH_PRESSURE_BURST_THRESHOLD and _burst_timer <= 0.0:
		if randf() < max(stage_burst_chance, HIGH_PRESSURE_BURST_CHANCE) * landmark_burst_multiplier:
			_burst_timer = burst_cooldown_seconds
			return 2

	if _pacing_state == "pressure" and randf() < 0.20:
		return 2

	return 1

func _current_run_stage_spawn_burst_chance() -> float:
	var base_chance: float = 0.0

	match _run_stage:
		"early":
			base_chance = RUN_STAGE_EARLY_SPAWN_BURST_CHANCE
		"mid":
			base_chance = RUN_STAGE_MID_SPAWN_BURST_CHANCE
		"late":
			base_chance = RUN_STAGE_LATE_SPAWN_BURST_CHANCE
		"endless":
			base_chance = RUN_STAGE_ENDLESS_SPAWN_BURST_CHANCE
		_:
			base_chance = RUN_STAGE_EARLY_SPAWN_BURST_CHANCE

	if _run_stage == "endless":
		base_chance = base_chance * _current_run_loop_spawn_multiplier()
		base_chance += float(_run_loop_index) * RUN_LOOP_SPAWN_BURST_STEP

	return min(base_chance, 0.55)

func _pick_spawn_marker(enemy_scene: PackedScene) -> Marker2D:
	var preferred_roots: Array[Node2D] = _preferred_spawn_roots(enemy_scene)
	var fallback_roots: Array[Node2D] = []

	for spawn_root: Node2D in preferred_roots:
		if spawn_root == _last_spawn_zone_root and preferred_roots.size() > 1:
			fallback_roots.append(spawn_root)
			continue

		var zone_marker: Marker2D = _pick_spawn_marker_from_root(spawn_root)
		if zone_marker != null:
			_last_spawn_zone_root = spawn_root
			return zone_marker

	for spawn_root: Node2D in fallback_roots:
		var fallback_marker: Marker2D = _pick_spawn_marker_from_root(spawn_root)
		if fallback_marker != null:
			_last_spawn_zone_root = spawn_root
			return fallback_marker

	return _pick_spawn_marker_from_root(_enemy_spawn_root)

func _preferred_spawn_roots(enemy_scene: PackedScene) -> Array[Node2D]:
	var preferred_roots: Array[Node2D] = []
	var is_ranged_enemy: bool = enemy_scene == _ranged_enemy_scene
	var is_swarm_enemy: bool = enemy_scene == _swarm_enemy_scene

	if is_swarm_enemy:
		_append_root(preferred_roots, _mixed_spawn_zone_root)
		_append_root(preferred_roots, _melee_spawn_zone_root)
		_append_root(preferred_roots, _mixed_spawn_zone_root)
		return preferred_roots

	if is_ranged_enemy:
		_append_root(preferred_roots, _ranged_spawn_zone_root)
		_append_root(preferred_roots, _mixed_spawn_zone_root)
		_append_root(preferred_roots, _ranged_spawn_zone_root)
		return preferred_roots

	_append_root(preferred_roots, _melee_spawn_zone_root)
	_append_root(preferred_roots, _mixed_spawn_zone_root)
	_append_root(preferred_roots, _melee_spawn_zone_root)
	return preferred_roots

func _append_root(root_list: Array[Node2D], root: Node2D) -> void:
	if root == null:
		return

	root_list.append(root)

func _pick_spawn_marker_from_root(spawn_root: Node2D) -> Marker2D:
	if spawn_root == null:
		return null

	var candidates: Array[Marker2D] = []

	for child: Node in spawn_root.get_children():
		if child is not Marker2D:
			continue

		var marker: Marker2D = child
		if _is_valid_spawn_marker(marker):
			candidates.append(marker)

	if candidates.is_empty():
		return null

	var random_index: int = randi_range(0, candidates.size() - 1)
	return candidates[random_index]

func _is_valid_spawn_marker(marker: Marker2D) -> bool:
	var spawn_position: Vector2 = marker.global_position
	if spawn_position.distance_to(_player.global_position) < min_spawn_distance_from_player:
		return false

	if not _is_outside_player_view(spawn_position):
		return false

	if _is_spawn_blocked(spawn_position):
		return false

	return true

func _is_outside_player_view(spawn_position: Vector2) -> bool:
	var camera: Camera2D = _player.get_node_or_null("Camera2D") as Camera2D
	if camera == null:
		return abs(spawn_position.x - _player.global_position.x) >= min_spawn_distance_from_player

	var viewport_size: Vector2 = camera.get_viewport_rect().size / camera.zoom
	var visible_rect: Rect2 = Rect2(
		camera.global_position - viewport_size * 0.5 - VIEW_MARGIN,
		viewport_size + VIEW_MARGIN * 2.0
	)
	return not visible_rect.has_point(spawn_position)

func _is_spawn_blocked(spawn_position: Vector2) -> bool:
	var query: PhysicsShapeQueryParameters2D = PhysicsShapeQueryParameters2D.new()
	query.shape = _spawn_shape
	query.transform = Transform2D(0.0, spawn_position + SPAWN_BODY_OFFSET)
	query.collide_with_areas = false
	query.collide_with_bodies = true

	var direct_space_state: PhysicsDirectSpaceState2D = _gameplay_root.get_world_2d().direct_space_state
	var collisions: Array[Dictionary] = direct_space_state.intersect_shape(query)
	return not collisions.is_empty()

# ============================================================================
# DEBUG
# ============================================================================

func _setup_debug_ui() -> void:
	if _debug_layer != null:
		return

	_debug_layer = CanvasLayer.new()
	_debug_layer.layer = 90
	add_child(_debug_layer)

	_debug_label = Label.new()
	_debug_label.name = "DirectorDebug"
	_debug_label.position = Vector2(12.0, 12.0)
	_debug_label.add_theme_font_size_override("font_size", 14)
	_debug_label.modulate = Color(0.95, 0.98, 1.0, 0.92)
	_debug_layer.add_child(_debug_label)

func _update_debug(delta: float) -> void:
	_debug_timer -= delta
	if _debug_label != null:
		_debug_label.text = "PRES: %.2f\nENEMIES: %d/%d\nMELEE/RNG/SWM: %d/%d/%d\nELITES: %d/%d\nCD: %.2f\nSTATE: %s\nCOMP: %s\nECO: %s\nRUN: %s\nLOOP: %s #%d %.2f\nPOOL: %s\nPROFILE: %s\nBOSS: %s %s\nBUILD: %s\nFINALE: %s %.2f\nRELIEF: %.2f\nTRANS: %s %.2f\nEVENT: %s %.2f" % [
			_pressure,
			_active_enemy_count(),
			_current_max_enemies(),
			_role_enemy_count(MELEE_ENEMY_GROUP_NAME),
			_role_enemy_count(RANGED_ENEMY_GROUP_NAME),
			_role_enemy_count(SWARM_ENEMY_GROUP_NAME),
			_active_elite_count(),
			_current_elite_cap(),
			max(_spawn_timer, 0.0),
			_pacing_state,
			_encounter_composition,
			_ecology_layer_state,
			_run_stage,
			get_run_loop_state(),
			get_run_loop_index(),
			get_run_loop_progress(),
			_world_chunk_pool_name,
			_world_encounter_profile_name,
			_boss_encounter_state,
			_current_boss_role(),
			_current_player_build_identity(),
			_stage_finale_label,
			_current_stage_finale_progress(),
			_tempo_relief_timer,
			_stage_transition_label,
			_stage_transition_timer,
			_landmark_event_type,
			_landmark_event_timer
		]

	if _debug_timer > 0.0:
		return

	_debug_timer = DEBUG_PRINT_INTERVAL
	print(
		"Director pressure=%.2f enemies=%d/%d interval=%.2f state=%s comp=%s eco=%s loop=%s #%d pool=%s profile=%s boss=%s %s finale=%s %.2f" % [
			_pressure,
			_active_enemy_count(),
			_current_max_enemies(),
			_current_spawn_interval(),
			_pacing_state,
			_encounter_composition,
			_ecology_layer_state,
			get_run_loop_state(),
			get_run_loop_index(),
			_world_chunk_pool_name,
			_world_encounter_profile_name,
			_boss_encounter_state,
			_current_boss_role(),
			_stage_finale_label,
			_current_stage_finale_progress()
		]
	)
