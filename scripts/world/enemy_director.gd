extends Node

# ============================================================================
# CONSTANTS
# ============================================================================

const DEBUG_PRINT_INTERVAL: float = 5.0
const SPAWN_COLLISION_SIZE: Vector2 = Vector2(20.0, 32.0)
const VIEW_MARGIN: Vector2 = Vector2(96.0, 64.0)
const SPAWN_BODY_OFFSET: Vector2 = Vector2(0.0, -16.0)

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

# ============================================================================
# RUNTIME VARIABLES
# ============================================================================

var _elapsed_time: float = 0.0
var _spawn_timer: float = 0.0
var _debug_timer: float = 0.0
var _pressure: float = 0.0
var _gameplay_root: Node2D = null
var _enemy_spawn_root: Node2D = null
var _enemy_scene: PackedScene = null
var _player: Node2D = null
var _spawn_shape: RectangleShape2D = RectangleShape2D.new()

# ============================================================================
# GODOT LIFECYCLE
# ============================================================================

func setup(gameplay_root: Node2D, enemy_spawn_root: Node2D, enemy_scene: PackedScene) -> void:
	_gameplay_root = gameplay_root
	_enemy_spawn_root = enemy_spawn_root
	_enemy_scene = enemy_scene
	_spawn_shape.size = SPAWN_COLLISION_SIZE
	_spawn_timer = base_spawn_interval
	_debug_timer = DEBUG_PRINT_INTERVAL

func _physics_process(delta: float) -> void:
	if _gameplay_root == null or _enemy_spawn_root == null or _enemy_scene == null:
		return

	_update_player_reference()
	_update_director(delta)
	_try_spawn_enemy()
	_update_debug(delta)

# ============================================================================
# DIRECTOR UPDATE
# ============================================================================

func _update_player_reference() -> void:
	if is_instance_valid(_player):
		return

	_player = get_tree().get_first_node_in_group("player") as Node2D

func _update_director(delta: float) -> void:
	_elapsed_time += delta
	_pressure = _elapsed_time * pressure_time_rate + float(_active_enemy_count()) * pressure_enemy_weight
	_spawn_timer -= delta

func _active_enemy_count() -> int:
	return get_tree().get_nodes_in_group("enemy").size()

func _current_spawn_interval() -> float:
	var pressure_factor: float = 1.0 + _pressure * 0.25
	return max(minimum_spawn_interval, base_spawn_interval / pressure_factor)

func _current_max_enemies() -> int:
	var time_bonus: int = int(floor(_elapsed_time / 45.0))
	var pressure_bonus: int = int(floor(_pressure))
	return clampi(base_max_enemies + time_bonus + pressure_bonus, base_max_enemies, max_enemy_cap)

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

	var spawn_marker: Marker2D = _pick_spawn_marker()
	_spawn_timer = _current_spawn_interval()
	if spawn_marker == null:
		return

	var enemy_instance: Node2D = _enemy_scene.instantiate() as Node2D
	if enemy_instance == null:
		return

	enemy_instance.position = _gameplay_root.to_local(spawn_marker.global_position)
	_gameplay_root.add_child(enemy_instance)

func _pick_spawn_marker() -> Marker2D:
	var candidates: Array[Marker2D] = []

	for child: Node in _enemy_spawn_root.get_children():
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

	var collisions: Array[Dictionary] = get_world_2d().direct_space_state.intersect_shape(query)
	return not collisions.is_empty()

# ============================================================================
# DEBUG
# ============================================================================

func _update_debug(delta: float) -> void:
	_debug_timer -= delta
	if _debug_timer > 0.0:
		return

	_debug_timer = DEBUG_PRINT_INTERVAL
	print(
		"Director pressure=%.2f enemies=%d/%d interval=%.2f" % [
			_pressure,
			_active_enemy_count(),
			_current_max_enemies(),
			_current_spawn_interval()
		]
	)
