extends Node2D

# ============================================================================
# CONSTANTS
# ============================================================================

const TILE_SIZE: int = 32
const WORLD_WIDTH_TILES: int = 96
const WORLD_HEIGHT_TILES: int = 30
const PLAYER_SCENE_PATH: String = "res://scenes/player/Player.tscn"
const BASIC_ENEMY_SCENE_PATH: String = "res://scenes/enemies/basic_enemy.tscn"
const ENEMY_DIRECTOR_SCRIPT_PATH: String = "res://scripts/world/enemy_director.gd"

const CENTRAL_ZONE_RECTS: Array[Rect2i] = [
	Rect2i(38, 18, 20, 2),
	Rect2i(44, 16, 8, 2),
	Rect2i(47, 14, 2, 1)
]

const LEFT_ROUTE_RECTS: Array[Rect2i] = [
	Rect2i(24, 19, 12, 2),
	Rect2i(8, 20, 12, 2),
	Rect2i(0, 23, 8, 3),
	Rect2i(12, 17, 5, 1),
	Rect2i(18, 15, 4, 1),
	Rect2i(22, 13, 4, 1),
	Rect2i(27, 11, 4, 1),
	Rect2i(4, 9, 5, 1),
	Rect2i(0, 6, 4, 1)
]

const RIGHT_ROUTE_RECTS: Array[Rect2i] = [
	Rect2i(60, 19, 12, 2),
	Rect2i(76, 20, 12, 2),
	Rect2i(88, 23, 8, 3),
	Rect2i(79, 17, 5, 1),
	Rect2i(74, 15, 4, 1),
	Rect2i(70, 13, 4, 1),
	Rect2i(65, 11, 4, 1),
	Rect2i(84, 8, 6, 1),
	Rect2i(92, 6, 4, 1)
]

const UPPER_ROUTE_RECTS: Array[Rect2i] = [
	Rect2i(32, 13, 7, 1),
	Rect2i(42, 11, 7, 1),
	Rect2i(50, 8, 5, 1),
	Rect2i(57, 11, 7, 1),
	Rect2i(66, 13, 7, 1),
	Rect2i(45, 7, 3, 1)
]

const LOWER_ROUTE_RECTS: Array[Rect2i] = [
	Rect2i(18, 24, 18, 2),
	Rect2i(36, 25, 8, 2),
	Rect2i(52, 24, 18, 2),
	Rect2i(30, 22, 4, 1),
	Rect2i(60, 22, 4, 1)
]

const BRIDGE_RECTS: Array[Rect2i] = [
	Rect2i(36, 17, 4, 1),
	Rect2i(56, 17, 4, 1),
	Rect2i(46, 5, 5, 1),
	Rect2i(43, 12, 10, 1)
]

const CLIMB_RECTS: Array[Rect2i] = [
	Rect2i(34, 20, 2, 4),
	Rect2i(60, 20, 2, 4),
	Rect2i(46, 14, 2, 4)
]

const LANDMARK_RECTS: Array[Rect2i] = [
	Rect2i(14, 16, 2, 4),
	Rect2i(48, 12, 2, 6),
	Rect2i(80, 16, 2, 4),
	Rect2i(66, 10, 2, 6)
]

const MELEE_SPAWN_POINTS: Array[Vector2i] = [
	Vector2i(10, 20),
	Vector2i(28, 19),
	Vector2i(32, 23),
	Vector2i(66, 20),
	Vector2i(82, 19),
	Vector2i(90, 23)
]

const MIXED_SPAWN_POINTS: Array[Vector2i] = [
	Vector2i(22, 15),
	Vector2i(46, 16),
	Vector2i(52, 16),
	Vector2i(74, 16)
]

const RANGED_SPAWN_POINTS: Array[Vector2i] = [
	Vector2i(34, 11),
	Vector2i(50, 8),
	Vector2i(68, 11)
]

const ARENA_MARKER_POINTS: Array[Vector2i] = [
	Vector2i(23, 19),
	Vector2i(48, 16),
	Vector2i(73, 19)
]

const SAFE_ROUTE_POINTS: Array[Vector2i] = [
	Vector2i(10, 20),
	Vector2i(18, 15),
	Vector2i(28, 11),
	Vector2i(38, 11),
	Vector2i(45, 7),
	Vector2i(57, 11),
	Vector2i(66, 13),
	Vector2i(74, 16)
]

const RISK_ROUTE_POINTS: Array[Vector2i] = [
	Vector2i(10, 20),
	Vector2i(24, 19),
	Vector2i(38, 18),
	Vector2i(48, 16),
	Vector2i(60, 17),
	Vector2i(76, 20),
	Vector2i(90, 23)
]

