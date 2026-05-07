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
const MELEE_ENEMY_WEIGHT: float = 0.60
const RANGED_ENEMY_WEIGHT: float = 0.25
const SWARM_ENEMY_WEIGHT: float = 0.15
const ELITE_BERSERKER: StringName = &"berserker"
const ELITE_TITAN: StringName = &"titan"
const ELITE_VOLTAIC: StringName = &"voltaic"
const ELITE_BASE_CHANCE: float = 0.015
const ELITE_TIME_WEIGHT: float = 0.00016
const ELITE_PRESSURE_WEIGHT: float = 0.010
const ELITE_LEVEL_WEIGHT: float = 0.008
const ELITE_MAX_CHANCE: float = 0.14
const RECOVERY_PENALTY_CAP: float = 2.5
const COMBAT_INTENSITY_CAP: float = 4.0
const RECOVERY_STATE_THRESHOLD: float = 1.3
const LOW_PRESSURE_STATE_THRESHOLD: float = 2.8
const HIGH_PRESSURE_STATE_THRESHOLD: float = 4.6
const HIGH_PRESSURE_BURST_THRESHOLD: float = 4.0
const HIGH_PRESSURE_BURST_CHANCE: float = 0.35

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
var _pacing_state: String = "recovery"
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
	if _spawn_zones_root != null:
		_melee_spawn_zone_root = _spawn_zones_root.get_node_or_null("Melee") as Node2D
		_mixed_spawn_zone_root = _spawn_zones_root.get_node_or_null("Mixed") as Node2D
		_ranged_spawn_zone_root = _spawn_zones_root.get_node_or_null("Ranged") as Node2D
	_spawn_shape.size = SPAWN_COLLISION_SIZE
	_spawn_timer = base_spawn_interval
	_debug_timer = DEBUG_PRINT_INTERVAL
	_setup_debug_ui()

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
		return

	_player = get_tree().get_first_node_in_group("player") as Node2D
	if _player != null and _player.has_method("get_current_level"):
		_player_level = int(_player.call("get_current_level"))

func _update_director(delta: float) -> void:
	_elapsed_time += delta
	var active_enemy_count: int = _active_enemy_count()
	var enemy_deaths: int = max(_last_active_enemy_count - active_enemy_count, 0)
	_update_combat_pressure(delta, active_enemy_count, enemy_deaths)
	_update_recovery_pressure(delta, active_enemy_count, enemy_deaths)
	_player_level = _current_player_level()
	_pressure = _compute_pressure(active_enemy_count)
	_pacing_state = _current_pacing_state(active_enemy_count)
	_spawn_timer -= delta
	_burst_timer = max(_burst_timer - delta, 0.0)
	_last_active_enemy_count = active_enemy_count

func _update_combat_pressure(delta: float, active_enemy_count: int, enemy_deaths: int) -> void:
	_recent_combat_intensity = max(_recent_combat_intensity - delta * combat_intensity_decay_rate, 0.0)
	if active_enemy_count >= 3:
		_recent_combat_intensity = min(_recent_combat_intensity + delta * combat_intensity_gain_rate, COMBAT_INTENSITY_CAP)

	if active_enemy_count >= 5:
		_recent_combat_intensity = min(_recent_combat_intensity + delta * 0.12, COMBAT_INTENSITY_CAP)

	if enemy_deaths > 0:
		_recent_combat_intensity = max(_recent_combat_intensity - float(enemy_deaths) * 0.12, 0.0)

func _update_recovery_pressure(delta: float, active_enemy_count: int, enemy_deaths: int) -> void:
	if active_enemy_count <= 1:
		_recovery_pressure_buffer = min(_recovery_pressure_buffer + delta * recovery_gain_rate, RECOVERY_PENALTY_CAP)
	else:
		_recovery_pressure_buffer = max(_recovery_pressure_buffer - delta * recovery_decay_rate, 0.0)

	if enemy_deaths > 0:
		_recovery_pressure_buffer = min(_recovery_pressure_buffer + float(enemy_deaths) * 0.16, RECOVERY_PENALTY_CAP)

func _compute_pressure(active_enemy_count: int) -> float:
	var elapsed_pressure: float = _elapsed_time * pressure_time_rate
	var enemy_pressure: float = float(active_enemy_count) * pressure_enemy_weight
	var level_pressure: float = float(max(_player_level - 1, 0)) * pressure_level_weight
	var intensity_pressure: float = _recent_combat_intensity
	var recovery_relief: float = _recovery_pressure_buffer

	var total_pressure: float = elapsed_pressure + enemy_pressure + level_pressure + intensity_pressure - recovery_relief
	return max(total_pressure, 0.0)

func _current_player_level() -> int:
	if _player != null and _player.has_method("get_current_level"):
		return int(_player.call("get_current_level"))

	return 1

func _active_enemy_count() -> int:
	return get_tree().get_nodes_in_group("enemy").size()