const RECOVERY_ROUTE_POINTS: Array[Vector2i] = [
	Vector2i(2, 23),
	Vector2i(18, 24),
	Vector2i(36, 25),
	Vector2i(52, 24),
	Vector2i(70, 22),
	Vector2i(88, 23)
]

const DIRECTOR_SPAWN_POINTS: Array[Vector2i] = [
	Vector2i(12, 18),
	Vector2i(30, 17),
	Vector2i(48, 15),
	Vector2i(66, 17),
	Vector2i(84, 18),
	Vector2i(52, 22)
]

const REWARD_HOOK_POINTS: Array[Vector2i] = [
	Vector2i(2, 5),
	Vector2i(94, 5),
	Vector2i(47, 4)
]

const SKY_COLOR_TOP: Color = Color(0.09, 0.10, 0.18, 1.0)
const SKY_COLOR_BOTTOM: Color = Color(0.28, 0.27, 0.34, 1.0)
const FAR_RUINS_COLOR: Color = Color(0.12, 0.12, 0.18, 0.95)
const MID_RUINS_COLOR: Color = Color(0.18, 0.18, 0.26, 0.96)
const FOREGROUND_RUIN_COLOR: Color = Color(0.26, 0.27, 0.34, 0.82)
const FOG_COLOR: Color = Color(0.45, 0.51, 0.62, 0.22)
const GROUND_COLOR: Color = Color(0.62, 0.64, 0.69, 1.0)
const ROUTE_SAFE_COLOR: Color = Color(0.72, 0.92, 1.0, 0.22)
const ROUTE_RISK_COLOR: Color = Color(1.0, 0.80, 0.50, 0.20)
const ROUTE_RECOVERY_COLOR: Color = Color(0.72, 1.0, 0.76, 0.20)
const PRESSURE_COMPRESSION_COLOR: Color = Color(1.0, 0.42, 0.24, 0.0)
const PRESSURE_RISK_COLOR: Color = Color(1.0, 0.74, 0.28, 0.0)
const PRESSURE_RECOVERY_COLOR: Color = Color(0.62, 0.96, 0.72, 0.0)

# ============================================================================
# LEVEL BUILDING
# ============================================================================

@onready var canvas_modulate: CanvasModulate = $CanvasModulate
@onready var sky_layer: ParallaxLayer = $ParallaxBackground/SkyLayer
@onready var far_layer: ParallaxLayer = $ParallaxBackground/FarLayer
@onready var mid_layer: ParallaxLayer = $ParallaxBackground/MidLayer
@onready var fog_layer: ParallaxLayer = $ParallaxBackground/FogLayer
@onready var foreground_layer: ParallaxLayer = $ParallaxBackground/ForegroundLayer
@onready var ground_tile_map: TileMap = $Gameplay/GroundTileMap
@onready var collision_root: Node2D = $Gameplay/Collision
@onready var player_spawn: Marker2D = $Gameplay/PlayerSpawn
@onready var enemy_spawns_root: Node2D = $Gameplay/EnemySpawns
@onready var director_spawns_root: Node2D = $Gameplay/FutureHooks/DirectorSpawns
@onready var reward_hooks_root: Node2D = $Gameplay/FutureHooks/RewardHooks
@onready var combat_arenas_root: Node2D = $Gameplay/FutureHooks/CombatArenas
@onready var traversal_routes_root: Node2D = $Gameplay/FutureHooks/TraversalRoutes
@onready var arena_pressure_root: Node2D = $Gameplay/FutureHooks/ArenaPressure
@onready var melee_spawn_root: Node2D = $Gameplay/FutureHooks/SpawnZones/Melee
@onready var mixed_spawn_root: Node2D = $Gameplay/FutureHooks/SpawnZones/Mixed
@onready var ranged_spawn_root: Node2D = $Gameplay/FutureHooks/SpawnZones/Ranged
@onready var left_limit: Marker2D = $CameraBounds/LeftLimit
@onready var top_limit: Marker2D = $CameraBounds/TopLimit
@onready var right_limit: Marker2D = $CameraBounds/RightLimit
@onready var bottom_limit: Marker2D = $CameraBounds/BottomLimit

var _enemy_director: Node = null
var _current_biome_stage: String = "early"
var _biome_canvas_color: Color = Color(0.82, 0.85, 0.90, 1.0)
var _biome_sky_top_color: Color = SKY_COLOR_TOP
var _biome_sky_bottom_color: Color = SKY_COLOR_BOTTOM
var _biome_far_color: Color = FAR_RUINS_COLOR
var _biome_mid_color: Color = MID_RUINS_COLOR
var _biome_foreground_color: Color = FOREGROUND_RUIN_COLOR
var _biome_fog_color: Color = FOG_COLOR
var _biome_ground_color: Color = GROUND_COLOR
var _biome_route_safe_color: Color = ROUTE_SAFE_COLOR
var _biome_route_risk_color: Color = ROUTE_RISK_COLOR
var _biome_route_recovery_color: Color = ROUTE_RECOVERY_COLOR
var _arena_compression_zone: Polygon2D = null
var _arena_risk_zone: Polygon2D = null
var _arena_recovery_zone: Polygon2D = null
var _biome_sky_motion_scale: Vector2 = Vector2(0.05, 0.05)
var _biome_far_motion_scale: Vector2 = Vector2(0.15, 0.12)
var _biome_mid_motion_scale: Vector2 = Vector2(0.30, 0.20)
var _biome_fog_motion_scale: Vector2 = Vector2(0.45, 0.20)
var _biome_foreground_motion_scale: Vector2 = Vector2(0.65, 0.30)

func _ready() -> void:
	_setup_tile_map()
	_clear_tile_map()
	_update_world_bounds()
	_position_player_spawn()
	_create_spawn_hooks()
	_create_reward_hooks()
	_create_combat_arenas()
	_create_spawn_zones()
	_build_level_geometry()
	_setup_player()
	_setup_enemy_director()
	_apply_biome_theme(_current_biome_stage)

func _process(_delta: float) -> void:
	_sync_biome_theme()
	_sync_arena_pressure()

func _setup_tile_map() -> void:
	ground_tile_map.tile_set = _create_ground_tile_set()

func _clear_tile_map() -> void:
	ground_tile_map.clear()

func _update_world_bounds() -> void:
	right_limit.position.x = WORLD_WIDTH_TILES * TILE_SIZE
	bottom_limit.position.y = WORLD_HEIGHT_TILES * TILE_SIZE

func _position_player_spawn() -> void:
	player_spawn.position = Vector2(44 * TILE_SIZE + TILE_SIZE * 0.5, 17 * TILE_SIZE)

func _create_spawn_hooks() -> void:
	_clear_children(director_spawns_root)
	for index: int in range(DIRECTOR_SPAWN_POINTS.size()):
		var marker: Marker2D = Marker2D.new()
		marker.name = "SpawnHook_%02d" % index
		marker.position = _tile_to_world_center(DIRECTOR_SPAWN_POINTS[index])
		director_spawns_root.add_child(marker)

func _create_reward_hooks() -> void:
	_clear_children(reward_hooks_root)
	for index: int in range(REWARD_HOOK_POINTS.size()):
		var marker: Marker2D = Marker2D.new()
		marker.name = "RewardHook_%02d" % index
		marker.position = _tile_to_world_center(REWARD_HOOK_POINTS[index])
		reward_hooks_root.add_child(marker)

func _create_combat_arenas() -> void:
	_clear_children(combat_arenas_root)
	for index: int in range(ARENA_MARKER_POINTS.size()):
		var marker: Marker2D = Marker2D.new()
		marker.name = "Arena_%02d" % index
		marker.position = _tile_to_world_center(ARENA_MARKER_POINTS[index])
		combat_arenas_root.add_child(marker)

func _create_spawn_zones() -> void:
	_clear_children(melee_spawn_root)
	_clear_children(mixed_spawn_root)
	_clear_children(ranged_spawn_root)
	_create_zone_markers(melee_spawn_root, MELEE_SPAWN_POINTS, "MeleeZone")
	_create_zone_markers(mixed_spawn_root, MIXED_SPAWN_POINTS, "MixedZone")
	_create_zone_markers(ranged_spawn_root, RANGED_SPAWN_POINTS, "RangedZone")

func _create_zone_markers(parent: Node2D, points: Array[Vector2i], prefix: String) -> void:
	for index: int in range(points.size()):
		var marker: Marker2D = Marker2D.new()
		marker.name = "%s_%02d" % [prefix, index]
		marker.position = _tile_to_world_center(points[index])
		parent.add_child(marker)

func _clear_children(parent: Node) -> void:
	for child: Node in parent.get_children():
		child.queue_free()

func _build_level_geometry() -> void:
	_clear_children(collision_root)
	_paint_level_rects(_all_level_rects())
	_create_level_colliders(_all_level_rects())

func _create_traversal_routes() -> void:
	_clear_children(traversal_routes_root)
	_add_route_line("SafeRoute", SAFE_ROUTE_POINTS, _biome_route_safe_color, 8.0)
	_add_route_line("RiskRoute", RISK_ROUTE_POINTS, _biome_route_risk_color, 7.0)
	_add_route_line("RecoveryRoute", RECOVERY_ROUTE_POINTS, _biome_route_recovery_color, 6.0)