func _current_spawn_interval() -> float:
	var pressure_factor: float = 1.0 + _pressure * 0.20
	var pacing_factor: float = _spawn_pacing_factor()
	var interval: float = base_spawn_interval / pressure_factor
	interval *= pacing_factor
	return max(minimum_spawn_interval, interval)

func _current_max_enemies() -> int:
	var time_bonus: int = int(floor(_elapsed_time / 45.0))
	var level_bonus: int = int(floor(float(max(_player_level - 1, 0)) * 0.5))
	var pressure_bonus: int = int(floor(_pressure * 0.75))
	return clampi(base_max_enemies + time_bonus + level_bonus + pressure_bonus, base_max_enemies, max_enemy_cap)

func _current_pacing_state(active_enemy_count: int) -> String:
	if active_enemy_count <= 1 and _pressure < RECOVERY_STATE_THRESHOLD:
		return "recovery"

	if _pressure < LOW_PRESSURE_STATE_THRESHOLD:
		return "low"

	if _pressure < HIGH_PRESSURE_STATE_THRESHOLD:
		return "pressure"

	return "high"

func _spawn_pacing_factor() -> float:
	match _pacing_state:
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

# ============================================================================
# SPAWNING
# ============================================================================

func _try_spawn_enemy() -> void:
	if _player == null:
		return

	if _spawn_timer > 0.0:
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

		enemy_instance.position = _gameplay_root.to_local(spawn_marker.global_position)
		_gameplay_root.add_child(enemy_instance)
		spawned_any_enemy = true

	if spawned_any_enemy:
		_spawn_timer = _current_spawn_interval()
	else:
		_spawn_timer = max(_current_spawn_interval(), base_spawn_interval * 0.75)

func _select_followup_enemy_scene(primary_scene: PackedScene) -> PackedScene:
	if primary_scene == _swarm_enemy_scene:
		return _swarm_enemy_scene

	if _ranged_enemy_scene == null:
		return primary_scene

	if primary_scene == _enemy_scene and _swarm_enemy_scene != null and randf() < 0.35:
		return _swarm_enemy_scene

	if primary_scene == _ranged_enemy_scene and _swarm_enemy_scene != null and randf() < 0.45:
		return _swarm_enemy_scene

	if primary_scene == _enemy_scene:
		return _ranged_enemy_scene

	return _enemy_scene

func _select_enemy_scene() -> PackedScene:
	if _ranged_enemy_scene == null and _swarm_enemy_scene == null:
		return _enemy_scene

	var roll: float = randf()
	if roll < MELEE_ENEMY_WEIGHT:
		return _enemy_scene

	if _ranged_enemy_scene != null and roll < MELEE_ENEMY_WEIGHT + RANGED_ENEMY_WEIGHT:
		return _ranged_enemy_scene

	if _swarm_enemy_scene != null and roll < MELEE_ENEMY_WEIGHT + RANGED_ENEMY_WEIGHT + SWARM_ENEMY_WEIGHT:
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
	return clamp(ELITE_BASE_CHANCE + time_bonus + pressure_bonus + level_bonus, 0.0, ELITE_MAX_CHANCE)

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
	if enemy_scene == _swarm_enemy_scene:
		if _pacing_state == "high" and _pressure >= HIGH_PRESSURE_BURST_THRESHOLD and _burst_timer <= 0.0:
			if randf() < 0.45:
				_burst_timer = burst_cooldown_seconds * 0.75
				return 2

		if randf() < 0.35:
			return 2

		return 1

	if _pacing_state == "high" and _pressure >= HIGH_PRESSURE_BURST_THRESHOLD and _burst_timer <= 0.0:
		if randf() < HIGH_PRESSURE_BURST_CHANCE:
			_burst_timer = burst_cooldown_seconds
			return 2

	if _pacing_state == "pressure" and randf() < 0.20:
		return 2

	return 1

func _pick_spawn_marker(enemy_scene: PackedScene) -> Marker2D:
	var preferred_roots: Array[Node2D] = _preferred_spawn_roots(enemy_scene)

	for spawn_root: Node2D in preferred_roots:
		var zone_marker: Marker2D = _pick_spawn_marker_from_root(spawn_root)
		if zone_marker != null:
			return zone_marker

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
		_debug_label.text = "PRES: %.2f\nENEMIES: %d/%d\nELITES: %d/%d\nCD: %.2f\nSTATE: %s" % [
			_pressure,
			_active_enemy_count(),
			_current_max_enemies(),
			_active_elite_count(),
			_current_elite_cap(),
			max(_spawn_timer, 0.0),
			_pacing_state
		]

	if _debug_timer > 0.0:
		return

	_debug_timer = DEBUG_PRINT_INTERVAL
	print(
		"Director pressure=%.2f enemies=%d/%d interval=%.2f state=%s" % [
			_pressure,
			_active_enemy_count(),
			_current_max_enemies(),
			_current_spawn_interval(),
			_pacing_state
		]
	)