func _add_route_line(name: String, points: Array[Vector2i], color: Color, width: float) -> void:
	var route_line: Line2D = Line2D.new()
	route_line.name = name
	route_line.width = width
	route_line.default_color = color
	route_line.antialiased = true
	route_line.points = _tile_points_to_world(points)
	traversal_routes_root.add_child(route_line)

func _tile_points_to_world(points: Array[Vector2i]) -> PackedVector2Array:
	var world_points: PackedVector2Array = PackedVector2Array()
	for tile_point: Vector2i in points:
		world_points.append(_tile_to_world_center(tile_point))

	return world_points

func _create_arena_pressure_layers() -> void:
	_clear_children(arena_pressure_root)
	_arena_compression_zone = _add_pressure_polygon(
		"CompressionZone",
		[
			Vector2(736, 384), Vector2(2336, 384), Vector2(2336, 704), Vector2(736, 704)
		],
		PRESSURE_COMPRESSION_COLOR
	)
	_arena_risk_zone = _add_pressure_polygon(
		"RiskZone",
		[
			Vector2(0, 288), Vector2(3072, 288), Vector2(3072, 576), Vector2(0, 576)
		],
		PRESSURE_RISK_COLOR
	)
	_arena_recovery_zone = _add_pressure_polygon(
		"RecoveryZone",
		[
			Vector2(0, 640), Vector2(3072, 640), Vector2(3072, 864), Vector2(0, 864)
		],
		PRESSURE_RECOVERY_COLOR
	)

func _add_pressure_polygon(name: String, points: Array[Vector2], color: Color) -> Polygon2D:
	var pressure_polygon: Polygon2D = Polygon2D.new()
	pressure_polygon.name = name
	pressure_polygon.color = color
	pressure_polygon.polygon = PackedVector2Array(points)
	arena_pressure_root.add_child(pressure_polygon)
	return pressure_polygon

# ============================================================================
# BIOME IDENTITY
# ============================================================================

func _sync_biome_theme() -> void:
	if _enemy_director == null or not is_instance_valid(_enemy_director):
		return

	if not _enemy_director.has_method("get_run_stage"):
		return

	var stage: String = String(_enemy_director.call("get_run_stage"))
	if stage == _current_biome_stage:
		return

	_apply_biome_theme(stage)

func _sync_arena_pressure() -> void:
	if _enemy_director == null or not is_instance_valid(_enemy_director):
		return

	if not _enemy_director.has_method("get_pacing_state"):
		return

	var pacing_state: String = String(_enemy_director.call("get_pacing_state"))
	var encounter_state: String = "recovery"
	var pressure_value: float = 0.0
	var landmark_event: String = "none"

	if _enemy_director.has_method("get_encounter_composition"):
		encounter_state = String(_enemy_director.call("get_encounter_composition"))

	if _enemy_director.has_method("get_pressure"):
		pressure_value = float(_enemy_director.call("get_pressure"))

	if _enemy_director.has_method("get_landmark_event_type"):
		landmark_event = String(_enemy_director.call("get_landmark_event_type"))

	var stage_pressure_scale: float = _stage_pressure_scale(_current_biome_stage)
	var pressure_scale: float = clamp(pressure_value * 0.16 * stage_pressure_scale, 0.0, 0.60)
	var compression_alpha: float = 0.05 + pressure_scale
	var risk_alpha: float = 0.04 + pressure_scale * 0.80
	var recovery_alpha: float = 0.05 + max(0.20 - pressure_scale * 0.35, 0.0)

	match pacing_state:
		"transition":
			compression_alpha += 0.08
			risk_alpha += 0.04
			recovery_alpha += 0.04
		"pressure":
			compression_alpha += 0.06
			risk_alpha += 0.06
		"high":
			compression_alpha += 0.12
			risk_alpha += 0.10
		"spike":
			compression_alpha += 0.18
			risk_alpha += 0.14
			recovery_alpha = max(recovery_alpha - 0.06, 0.0)
		_:
			compression_alpha *= 0.8

	match encounter_state:
		"build":
			recovery_alpha += 0.02
		"pressure":
			compression_alpha += 0.03
		"spike":
			compression_alpha += 0.08
			risk_alpha += 0.05
		_:
			recovery_alpha += 0.01

	match landmark_event:
		"swarm_surge":
			risk_alpha += 0.08
		"elite_push":
			compression_alpha += 0.10
		"melee_rush":
			risk_alpha += 0.05
			compression_alpha += 0.03
		_:
			pass

	_update_pressure_polygon(_arena_compression_zone, Color(1.0, 0.42, 0.24, clamp(compression_alpha, 0.0, 0.32)))
	_update_pressure_polygon(_arena_risk_zone, Color(1.0, 0.74, 0.28, clamp(risk_alpha, 0.0, 0.30)))
	_update_pressure_polygon(_arena_recovery_zone, Color(0.62, 0.96, 0.72, clamp(recovery_alpha, 0.0, 0.26)))

func _update_pressure_polygon(polygon: Polygon2D, color: Color) -> void:
	if polygon == null:
		return

	polygon.color = color

func _stage_pressure_scale(stage: String) -> float:
	match stage:
		"early":
			return 0.90
		"mid":
			return 1.00
		"late":
			return 1.12
		"endless":
			return 1.20
		_:
			return 1.0

func _apply_biome_theme(stage: String) -> void:
	_current_biome_stage = stage

	match stage:
		"mid":
			_biome_canvas_color = Color(0.76, 0.80, 0.88, 1.0)
			_biome_sky_top_color = Color(0.08, 0.10, 0.17, 1.0)
			_biome_sky_bottom_color = Color(0.23, 0.25, 0.32, 1.0)
			_biome_far_color = Color(0.10, 0.11, 0.16, 0.92)
			_biome_mid_color = Color(0.15, 0.16, 0.23, 0.95)
			_biome_foreground_color = Color(0.22, 0.24, 0.30, 0.84)
			_biome_fog_color = Color(0.42, 0.48, 0.58, 0.24)
			_biome_ground_color = Color(0.58, 0.60, 0.66, 1.0)
			_biome_sky_motion_scale = Vector2(0.045, 0.045)
			_biome_far_motion_scale = Vector2(0.14, 0.11)
			_biome_mid_motion_scale = Vector2(0.28, 0.19)
			_biome_fog_motion_scale = Vector2(0.42, 0.18)
			_biome_foreground_motion_scale = Vector2(0.60, 0.28)
			_biome_route_safe_color = Color(0.62, 0.88, 1.0, 0.20)
			_biome_route_risk_color = Color(1.0, 0.76, 0.42, 0.18)
			_biome_route_recovery_color = Color(0.68, 1.0, 0.72, 0.18)
		"late":
			_biome_canvas_color = Color(0.68, 0.72, 0.80, 1.0)
			_biome_sky_top_color = Color(0.06, 0.07, 0.12, 1.0)
			_biome_sky_bottom_color = Color(0.18, 0.17, 0.24, 1.0)
			_biome_far_color = Color(0.08, 0.08, 0.13, 0.94)
			_biome_mid_color = Color(0.12, 0.12, 0.19, 0.96)
			_biome_foreground_color = Color(0.18, 0.18, 0.25, 0.88)
			_biome_fog_color = Color(0.34, 0.38, 0.46, 0.28)
			_biome_ground_color = Color(0.52, 0.54, 0.60, 1.0)
			_biome_sky_motion_scale = Vector2(0.040, 0.040)
			_biome_far_motion_scale = Vector2(0.12, 0.10)
			_biome_mid_motion_scale = Vector2(0.24, 0.16)
			_biome_fog_motion_scale = Vector2(0.38, 0.16)
			_biome_foreground_motion_scale = Vector2(0.56, 0.26)
			_biome_route_safe_color = Color(0.56, 0.82, 0.96, 0.18)
			_biome_route_risk_color = Color(0.96, 0.68, 0.38, 0.16)
			_biome_route_recovery_color = Color(0.62, 0.92, 0.68, 0.16)
		"endless":
			_biome_canvas_color = Color(0.62, 0.65, 0.74, 1.0)
			_biome_sky_top_color = Color(0.05, 0.05, 0.09, 1.0)
			_biome_sky_bottom_color = Color(0.14, 0.12, 0.19, 1.0)
			_biome_far_color = Color(0.06, 0.06, 0.10, 0.95)
			_biome_mid_color = Color(0.10, 0.10, 0.16, 0.96)
			_biome_foreground_color = Color(0.14, 0.14, 0.20, 0.92)
			_biome_fog_color = Color(0.26, 0.30, 0.38, 0.32)
			_biome_ground_color = Color(0.46, 0.48, 0.54, 1.0)
			_biome_sky_motion_scale = Vector2(0.035, 0.035)
			_biome_far_motion_scale = Vector2(0.10, 0.08)
			_biome_mid_motion_scale = Vector2(0.22, 0.15)
			_biome_fog_motion_scale = Vector2(0.34, 0.14)
			_biome_foreground_motion_scale = Vector2(0.52, 0.24)
			_biome_route_safe_color = Color(0.50, 0.78, 0.92, 0.16)
			_biome_route_risk_color = Color(0.92, 0.62, 0.34, 0.14)
			_biome_route_recovery_color = Color(0.56, 0.84, 0.62, 0.14)
		_:
			_biome_canvas_color = Color(0.82, 0.85, 0.90, 1.0)
			_biome_sky_top_color = SKY_COLOR_TOP
			_biome_sky_bottom_color = SKY_COLOR_BOTTOM
			_biome_far_color = FAR_RUINS_COLOR
			_biome_mid_color = MID_RUINS_COLOR
			_biome_foreground_color = FOREGROUND_RUIN_COLOR
			_biome_fog_color = FOG_COLOR
			_biome_ground_color = GROUND_COLOR
			_biome_sky_motion_scale = Vector2(0.05, 0.05)
			_biome_far_motion_scale = Vector2(0.15, 0.12)
			_biome_mid_motion_scale = Vector2(0.30, 0.20)
			_biome_fog_motion_scale = Vector2(0.45, 0.20)
			_biome_foreground_motion_scale = Vector2(0.65, 0.30)
			_biome_route_safe_color = ROUTE_SAFE_COLOR
			_biome_route_risk_color = ROUTE_RISK_COLOR
			_biome_route_recovery_color = ROUTE_RECOVERY_COLOR

	canvas_modulate.color = _biome_canvas_color
	_setup_tile_map()
	_setup_background()
	_create_traversal_routes()
	_create_arena_pressure_layers()
	_sync_arena_pressure()

func _all_level_rects() -> Array[Rect2i]:
	var level_rects: Array[Rect2i] = []
	level_rects.append_array(CENTRAL_ZONE_RECTS)
	level_rects.append_array(LEFT_ROUTE_RECTS)
	level_rects.append_array(RIGHT_ROUTE_RECTS)
	level_rects.append_array(UPPER_ROUTE_RECTS)
	level_rects.append_array(LOWER_ROUTE_RECTS)
	level_rects.append_array(BRIDGE_RECTS)
	level_rects.append_array(CLIMB_RECTS)
	level_rects.append_array(LANDMARK_RECTS)
	return level_rects

# ============================================================================
# PLATFORM CREATION
# ============================================================================

func _paint_level_rects(level_rects: Array[Rect2i]) -> void:
	for rect: Rect2i in level_rects:
		_paint_rect(rect)

func _paint_rect(rect: Rect2i) -> void:
	for x: int in range(rect.position.x, rect.end.x):
		for y: int in range(rect.position.y, rect.end.y):
			ground_tile_map.set_cell(0, Vector2i(x, y), 0, Vector2i.ZERO, 0)

func _create_level_colliders(level_rects: Array[Rect2i]) -> void:
	for rect: Rect2i in level_rects:
		_create_collision_body(rect)

func _create_collision_body(rect: Rect2i) -> void:
	var body: StaticBody2D = StaticBody2D.new()
	var collision_shape: CollisionShape2D = CollisionShape2D.new()
	var shape: RectangleShape2D = RectangleShape2D.new()
	var size: Vector2 = Vector2(rect.size.x * TILE_SIZE, rect.size.y * TILE_SIZE)

	shape.size = size
	collision_shape.shape = shape
	collision_shape.position = Vector2(size.x * 0.5, size.y * 0.5)
	body.position = Vector2(rect.position.x * TILE_SIZE, rect.position.y * TILE_SIZE)
	body.add_child(collision_shape)
	collision_root.add_child(body)

func _create_ground_tile_set() -> TileSet:
	var image: Image = Image.create(TILE_SIZE, TILE_SIZE, false, Image.FORMAT_RGBA8)
	image.fill(_biome_ground_color)

	var texture: ImageTexture = ImageTexture.create_from_image(image)
	var tile_set: TileSet = TileSet.new()
	var atlas_source: TileSetAtlasSource = TileSetAtlasSource.new()

	atlas_source.texture = texture
	atlas_source.texture_region_size = Vector2i(TILE_SIZE, TILE_SIZE)
	atlas_source.create_tile(Vector2i.ZERO)

	tile_set.add_source(atlas_source, 0)
	tile_set.tile_size = Vector2i(TILE_SIZE, TILE_SIZE)
	return tile_set

func _tile_to_world_center(tile: Vector2i) -> Vector2:
	return Vector2(
		tile.x * TILE_SIZE + TILE_SIZE * 0.5,
		tile.y * TILE_SIZE + TILE_SIZE * 0.5
	)

# ============================================================================
# BACKGROUND SETUP
# ============================================================================

func _setup_background() -> void:
	_rebuild_layer_children(sky_layer)
	_rebuild_layer_children(far_layer)
	_rebuild_layer_children(mid_layer)
	_rebuild_layer_children(fog_layer)
	_rebuild_layer_children(foreground_layer)
	sky_layer.motion_scale = _biome_sky_motion_scale
	far_layer.motion_scale = _biome_far_motion_scale
	mid_layer.motion_scale = _biome_mid_motion_scale
	fog_layer.motion_scale = _biome_fog_motion_scale
	foreground_layer.motion_scale = _biome_foreground_motion_scale
	_add_sky_gradient()
	_add_far_silhouettes()
	_add_mid_silhouettes()
	_add_fog_bands()
	_add_foreground_landmarks()

func _rebuild_layer_children(layer: ParallaxLayer) -> void:
	for child: Node in layer.get_children():
		child.queue_free()

func _add_sky_gradient() -> void:
	var sky_rect: TextureRect = TextureRect.new()
	var gradient: Gradient = Gradient.new()
	var gradient_texture: GradientTexture2D = GradientTexture2D.new()

	gradient.colors = PackedColorArray([_biome_sky_top_color, _biome_sky_bottom_color])
	gradient.offsets = PackedFloat32Array([0.0, 1.0])
	gradient_texture.gradient = gradient
	gradient_texture.width = WORLD_WIDTH_TILES * TILE_SIZE
	gradient_texture.height = WORLD_HEIGHT_TILES * TILE_SIZE

	sky_rect.size = Vector2(WORLD_WIDTH_TILES * TILE_SIZE, WORLD_HEIGHT_TILES * TILE_SIZE)
	sky_rect.stretch_mode = TextureRect.STRETCH_SCALE
	sky_rect.texture = gradient_texture
	sky_layer.add_child(sky_rect)

func _add_far_silhouettes() -> void:
	_add_ruin_shape(
		far_layer,
		_biome_far_color,
		[
			Vector2(0, 600), Vector2(180, 520), Vector2(360, 560), Vector2(540, 430),
			Vector2(720, 500), Vector2(980, 340), Vector2(1220, 430), Vector2(1500, 300),
			Vector2(1780, 430), Vector2(2060, 310), Vector2(2360, 400), Vector2(2700, 290),
			Vector2(3072, 360), Vector2(3072, 960), Vector2(0, 960)
		]
	)
	_add_ruin_shape(
		far_layer,
		Color(_biome_far_color.r, _biome_far_color.g, _biome_far_color.b, 0.75),
		[
			Vector2(0, 680), Vector2(240, 620), Vector2(520, 660), Vector2(780, 570),
			Vector2(1090, 640), Vector2(1370, 520), Vector2(1680, 620), Vector2(2010, 540),
			Vector2(2390, 650), Vector2(2740, 580), Vector2(3072, 640), Vector2(3072, 960),
			Vector2(0, 960)
		]
	)

func _add_mid_silhouettes() -> void:
	_add_ruin_shape(
		mid_layer,
		_biome_mid_color,
		[
			Vector2(0, 760), Vector2(120, 700), Vector2(230, 590), Vector2(360, 640),
			Vector2(470, 520), Vector2(620, 610), Vector2(760, 450), Vector2(940, 540),
			Vector2(1100, 390), Vector2(1290, 520), Vector2(1470, 360), Vector2(1670, 500),
			Vector2(1880, 380), Vector2(2110, 520), Vector2(2360, 410), Vector2(2580, 560),
			Vector2(2830, 470), Vector2(3072, 560), Vector2(3072, 960), Vector2(0, 960)
		]
	)

func _add_fog_bands() -> void:
	var high_fog: ColorRect = ColorRect.new()
	var low_fog: ColorRect = ColorRect.new()

	high_fog.position = Vector2(0, 320)
	high_fog.size = Vector2(WORLD_WIDTH_TILES * TILE_SIZE, 160)
	high_fog.color = _biome_fog_color
	fog_layer.add_child(high_fog)

	low_fog.position = Vector2(0, 520)
	low_fog.size = Vector2(WORLD_WIDTH_TILES * TILE_SIZE, 210)
	low_fog.color = Color(_biome_fog_color.r, _biome_fog_color.g, _biome_fog_color.b, 0.30)
	fog_layer.add_child(low_fog)

func _add_foreground_landmarks() -> void:
	_add_ruin_shape(
		foreground_layer,
		_biome_foreground_color,
		[
			Vector2(90, 960), Vector2(90, 520), Vector2(170, 520), Vector2(170, 960)
		]
	)
	_add_ruin_shape(
		foreground_layer,
		_biome_foreground_color,
		[
			Vector2(1510, 960), Vector2(1510, 360), Vector2(1600, 360), Vector2(1600, 960)
		]
	)
	_add_ruin_shape(
		foreground_layer,
		_biome_foreground_color,
		[
			Vector2(2890, 960), Vector2(2890, 470), Vector2(2990, 470), Vector2(2990, 960)
		]
	)
	_add_ruin_shape(
		foreground_layer,
		Color(_biome_foreground_color.r, _biome_foreground_color.g, _biome_foreground_color.b, 0.55),
		[
			Vector2(0, 900), Vector2(400, 820), Vector2(780, 870), Vector2(1180, 780),
			Vector2(1560, 860), Vector2(1920, 790), Vector2(2320, 870), Vector2(2700, 800),
			Vector2(3072, 860), Vector2(3072, 960), Vector2(0, 960)
		]
	)
	_add_ruin_shape(
		foreground_layer,
		Color(_biome_foreground_color.r, _biome_foreground_color.g, _biome_foreground_color.b, 0.68),
		[
			Vector2(260, 960), Vector2(260, 680), Vector2(340, 680), Vector2(340, 960)
		]
	)
	_add_ruin_shape(
		foreground_layer,
		Color(_biome_foreground_color.r, _biome_foreground_color.g, _biome_foreground_color.b, 0.68),
		[
			Vector2(2740, 960), Vector2(2740, 660), Vector2(2820, 660), Vector2(2820, 960)
		]
	)

func _add_ruin_shape(layer: ParallaxLayer, color: Color, points: Array[Vector2]) -> void:
	var polygon: Polygon2D = Polygon2D.new()
	polygon.color = color
	polygon.polygon = PackedVector2Array(points)
	layer.add_child(polygon)

# ============================================================================
# PLAYER SETUP
# ============================================================================

func _setup_player() -> void:
	if not FileAccess.file_exists(PLAYER_SCENE_PATH):
		return

	var existing_player: Node = $Gameplay.get_node_or_null("Player")
	if existing_player != null:
		existing_player.queue_free()

	var player_scene: PackedScene = load(PLAYER_SCENE_PATH)
	var player_instance: Node2D = player_scene.instantiate() as Node2D
	if player_instance == null:
		return

	player_instance.position = player_spawn.position
	$Gameplay.add_child(player_instance)
	_configure_player_camera(player_instance)

func _configure_player_camera(player_instance: Node2D) -> void:
	var camera: Camera2D = player_instance.get_node_or_null("Camera2D")
	if camera == null:
		return

	camera.limit_left = int(left_limit.position.x)
	camera.limit_top = int(top_limit.position.y)
	camera.limit_right = int(right_limit.position.x)
	camera.limit_bottom = int(bottom_limit.position.y)

func _setup_enemy_director() -> void:
	if not FileAccess.file_exists(ENEMY_DIRECTOR_SCRIPT_PATH):
		return

	if not FileAccess.file_exists(BASIC_ENEMY_SCENE_PATH):
		return

	for child: Node in $Gameplay.get_children():
		if child.is_in_group("enemy"):
			child.queue_free()

	var enemy_scene: PackedScene = load(BASIC_ENEMY_SCENE_PATH)
	var existing_director: Node = get_node_or_null("EnemyDirector")
	if existing_director != null:
		existing_director.queue_free()

	var director_script: Script = load(ENEMY_DIRECTOR_SCRIPT_PATH)
	var director: Node = director_script.new()
	director.name = "EnemyDirector"
	add_child(director)
	director.setup($Gameplay, enemy_spawns_root, enemy_scene, $Gameplay/FutureHooks/SpawnZones)
	_enemy_director = director

# ============================================================================
# DEBUG
# ============================================================================

func _unhandled_input(event: InputEvent) -> void:
	if event is not InputEventKey:
		return

	var key_event: InputEventKey = event
	if not key_event.pressed or key_event.keycode != KEY_F3:
		return

	var pacing_state: String = "n/a"
	var encounter_state: String = "n/a"
	if _enemy_director != null and is_instance_valid(_enemy_director):
		if _enemy_director.has_method("get_pacing_state"):
			pacing_state = String(_enemy_director.call("get_pacing_state"))
		if _enemy_director.has_method("get_encounter_composition"):
			encounter_state = String(_enemy_director.call("get_encounter_composition"))

	print("Level rects: %s | spawn hooks: %s | reward hooks: %s | biome: %s" % [
		_all_level_rects().size(),
		director_spawns_root.get_child_count(),
		reward_hooks_root.get_child_count(),
		_current_biome_stage
	])
	print("Arena pressure | pacing: %s | encounter: %s" % [pacing_state, encounter_state])
