extends Node2D

# ============================================================================
# CONSTANTS
# ============================================================================

const TILE_SIZE: int = 32
const WORLD_WIDTH_TILES: int = 112
const WORLD_HEIGHT_TILES: int = 34
const PLAYER_SCENE_PATH: String = "res://scenes/player/Player.tscn"
const BASIC_ENEMY_SCENE_PATH: String = "res://scenes/enemies/basic_enemy.tscn"
const ENEMY_DIRECTOR_SCRIPT_PATH: String = "res://scripts/world/enemy_director.gd"
const META_PROGRESS_SAVE_PATH: String = "user://goblin_game_meta_progress.cfg"
const META_PROGRESS_SECTION: String = "meta_progress"
const META_DISCOVERY_POINTS_KEY: String = "discovery_points"
const CHALLENGE_VARIANT_BALANCED: String = "balanced"
const CHALLENGE_VARIANT_SURGE: String = "surge"
const CHALLENGE_VARIANT_ENDURANCE: String = "endurance"
const CHALLENGE_VARIANT_TRAVERSAL: String = "traversal"
const CHALLENGE_VARIANT_ECOLOGY: String = "ecology"
const AUDIO_MIX_RATE: float = 22050.0
const AUDIO_BUFFER_LENGTH: float = 0.24
const AUDIO_ATMOSPHERE_VOLUME_DB: float = -28.0
const AUDIO_COMBAT_VOLUME_DB: float = -16.0
const AUDIO_MOVEMENT_VOLUME_DB: float = -18.0
const AUDIO_STATUS_VOLUME_DB: float = -15.0
const AUDIO_REWARD_VOLUME_DB: float = -14.5

const CENTRAL_ZONE_RECTS: Array[Rect2i] = [
	Rect2i(38, 18, 20, 2),
	Rect2i(44, 16, 8, 2),
	Rect2i(30, 17, 4, 2),
	Rect2i(47, 14, 2, 1),
	Rect2i(62, 17, 4, 2)
]

const LEFT_ROUTE_RECTS: Array[Rect2i] = [
	Rect2i(22, 20, 18, 3),
	Rect2i(6, 21, 18, 3),
	Rect2i(0, 23, 12, 4),
	Rect2i(10, 17, 10, 2),
	Rect2i(18, 15, 10, 2),
	Rect2i(26, 13, 8, 2),
	Rect2i(34, 11, 8, 2),
	Rect2i(2, 9, 8, 2),
	Rect2i(0, 6, 8, 2)
]

const RIGHT_ROUTE_RECTS: Array[Rect2i] = [
	Rect2i(58, 20, 18, 3),
	Rect2i(74, 21, 18, 3),
	Rect2i(88, 23, 14, 4),
	Rect2i(80, 17, 8, 2),
	Rect2i(72, 15, 8, 2),
	Rect2i(64, 13, 8, 2),
	Rect2i(70, 11, 8, 2),
	Rect2i(82, 8, 10, 2),
	Rect2i(94, 6, 8, 2)
]

const UPPER_ROUTE_RECTS: Array[Rect2i] = [
	Rect2i(26, 13, 14, 2),
	Rect2i(40, 11, 10, 2),
	Rect2i(50, 9, 10, 2),
	Rect2i(60, 8, 10, 2),
	Rect2i(70, 9, 10, 2),
	Rect2i(80, 11, 10, 2),
	Rect2i(90, 12, 10, 2),
	Rect2i(48, 6, 6, 2)
]

const LOWER_ROUTE_RECTS: Array[Rect2i] = [
	Rect2i(16, 25, 24, 2),
	Rect2i(44, 26, 16, 2),
	Rect2i(64, 25, 24, 2),
	Rect2i(88, 24, 16, 2),
	Rect2i(28, 22, 6, 1),
	Rect2i(56, 22, 6, 1),
	Rect2i(84, 22, 6, 1)
]

const BRIDGE_RECTS: Array[Rect2i] = [
	Rect2i(32, 17, 12, 2),
	Rect2i(50, 17, 12, 2),
	Rect2i(42, 14, 14, 2),
	Rect2i(46, 8, 10, 2)
]

const TRANSITION_RECTS: Array[Rect2i] = [
	Rect2i(20, 18, 4, 2),
	Rect2i(28, 16, 4, 2),
	Rect2i(36, 14, 4, 2),
	Rect2i(56, 18, 4, 2),
	Rect2i(64, 16, 4, 2),
	Rect2i(72, 14, 4, 2),
	Rect2i(44, 18, 6, 2),
	Rect2i(48, 12, 6, 2)
]

const CLIMB_RECTS: Array[Rect2i] = [
	Rect2i(34, 20, 3, 4),
	Rect2i(34, 17, 3, 3),
	Rect2i(62, 20, 3, 4),
	Rect2i(62, 17, 3, 3),
	Rect2i(48, 14, 4, 4)
]

const FAR_LEFT_RECTS: Array[Rect2i] = [
	Rect2i(0, 19, 10, 2),
	Rect2i(0, 16, 8, 1),
	Rect2i(6, 14, 6, 1)
]

const FAR_RIGHT_RECTS: Array[Rect2i] = [
	Rect2i(102, 19, 10, 2),
	Rect2i(98, 16, 8, 1),
	Rect2i(94, 14, 6, 1)
]

const HIGH_RIDGE_RECTS: Array[Rect2i] = [
	Rect2i(22, 11, 16, 2),
	Rect2i(40, 9, 16, 2),
	Rect2i(58, 8, 16, 2),
	Rect2i(76, 7, 14, 2),
	Rect2i(92, 6, 12, 2)
]

const LOW_BASIN_RECTS: Array[Rect2i] = [
	Rect2i(12, 27, 22, 3),
	Rect2i(36, 28, 18, 3),
	Rect2i(56, 27, 22, 3),
	Rect2i(80, 26, 20, 3)
]

const LEFT_ASCENT_ROUTE_POINTS: Array[Vector2i] = [
	Vector2i(12, 18),
	Vector2i(18, 15),
	Vector2i(24, 13),
	Vector2i(30, 11),
	Vector2i(38, 11),
	Vector2i(45, 7)
]

const RIGHT_ASCENT_ROUTE_POINTS: Array[Vector2i] = [
	Vector2i(52, 16),
	Vector2i(60, 17),
	Vector2i(68, 15),
	Vector2i(76, 13),
	Vector2i(84, 8),
	Vector2i(92, 6)
]

const HIGHLINE_VERTICAL_ROUTE_POINTS: Array[Vector2i] = [
	Vector2i(22, 15),
	Vector2i(32, 13),
	Vector2i(42, 11),
	Vector2i(50, 8),
	Vector2i(57, 11),
	Vector2i(66, 13)
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
	Vector2i(90, 23),
	Vector2i(104, 23)
]

const MIXED_SPAWN_POINTS: Array[Vector2i] = [
	Vector2i(22, 15),
	Vector2i(46, 16),
	Vector2i(52, 16),
	Vector2i(74, 16),
	Vector2i(92, 18)
]

const RANGED_SPAWN_POINTS: Array[Vector2i] = [
	Vector2i(34, 11),
	Vector2i(50, 8),
	Vector2i(68, 11),
	Vector2i(100, 8)
]

const ARENA_MARKER_POINTS: Array[Vector2i] = [
	Vector2i(23, 19),
	Vector2i(48, 16),
	Vector2i(73, 19),
	Vector2i(96, 18)
]

const SAFE_ROUTE_POINTS: Array[Vector2i] = [
	Vector2i(10, 20),
	Vector2i(18, 15),
	Vector2i(28, 11),
	Vector2i(38, 11),
	Vector2i(45, 7),
	Vector2i(57, 11),
	Vector2i(66, 13),
	Vector2i(74, 16),
	Vector2i(90, 18),
	Vector2i(104, 20)
]

const RISK_ROUTE_POINTS: Array[Vector2i] = [
	Vector2i(10, 20),
	Vector2i(24, 19),
	Vector2i(38, 18),
	Vector2i(48, 16),
	Vector2i(60, 17),
	Vector2i(76, 20),
	Vector2i(90, 23),
	Vector2i(100, 22),
	Vector2i(108, 21)
]

const RECOVERY_ROUTE_POINTS: Array[Vector2i] = [
	Vector2i(2, 23),
	Vector2i(18, 24),
	Vector2i(36, 25),
	Vector2i(52, 24),
	Vector2i(70, 22),
	Vector2i(88, 23),
	Vector2i(100, 24),
	Vector2i(108, 24)
]

const LEFT_FORK_ROUTE_POINTS: Array[Vector2i] = [
	Vector2i(2, 23),
	Vector2i(10, 20),
	Vector2i(18, 15),
	Vector2i(24, 19),
	Vector2i(32, 23),
	Vector2i(38, 18),
	Vector2i(45, 7)
]

const RIGHT_FORK_ROUTE_POINTS: Array[Vector2i] = [
	Vector2i(47, 14),
	Vector2i(56, 17),
	Vector2i(66, 17),
	Vector2i(74, 16),
	Vector2i(82, 19),
	Vector2i(90, 23)
]

const HIGHLINE_ROUTE_POINTS: Array[Vector2i] = [
	Vector2i(22, 15),
	Vector2i(32, 13),
	Vector2i(42, 11),
	Vector2i(50, 8),
	Vector2i(57, 11),
	Vector2i(66, 13),
	Vector2i(74, 16)
]

const FAR_LEFT_ROUTE_POINTS: Array[Vector2i] = [
	Vector2i(0, 23),
	Vector2i(8, 21),
	Vector2i(16, 18),
	Vector2i(24, 15),
	Vector2i(32, 13),
	Vector2i(45, 7)
]

const FAR_RIGHT_ROUTE_POINTS: Array[Vector2i] = [
	Vector2i(57, 17),
	Vector2i(68, 17),
	Vector2i(80, 18),
	Vector2i(92, 21),
	Vector2i(104, 23),
	Vector2i(110, 22)
]

const HIGH_RIDGE_ROUTE_POINTS: Array[Vector2i] = [
	Vector2i(24, 11),
	Vector2i(36, 10),
	Vector2i(48, 8),
	Vector2i(60, 7),
	Vector2i(72, 6),
	Vector2i(86, 6),
	Vector2i(100, 5)
]

const LOW_BASIN_ROUTE_POINTS: Array[Vector2i] = [
	Vector2i(12, 26),
	Vector2i(28, 27),
	Vector2i(44, 28),
	Vector2i(60, 27),
	Vector2i(76, 26),
	Vector2i(92, 25),
	Vector2i(108, 24)
]

const DIRECTOR_SPAWN_POINTS: Array[Vector2i] = [
	Vector2i(12, 18),
	Vector2i(30, 17),
	Vector2i(48, 15),
	Vector2i(66, 17),
	Vector2i(84, 18),
	Vector2i(52, 22),
	Vector2i(100, 20)
]

const REWARD_HOOK_POINTS: Array[Vector2i] = [
	Vector2i(2, 5),
	Vector2i(94, 5),
	Vector2i(47, 4),
	Vector2i(108, 6)
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
const WORLD_CHUNK_CATEGORY_RECOVERY: String = "recovery"
const WORLD_CHUNK_CATEGORY_TRAVERSAL: String = "traversal"
const WORLD_CHUNK_CATEGORY_ESCALATION: String = "escalation"
const WORLD_CHUNK_CATEGORY_PRESSURE: String = "pressure"
const WORLD_CHUNK_CATEGORY_CLIMAX: String = "climax"
const WORLD_BIOME_POOL_EARLY: String = "early_open_pool"
const WORLD_BIOME_POOL_MID: String = "mid_mixed_pool"
const WORLD_BIOME_POOL_LATE: String = "late_pressure_pool"
const WORLD_BIOME_POOL_ENDLESS: String = "endless_loop_pool"
const WORLD_ENCOUNTER_PROFILE_OPEN: String = "open"
const WORLD_ENCOUNTER_PROFILE_MIXED: String = "mixed"
const WORLD_ENCOUNTER_PROFILE_PRESSURE: String = "pressure"
const WORLD_ENCOUNTER_PROFILE_RECOVERY: String = "recovery"

# Layout indices are lightweight handcrafted chunk sequences, not procedural generation.
const WORLD_CHUNK_LAYOUT_CROSSROADS: int = 0
const WORLD_CHUNK_LAYOUT_LEFT_FORK: int = 1
const WORLD_CHUNK_LAYOUT_RIGHT_FORK: int = 2
const WORLD_CHUNK_LAYOUT_HIGHLINE: int = 3
const WORLD_CHUNK_LAYOUT_RECOVERY: int = 4
const WORLD_CHUNK_MIN_RECOVERY_COUNT: int = 1
const WORLD_CHUNK_MIN_TRAVERSAL_COUNT: int = 1
const WORLD_CHUNK_MAX_PRESSURE_COUNT: int = 2
const WORLD_CHUNK_MAX_CLIMAX_COUNT: int = 1

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
var _world_chunk_layout_index: int = WORLD_CHUNK_LAYOUT_CROSSROADS
var _world_chunk_layout_name: String = "crossroads"
var _world_chunk_pool_name: String = WORLD_BIOME_POOL_EARLY
var _world_encounter_profile_name: String = WORLD_ENCOUNTER_PROFILE_OPEN
var _current_challenge_variant_name: String = CHALLENGE_VARIANT_BALANCED
var _meta_discovery_points: int = 0
var _audio_atmosphere_player: AudioStreamPlayer = null
var _audio_combat_player: AudioStreamPlayer = null
var _audio_movement_player: AudioStreamPlayer = null
var _audio_status_player: AudioStreamPlayer = null
var _audio_atmosphere_phase: float = 0.0
var _audio_atmosphere_pulse_phase: float = 0.0
var _world_chunk_plan: Array[Dictionary] = []
var _world_chunk_sequence: Array[String] = []
var _world_chunk_category_sequence: Array[String] = []
var _world_chunk_ecology_counts: Dictionary = {}

func _ready() -> void:
	_load_meta_progress()
	_select_challenge_variant()
	_setup_tile_map()
	_clear_tile_map()
	_update_world_bounds()
	_position_player_spawn()
	_select_world_chunk_layout()
	_create_spawn_hooks()
	_create_reward_hooks()
	_create_combat_arenas()
	_create_spawn_zones()
	_build_level_geometry()
	_setup_player()
	_setup_enemy_director()
	_apply_biome_theme(_current_biome_stage)
	_setup_audio_feedback()

func _process(delta: float) -> void:
	_update_survival_audio(delta)
	_sync_biome_theme()
	_sync_arena_pressure()

func _load_meta_progress() -> void:
	_meta_discovery_points = 0

	if not FileAccess.file_exists(META_PROGRESS_SAVE_PATH):
		return

	var config: ConfigFile = ConfigFile.new()
	if config.load(META_PROGRESS_SAVE_PATH) != OK:
		return

	_meta_discovery_points = max(int(config.get_value(META_PROGRESS_SECTION, META_DISCOVERY_POINTS_KEY, 0)), 0)

func _select_challenge_variant() -> void:
	var available_variants: Array[String] = [CHALLENGE_VARIANT_BALANCED]

	if _meta_discovery_points >= 1:
		available_variants.append(CHALLENGE_VARIANT_ENDURANCE)
	if _meta_discovery_points >= 2:
		available_variants.append(CHALLENGE_VARIANT_TRAVERSAL)
	if _meta_discovery_points >= 3:
		available_variants.append(CHALLENGE_VARIANT_ECOLOGY)
	if _meta_discovery_points >= 4:
		available_variants.append(CHALLENGE_VARIANT_SURGE)

	var variant_rng: RandomNumberGenerator = RandomNumberGenerator.new()
	variant_rng.seed = int(Time.get_ticks_usec()) ^ int(get_instance_id()) ^ (_meta_discovery_points * 31)

	match _current_biome_stage:
		"mid":
			_current_challenge_variant_name = _weighted_challenge_variant_choice(available_variants, variant_rng, [CHALLENGE_VARIANT_TRAVERSAL, CHALLENGE_VARIANT_ECOLOGY, CHALLENGE_VARIANT_ENDURANCE])
		"late":
			_current_challenge_variant_name = _weighted_challenge_variant_choice(available_variants, variant_rng, [CHALLENGE_VARIANT_SURGE, CHALLENGE_VARIANT_ECOLOGY, CHALLENGE_VARIANT_TRAVERSAL])
		"endless":
			_current_challenge_variant_name = _weighted_challenge_variant_choice(available_variants, variant_rng, [CHALLENGE_VARIANT_SURGE, CHALLENGE_VARIANT_ECOLOGY, CHALLENGE_VARIANT_ENDURANCE])
		_:
			_current_challenge_variant_name = _weighted_challenge_variant_choice(available_variants, variant_rng, [CHALLENGE_VARIANT_BALANCED, CHALLENGE_VARIANT_ENDURANCE, CHALLENGE_VARIANT_TRAVERSAL])

func _weighted_challenge_variant_choice(available_variants: Array[String], variant_rng: RandomNumberGenerator, preferred_variants: Array[String]) -> String:
	if available_variants.is_empty():
		return CHALLENGE_VARIANT_BALANCED

	var weighted_variants: Array[String] = []
	for variant_name: String in available_variants:
		var weight: int = 1
		if preferred_variants.has(variant_name):
			weight += 2
		for weight_index: int in range(weight):
			weighted_variants.append(variant_name)

	return weighted_variants[variant_rng.randi_range(0, weighted_variants.size() - 1)]

func _setup_tile_map() -> void:
	ground_tile_map.tile_set = _create_ground_tile_set()

func _clear_tile_map() -> void:
	ground_tile_map.clear()

func _update_world_bounds() -> void:
	left_limit.position.x = 0.0
	top_limit.position.y = 0.0
	right_limit.position.x = WORLD_WIDTH_TILES * TILE_SIZE
	bottom_limit.position.y = WORLD_HEIGHT_TILES * TILE_SIZE

func _position_player_spawn() -> void:
	player_spawn.position = Vector2(52 * TILE_SIZE + TILE_SIZE * 0.5, 17 * TILE_SIZE)

func _create_spawn_hooks() -> void:
	_clear_children(director_spawns_root)
	var spawn_points: Array[Vector2i] = _current_world_spawn_hook_points()
	for index: int in range(spawn_points.size()):
		var marker: Marker2D = Marker2D.new()
		marker.name = "SpawnHook_%02d" % index
		marker.position = _tile_to_world_center(spawn_points[index])
		director_spawns_root.add_child(marker)

func _create_reward_hooks() -> void:
	_clear_children(reward_hooks_root)
	var reward_points: Array[Vector2i] = _current_world_reward_hook_points()
	for index: int in range(reward_points.size()):
		var marker: Marker2D = Marker2D.new()
		marker.name = "RewardHook_%02d" % index
		marker.position = _tile_to_world_center(reward_points[index])
		reward_hooks_root.add_child(marker)

func _create_combat_arenas() -> void:
	_clear_children(combat_arenas_root)
	var arena_points: Array[Vector2i] = _current_world_arena_marker_points()
	for index: int in range(arena_points.size()):
		var marker: Marker2D = Marker2D.new()
		marker.name = "Arena_%02d" % index
		marker.position = _tile_to_world_center(arena_points[index])
		combat_arenas_root.add_child(marker)

func _create_spawn_zones() -> void:
	_clear_children(melee_spawn_root)
	_clear_children(mixed_spawn_root)
	_clear_children(ranged_spawn_root)
	_create_zone_markers(melee_spawn_root, _current_world_melee_spawn_points(), "MeleeZone")
	_create_zone_markers(mixed_spawn_root, _current_world_mixed_spawn_points(), "MixedZone")
	_create_zone_markers(ranged_spawn_root, _current_world_ranged_spawn_points(), "RangedZone")

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
	var level_rects: Array[Rect2i] = _all_level_rects()
	level_rects = _expand_combat_flow_rects(level_rects)
	_paint_level_rects(level_rects)
	_create_level_colliders(level_rects)

# ============================================================================
# TRAVERSAL
# ============================================================================

func _create_traversal_routes() -> void:
	_clear_children(traversal_routes_root)
	for route_spec: Dictionary in _current_world_route_specs():
		var route_name: String = String(route_spec["name"])
		var route_points: Array[Vector2i] = route_spec["points"]
		var route_color: Color = route_spec["color"]
		var route_width: float = float(route_spec["width"])
		_add_route_line(
			route_name,
			route_points,
			route_color,
			route_width
		)

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
	var compression_points: Array[Vector2] = [
		Vector2(832, 448), Vector2(2752, 448), Vector2(2752, 768), Vector2(832, 768)
	]
	var risk_points: Array[Vector2] = [
		Vector2(0, 320), Vector2(3584, 320), Vector2(3584, 640), Vector2(0, 640)
	]
	var recovery_points: Array[Vector2] = [
		Vector2(0, 736), Vector2(3584, 736), Vector2(3584, 1024), Vector2(0, 1024)
	]
	match _world_chunk_layout_index:
		WORLD_CHUNK_LAYOUT_LEFT_FORK:
			compression_points = [
				Vector2(640, 448), Vector2(2432, 448), Vector2(2432, 768), Vector2(640, 768)
			]
			risk_points = [
				Vector2(0, 320), Vector2(3264, 320), Vector2(3264, 640), Vector2(0, 640)
			]
			recovery_points = [
				Vector2(0, 736), Vector2(2752, 736), Vector2(2752, 1024), Vector2(0, 1024)
			]
		WORLD_CHUNK_LAYOUT_RIGHT_FORK:
			compression_points = [
				Vector2(960, 448), Vector2(2816, 448), Vector2(2816, 768), Vector2(960, 768)
			]
			risk_points = [
				Vector2(256, 320), Vector2(3584, 320), Vector2(3584, 640), Vector2(256, 640)
			]
			recovery_points = [
				Vector2(512, 736), Vector2(3584, 736), Vector2(3584, 1024), Vector2(512, 1024)
			]
		WORLD_CHUNK_LAYOUT_HIGHLINE:
			compression_points = [
				Vector2(736, 384), Vector2(2816, 384), Vector2(2816, 704), Vector2(736, 704)
			]
			risk_points = [
				Vector2(0, 288), Vector2(3584, 288), Vector2(3584, 608), Vector2(0, 608)
			]
			recovery_points = [
				Vector2(0, 768), Vector2(3584, 768), Vector2(3584, 1024), Vector2(0, 1024)
			]
		WORLD_CHUNK_LAYOUT_RECOVERY:
			compression_points = [
				Vector2(768, 480), Vector2(2752, 480), Vector2(2752, 800), Vector2(768, 800)
			]
			risk_points = [
				Vector2(0, 352), Vector2(3584, 352), Vector2(3584, 672), Vector2(0, 672)
			]
			recovery_points = [
				Vector2(0, 672), Vector2(3584, 672), Vector2(3584, 1024), Vector2(0, 1024)
			]
	_arena_compression_zone = _add_pressure_polygon(
		"CompressionZone",
		compression_points,
		PRESSURE_COMPRESSION_COLOR
	)
	_arena_risk_zone = _add_pressure_polygon(
		"RiskZone",
		risk_points,
		PRESSURE_RISK_COLOR
	)
	_arena_recovery_zone = _add_pressure_polygon(
		"RecoveryZone",
		recovery_points,
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
	var loop_state: String = "none"
	var loop_index: int = 0
	var loop_progress: float = 0.0
	var finale_state: String = "none"
	var finale_progress: float = 0.0
	var landmark_event: String = "none"
	var ecology_counts: Dictionary = _current_world_chunk_ecology_counts()

	if _enemy_director.has_method("get_encounter_composition"):
		encounter_state = String(_enemy_director.call("get_encounter_composition"))

	if _enemy_director.has_method("get_pressure"):
		pressure_value = float(_enemy_director.call("get_pressure"))

	if _enemy_director.has_method("get_landmark_event_type"):
		landmark_event = String(_enemy_director.call("get_landmark_event_type"))

	if _enemy_director.has_method("get_stage_finale_state"):
		finale_state = String(_enemy_director.call("get_stage_finale_state"))

	if _enemy_director.has_method("get_stage_finale_progress"):
		finale_progress = float(_enemy_director.call("get_stage_finale_progress"))

	if _enemy_director.has_method("get_run_loop_state"):
		loop_state = String(_enemy_director.call("get_run_loop_state"))

	if _enemy_director.has_method("get_run_loop_index"):
		loop_index = int(_enemy_director.call("get_run_loop_index"))

	if _enemy_director.has_method("get_run_loop_progress"):
		loop_progress = float(_enemy_director.call("get_run_loop_progress"))

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
		"loop_transition":
			compression_alpha += 0.08
			risk_alpha += 0.08
			recovery_alpha = max(recovery_alpha - 0.05, 0.0)
		"finale":
			compression_alpha += 0.10
			risk_alpha += 0.08
			recovery_alpha = max(recovery_alpha - 0.04, 0.0)
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

	if finale_progress > 0.0:
		compression_alpha += 0.04 + finale_progress * 0.08
		risk_alpha += 0.03 + finale_progress * 0.06
		recovery_alpha = max(recovery_alpha - finale_progress * 0.05, 0.0)

	if finale_state == "climax":
		compression_alpha += 0.04
		risk_alpha += 0.03

	if loop_state == "loop_transition":
		compression_alpha += 0.04
		risk_alpha += 0.04
		recovery_alpha = max(recovery_alpha - 0.03, 0.0)

	if loop_progress > 0.0:
		compression_alpha += 0.02 + loop_progress * 0.05
		risk_alpha += 0.02 + float(loop_index) * 0.01

	compression_alpha += float(ecology_counts.get(WORLD_CHUNK_CATEGORY_PRESSURE, 0)) * 0.008
	compression_alpha += float(ecology_counts.get(WORLD_CHUNK_CATEGORY_CLIMAX, 0)) * 0.012
	risk_alpha += float(ecology_counts.get(WORLD_CHUNK_CATEGORY_ESCALATION, 0)) * 0.010
	recovery_alpha += float(ecology_counts.get(WORLD_CHUNK_CATEGORY_RECOVERY, 0)) * 0.010

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
	if _world_chunk_sequence.is_empty():
		_select_world_chunk_layout()

	var level_rects: Array[Rect2i] = []
	for chunk_id: String in _world_chunk_sequence:
		_append_world_chunk_rects(level_rects, chunk_id)
	level_rects.append_array(TRANSITION_RECTS)
	return level_rects

# ============================================================================
# WORLD FLOW
# ============================================================================

func _select_world_chunk_layout() -> void:
	var chunk_rng: RandomNumberGenerator = RandomNumberGenerator.new()
	chunk_rng.seed = int(Time.get_ticks_usec()) ^ int(get_instance_id())
	var layout_candidates: Array[int] = _current_world_chunk_layout_candidates()
	if layout_candidates.is_empty():
		layout_candidates = [WORLD_CHUNK_LAYOUT_CROSSROADS]

	var selected_candidate_count: int = min(2, layout_candidates.size())
	_world_chunk_layout_index = layout_candidates[chunk_rng.randi_range(0, selected_candidate_count - 1)]
	_refresh_world_chunk_layout_state()
	if not _current_world_chunk_plan_is_stable(_world_chunk_plan):
		_world_chunk_layout_index = WORLD_CHUNK_LAYOUT_CROSSROADS
		_refresh_world_chunk_layout_state()

func _refresh_world_chunk_layout_state() -> void:
	_world_chunk_layout_name = _current_world_chunk_layout_name()
	_world_chunk_pool_name = _current_world_chunk_pool_name()
	_world_chunk_plan = _current_world_chunk_plan()
	_world_chunk_sequence = _current_world_chunk_sequence()
	_world_chunk_category_sequence = _current_world_chunk_category_sequence()
	_world_chunk_ecology_counts = _current_world_chunk_ecology_counts()
	_world_encounter_profile_name = _current_world_encounter_profile_name()

func _current_world_chunk_layout_name() -> String:
	match _world_chunk_layout_index:
		WORLD_CHUNK_LAYOUT_LEFT_FORK:
			return "left_fork"
		WORLD_CHUNK_LAYOUT_RIGHT_FORK:
			return "right_fork"
		WORLD_CHUNK_LAYOUT_HIGHLINE:
			return "highline"
		WORLD_CHUNK_LAYOUT_RECOVERY:
			return "recovery"
		_:
			return "crossroads"

func _current_world_chunk_pool_name() -> String:
	match _current_biome_stage:
		"mid":
			return WORLD_BIOME_POOL_MID
		"late":
			return WORLD_BIOME_POOL_LATE
		"endless":
			return WORLD_BIOME_POOL_ENDLESS
		_:
			return WORLD_BIOME_POOL_EARLY

func _current_world_chunk_layout_candidates() -> Array[int]:
	var meta_discovery_points: int = _meta_discovery_points
	var target_profiles: Array[String] = [WORLD_ENCOUNTER_PROFILE_OPEN, WORLD_ENCOUNTER_PROFILE_RECOVERY]

	match _current_challenge_variant_name:
		"surge":
			target_profiles = [WORLD_ENCOUNTER_PROFILE_PRESSURE, WORLD_ENCOUNTER_PROFILE_MIXED]
		"endurance":
			target_profiles = [WORLD_ENCOUNTER_PROFILE_RECOVERY, WORLD_ENCOUNTER_PROFILE_OPEN]
		"traversal":
			target_profiles = [WORLD_ENCOUNTER_PROFILE_OPEN, WORLD_ENCOUNTER_PROFILE_MIXED]
		"ecology":
			target_profiles = [WORLD_ENCOUNTER_PROFILE_MIXED, WORLD_ENCOUNTER_PROFILE_PRESSURE, WORLD_ENCOUNTER_PROFILE_RECOVERY]
		_:
			target_profiles = [WORLD_ENCOUNTER_PROFILE_OPEN, WORLD_ENCOUNTER_PROFILE_RECOVERY]

	if meta_discovery_points >= 2:
		target_profiles.append(WORLD_ENCOUNTER_PROFILE_MIXED)
	if meta_discovery_points >= 4:
		target_profiles.append(WORLD_ENCOUNTER_PROFILE_PRESSURE)
	if meta_discovery_points >= 6:
		target_profiles.append(WORLD_ENCOUNTER_PROFILE_RECOVERY)

	match _current_biome_stage:
		"late":
			target_profiles.append(WORLD_ENCOUNTER_PROFILE_PRESSURE)
		"endless":
			target_profiles.append(WORLD_ENCOUNTER_PROFILE_MIXED)

	return _ranked_world_chunk_layout_candidates(target_profiles)

func _ranked_world_chunk_layout_candidates(target_profiles: Array[String]) -> Array[int]:
	var layout_scores: Array[Dictionary] = []
	for layout_index: int in [
		WORLD_CHUNK_LAYOUT_CROSSROADS,
		WORLD_CHUNK_LAYOUT_LEFT_FORK,
		WORLD_CHUNK_LAYOUT_RIGHT_FORK,
		WORLD_CHUNK_LAYOUT_HIGHLINE,
		WORLD_CHUNK_LAYOUT_RECOVERY
	]:
		var score: int = _current_world_chunk_layout_score(layout_index, target_profiles)
		layout_scores.append({"layout": layout_index, "score": score})

	layout_scores.sort_custom(func(left_entry: Dictionary, right_entry: Dictionary) -> bool:
		return int(left_entry["score"]) > int(right_entry["score"])
	)

	var ordered_layouts: Array[int] = []
	for entry: Dictionary in layout_scores:
		ordered_layouts.append(int(entry["layout"]))

	return ordered_layouts

func _current_world_chunk_layout_score(layout_index: int, target_profiles: Array[String]) -> int:
	var plan: Array[Dictionary] = _current_world_chunk_plan_for_layout(layout_index)
	var ecology_counts: Dictionary = _current_world_chunk_ecology_counts_for_plan(plan)
	var score: int = _current_world_chunk_plan_stability_score(plan)

	for target_profile: String in target_profiles:
		score += _current_world_chunk_profile_score(target_profile, ecology_counts)

	return score

func _current_world_chunk_plan_is_stable(plan: Array[Dictionary]) -> bool:
	var ecology_counts: Dictionary = _current_world_chunk_ecology_counts_for_plan(plan)
	var recovery_count: int = int(ecology_counts.get(WORLD_CHUNK_CATEGORY_RECOVERY, 0))
	var traversal_count: int = int(ecology_counts.get(WORLD_CHUNK_CATEGORY_TRAVERSAL, 0))
	var pressure_count: int = int(ecology_counts.get(WORLD_CHUNK_CATEGORY_PRESSURE, 0))
	var climax_count: int = int(ecology_counts.get(WORLD_CHUNK_CATEGORY_CLIMAX, 0))

	if recovery_count < WORLD_CHUNK_MIN_RECOVERY_COUNT:
		return false

	if traversal_count < WORLD_CHUNK_MIN_TRAVERSAL_COUNT:
		return false

	if pressure_count > WORLD_CHUNK_MAX_PRESSURE_COUNT:
		return false

	if climax_count != WORLD_CHUNK_MAX_CLIMAX_COUNT:
		return false

	if recovery_count + traversal_count <= pressure_count:
		return false

	return true

func _current_world_chunk_plan_stability_score(plan: Array[Dictionary]) -> int:
	var ecology_counts: Dictionary = _current_world_chunk_ecology_counts_for_plan(plan)
	var recovery_count: int = int(ecology_counts.get(WORLD_CHUNK_CATEGORY_RECOVERY, 0))
	var traversal_count: int = int(ecology_counts.get(WORLD_CHUNK_CATEGORY_TRAVERSAL, 0))
	var pressure_count: int = int(ecology_counts.get(WORLD_CHUNK_CATEGORY_PRESSURE, 0))
	var climax_count: int = int(ecology_counts.get(WORLD_CHUNK_CATEGORY_CLIMAX, 0))
	var score: int = 0

	if recovery_count >= WORLD_CHUNK_MIN_RECOVERY_COUNT:
		score += 4
	else:
		score -= 8

	if traversal_count >= WORLD_CHUNK_MIN_TRAVERSAL_COUNT:
		score += 3
	else:
		score -= 5

	if pressure_count <= WORLD_CHUNK_MAX_PRESSURE_COUNT:
		score += 2
	else:
		score -= (pressure_count - WORLD_CHUNK_MAX_PRESSURE_COUNT) * 3

	if climax_count == WORLD_CHUNK_MAX_CLIMAX_COUNT:
		score += 4
	else:
		score -= 8

	if recovery_count + traversal_count >= pressure_count + 2:
		score += 2
	else:
		score -= 2

	return score

func _current_world_chunk_profile_score(profile_name: String, ecology_counts: Dictionary) -> int:
	var recovery_count: int = int(ecology_counts.get(WORLD_ENCOUNTER_PROFILE_RECOVERY, 0))
	var traversal_count: int = int(ecology_counts.get(WORLD_CHUNK_CATEGORY_TRAVERSAL, 0))
	var pressure_count: int = int(ecology_counts.get(WORLD_CHUNK_CATEGORY_PRESSURE, 0))
	var climax_count: int = int(ecology_counts.get(WORLD_CHUNK_CATEGORY_CLIMAX, 0))
	var melee_count: int = int(ecology_counts.get("melee", 0))
	var ranged_count: int = int(ecology_counts.get("ranged", 0))
	var swarm_count: int = int(ecology_counts.get("swarm", 0))
	var open_count: int = int(ecology_counts.get("open", 0))

	match profile_name:
		WORLD_ENCOUNTER_PROFILE_RECOVERY:
			return recovery_count * 3 + traversal_count * 2 + open_count * 2 - pressure_count * 2 - swarm_count
		WORLD_ENCOUNTER_PROFILE_PRESSURE:
			return pressure_count * 3 + climax_count * 2 + ranged_count * 2 + swarm_count * 2 - recovery_count
		WORLD_ENCOUNTER_PROFILE_MIXED:
			return traversal_count * 2 + pressure_count + recovery_count + melee_count + ranged_count + swarm_count
		_:
			return open_count * 3 + recovery_count * 2 + traversal_count * 2 - pressure_count - swarm_count

# ============================================================================
# ARENA CHUNKS
# ============================================================================

func _current_world_chunk_plan() -> Array[Dictionary]:
	return _current_world_chunk_plan_for_layout(_world_chunk_layout_index)

func _current_world_chunk_plan_for_layout(layout_index: int) -> Array[Dictionary]:
	match layout_index:
		WORLD_CHUNK_LAYOUT_LEFT_FORK:
			return [
				{"id": "arrival_core", "category": WORLD_CHUNK_CATEGORY_RECOVERY, "ecology": ["open", "melee"]},
				{"id": "left_flank", "category": WORLD_CHUNK_CATEGORY_ESCALATION, "ecology": ["open", "melee"]},
				{"id": "upper_cross", "category": WORLD_CHUNK_CATEGORY_TRAVERSAL, "ecology": ["open", "ranged"]},
				{"id": "bridge_cross", "category": WORLD_CHUNK_CATEGORY_PRESSURE, "ecology": ["pressure", "swarm"]},
				{"id": "climb_cross", "category": WORLD_CHUNK_CATEGORY_TRAVERSAL, "ecology": ["open", "melee"]},
				{"id": "pressure_landmark", "category": WORLD_CHUNK_CATEGORY_CLIMAX, "ecology": ["climax", "elite"]}
			]
		WORLD_CHUNK_LAYOUT_RIGHT_FORK:
			return [
				{"id": "arrival_core", "category": WORLD_CHUNK_CATEGORY_RECOVERY, "ecology": ["open", "melee"]},
				{"id": "right_flank", "category": WORLD_CHUNK_CATEGORY_ESCALATION, "ecology": ["pressure", "ranged"]},
				{"id": "lower_cross", "category": WORLD_CHUNK_CATEGORY_TRAVERSAL, "ecology": ["open", "ranged"]},
				{"id": "bridge_cross", "category": WORLD_CHUNK_CATEGORY_PRESSURE, "ecology": ["pressure", "swarm"]},
				{"id": "climb_cross", "category": WORLD_CHUNK_CATEGORY_TRAVERSAL, "ecology": ["open", "melee"]},
				{"id": "survival_landmark", "category": WORLD_CHUNK_CATEGORY_CLIMAX, "ecology": ["climax", "elite"]}
			]
		WORLD_CHUNK_LAYOUT_HIGHLINE:
			return [
				{"id": "arrival_core", "category": WORLD_CHUNK_CATEGORY_RECOVERY, "ecology": ["open", "melee"]},
				{"id": "left_flank", "category": WORLD_CHUNK_CATEGORY_TRAVERSAL, "ecology": ["open", "ranged"]},
				{"id": "right_flank", "category": WORLD_CHUNK_CATEGORY_ESCALATION, "ecology": ["pressure", "ranged"]},
				{"id": "upper_cross", "category": WORLD_CHUNK_CATEGORY_TRAVERSAL, "ecology": ["open", "ranged"]},
				{"id": "bridge_cross", "category": WORLD_CHUNK_CATEGORY_PRESSURE, "ecology": ["pressure", "swarm"]},
				{"id": "vertical_landmark", "category": WORLD_CHUNK_CATEGORY_CLIMAX, "ecology": ["climax", "elite"]}
			]
		WORLD_CHUNK_LAYOUT_RECOVERY:
			return [
				{"id": "arrival_core", "category": WORLD_CHUNK_CATEGORY_RECOVERY, "ecology": ["open", "melee"]},
				{"id": "lower_cross", "category": WORLD_CHUNK_CATEGORY_RECOVERY, "ecology": ["open", "melee"]},
				{"id": "left_flank", "category": WORLD_CHUNK_CATEGORY_TRAVERSAL, "ecology": ["open", "melee"]},
				{"id": "right_flank", "category": WORLD_CHUNK_CATEGORY_TRAVERSAL, "ecology": ["open", "ranged"]},
				{"id": "bridge_cross", "category": WORLD_CHUNK_CATEGORY_ESCALATION, "ecology": ["pressure", "swarm"]},
				{"id": "recovery_landmark", "category": WORLD_CHUNK_CATEGORY_CLIMAX, "ecology": ["climax", "elite"]}
			]
		_:
			return [
				{"id": "arrival_core", "category": WORLD_CHUNK_CATEGORY_RECOVERY, "ecology": ["open", "melee"]},
				{"id": "left_flank", "category": WORLD_CHUNK_CATEGORY_TRAVERSAL, "ecology": ["open", "melee"]},
				{"id": "right_flank", "category": WORLD_CHUNK_CATEGORY_TRAVERSAL, "ecology": ["open", "ranged"]},
				{"id": "upper_cross", "category": WORLD_CHUNK_CATEGORY_RECOVERY, "ecology": ["open", "ranged"]},
				{"id": "lower_cross", "category": WORLD_CHUNK_CATEGORY_PRESSURE, "ecology": ["pressure", "swarm"]},
				{"id": "bridge_cross", "category": WORLD_CHUNK_CATEGORY_ESCALATION, "ecology": ["pressure", "ranged"]},
				{"id": "climb_cross", "category": WORLD_CHUNK_CATEGORY_TRAVERSAL, "ecology": ["open", "melee"]},
				{"id": "anchor_landmark", "category": WORLD_CHUNK_CATEGORY_CLIMAX, "ecology": ["climax", "elite"]}
			]

func _current_world_chunk_sequence() -> Array[String]:
	if _world_chunk_plan.is_empty():
		return []

	var chunk_ids: Array[String] = []
	for plan_entry: Dictionary in _world_chunk_plan:
		chunk_ids.append(String(plan_entry.get("id", "")))

	return chunk_ids

func _current_world_chunk_category_sequence() -> Array[String]:
	if _world_chunk_plan.is_empty():
		return []

	var chunk_categories: Array[String] = []
	for plan_entry: Dictionary in _world_chunk_plan:
		chunk_categories.append(String(plan_entry.get("category", WORLD_CHUNK_CATEGORY_TRAVERSAL)))

	return chunk_categories

func _current_world_chunk_ecology_counts() -> Dictionary:
	return _current_world_chunk_ecology_counts_for_plan(_world_chunk_plan)

func _current_world_chunk_ecology_counts_for_plan(plan: Array[Dictionary]) -> Dictionary:
	var ecology_counts: Dictionary = {
		WORLD_CHUNK_CATEGORY_RECOVERY: 0,
		WORLD_CHUNK_CATEGORY_TRAVERSAL: 0,
		WORLD_CHUNK_CATEGORY_ESCALATION: 0,
		WORLD_CHUNK_CATEGORY_PRESSURE: 0,
		WORLD_CHUNK_CATEGORY_CLIMAX: 0,
		"open": 0,
		"melee": 0,
		"ranged": 0,
		"swarm": 0,
		"elite": 0
	}

	for plan_entry: Dictionary in plan:
		var chunk_category: String = String(plan_entry.get("category", WORLD_CHUNK_CATEGORY_TRAVERSAL))
		ecology_counts[chunk_category] = int(ecology_counts.get(chunk_category, 0)) + 1

		var chunk_ecology: Array = plan_entry.get("ecology", [])
		for ecology_tag_variant: Variant in chunk_ecology:
			var ecology_tag: String = String(ecology_tag_variant)
			ecology_counts[ecology_tag] = int(ecology_counts.get(ecology_tag, 0)) + 1

	return ecology_counts

func _current_world_chunk_category_summary() -> String:
	return _string_list(_current_world_chunk_category_sequence())

func _current_world_encounter_profile_name() -> String:
	var recovery_count: int = int(_world_chunk_ecology_counts.get(WORLD_CHUNK_CATEGORY_RECOVERY, 0))
	var traversal_count: int = int(_world_chunk_ecology_counts.get(WORLD_CHUNK_CATEGORY_TRAVERSAL, 0))
	var pressure_count: int = int(_world_chunk_ecology_counts.get(WORLD_CHUNK_CATEGORY_PRESSURE, 0))
	var climax_count: int = int(_world_chunk_ecology_counts.get(WORLD_CHUNK_CATEGORY_CLIMAX, 0))
	var melee_count: int = int(_world_chunk_ecology_counts.get("melee", 0))
	var ranged_count: int = int(_world_chunk_ecology_counts.get("ranged", 0))
	var swarm_count: int = int(_world_chunk_ecology_counts.get("swarm", 0))

	if recovery_count >= pressure_count and traversal_count >= pressure_count:
		return WORLD_ENCOUNTER_PROFILE_OPEN

	if pressure_count + climax_count >= recovery_count + 1 and (ranged_count + swarm_count) >= melee_count:
		return WORLD_ENCOUNTER_PROFILE_PRESSURE

	if recovery_count > pressure_count + 1:
		return WORLD_ENCOUNTER_PROFILE_RECOVERY

	return WORLD_ENCOUNTER_PROFILE_MIXED

func _append_world_chunk_rects(level_rects: Array[Rect2i], chunk_id: String) -> void:
	match chunk_id:
		"arrival_core":
			level_rects.append_array(CENTRAL_ZONE_RECTS)
		"left_flank":
			level_rects.append_array(LEFT_ROUTE_RECTS)
			level_rects.append_array(FAR_LEFT_RECTS)
		"right_flank":
			level_rects.append_array(RIGHT_ROUTE_RECTS)
			level_rects.append_array(FAR_RIGHT_RECTS)
		"upper_cross":
			level_rects.append_array(UPPER_ROUTE_RECTS)
			level_rects.append_array(HIGH_RIDGE_RECTS)
		"lower_cross":
			level_rects.append_array(LOWER_ROUTE_RECTS)
			level_rects.append_array(LOW_BASIN_RECTS)
		"bridge_cross":
			level_rects.append_array(BRIDGE_RECTS)
		"climb_cross":
			level_rects.append_array(CLIMB_RECTS)
		"anchor_landmark":
			level_rects.append_array(LANDMARK_RECTS)
		"pressure_landmark":
			level_rects.append_array(LANDMARK_RECTS)
			level_rects.append_array(BRIDGE_RECTS)
		"survival_landmark":
			level_rects.append_array(LANDMARK_RECTS)
			level_rects.append_array(CENTRAL_ZONE_RECTS)
		"vertical_landmark":
			level_rects.append_array(LANDMARK_RECTS)
			level_rects.append_array(CLIMB_RECTS)
			level_rects.append_array(HIGH_RIDGE_RECTS)
		"recovery_landmark":
			level_rects.append_array(LANDMARK_RECTS)
			level_rects.append_array(LOW_BASIN_RECTS)

func _expand_combat_flow_rects(level_rects: Array[Rect2i]) -> Array[Rect2i]:
	var expanded_rects: Array[Rect2i] = []

	for rect: Rect2i in level_rects:
		var expanded_rect: Rect2i = rect

		if rect.size.y <= 2:
			expanded_rect.position.y -= 1
			expanded_rect.size.y += 1

		expanded_rects.append(expanded_rect)

	return expanded_rects

func _current_world_spawn_hook_points() -> Array[Vector2i]:
	match _world_chunk_layout_index:
		WORLD_CHUNK_LAYOUT_LEFT_FORK:
			return [
				Vector2i(10, 20),
				Vector2i(22, 15),
				Vector2i(30, 17),
				Vector2i(34, 11),
				Vector2i(45, 7),
				Vector2i(47, 14),
				Vector2i(18, 15)
			]
		WORLD_CHUNK_LAYOUT_RIGHT_FORK:
			return [
				Vector2i(47, 14),
				Vector2i(60, 17),
				Vector2i(66, 17),
				Vector2i(82, 19),
				Vector2i(90, 23),
				Vector2i(104, 23),
				Vector2i(74, 16)
			]
		WORLD_CHUNK_LAYOUT_HIGHLINE:
			return [
				Vector2i(22, 15),
				Vector2i(42, 11),
				Vector2i(50, 8),
				Vector2i(57, 11),
				Vector2i(66, 13),
				Vector2i(86, 6),
				Vector2i(47, 14)
			]
		WORLD_CHUNK_LAYOUT_RECOVERY:
			return [
				Vector2i(10, 20),
				Vector2i(18, 24),
				Vector2i(36, 25),
				Vector2i(52, 24),
				Vector2i(70, 22),
				Vector2i(108, 24),
				Vector2i(88, 23)
			]
		_:
			return DIRECTOR_SPAWN_POINTS

func _current_world_reward_hook_points() -> Array[Vector2i]:
	match _world_chunk_layout_index:
		WORLD_CHUNK_LAYOUT_LEFT_FORK:
			return [
				Vector2i(2, 5),
				Vector2i(14, 16),
				Vector2i(24, 13),
				Vector2i(47, 4)
			]
		WORLD_CHUNK_LAYOUT_RIGHT_FORK:
			return [
				Vector2i(47, 4),
				Vector2i(80, 16),
				Vector2i(104, 19),
				Vector2i(94, 5)
			]
		WORLD_CHUNK_LAYOUT_HIGHLINE:
			return [
				Vector2i(14, 16),
				Vector2i(47, 4),
				Vector2i(72, 6),
				Vector2i(66, 10)
			]
		WORLD_CHUNK_LAYOUT_RECOVERY:
			return [
				Vector2i(2, 5),
				Vector2i(47, 4),
				Vector2i(92, 25),
				Vector2i(80, 16)
			]
		_:
			return REWARD_HOOK_POINTS

func _current_world_arena_marker_points() -> Array[Vector2i]:
	match _world_chunk_layout_index:
		WORLD_CHUNK_LAYOUT_LEFT_FORK:
			return [
				Vector2i(14, 16),
				Vector2i(23, 19),
				Vector2i(36, 18),
				Vector2i(48, 16)
			]
		WORLD_CHUNK_LAYOUT_RIGHT_FORK:
			return [
				Vector2i(48, 16),
				Vector2i(60, 17),
				Vector2i(76, 18),
				Vector2i(80, 16)
			]
		WORLD_CHUNK_LAYOUT_HIGHLINE:
			return [
				Vector2i(23, 19),
				Vector2i(48, 12),
				Vector2i(72, 6),
				Vector2i(66, 13)
			]
		WORLD_CHUNK_LAYOUT_RECOVERY:
			return [
				Vector2i(23, 19),
				Vector2i(36, 25),
				Vector2i(60, 27),
				Vector2i(52, 24)
			]
		_:
			return ARENA_MARKER_POINTS

func _current_world_melee_spawn_points() -> Array[Vector2i]:
	match _world_chunk_layout_index:
		WORLD_CHUNK_LAYOUT_LEFT_FORK:
			return [
				Vector2i(10, 20),
				Vector2i(18, 15),
				Vector2i(24, 19),
				Vector2i(32, 23),
				Vector2i(38, 18),
				Vector2i(45, 7),
				Vector2i(47, 14)
			]
		WORLD_CHUNK_LAYOUT_RIGHT_FORK:
			return [
				Vector2i(48, 15),
				Vector2i(60, 17),
				Vector2i(66, 20),
				Vector2i(82, 19),
				Vector2i(90, 23),
				Vector2i(104, 23),
				Vector2i(74, 16)
			]
		WORLD_CHUNK_LAYOUT_HIGHLINE:
			return [
				Vector2i(22, 15),
				Vector2i(30, 17),
				Vector2i(42, 11),
				Vector2i(50, 8),
				Vector2i(57, 11),
				Vector2i(72, 6)
			]
		WORLD_CHUNK_LAYOUT_RECOVERY:
			return [
				Vector2i(10, 20),
				Vector2i(18, 24),
				Vector2i(36, 25),
				Vector2i(52, 24),
				Vector2i(70, 22),
				Vector2i(108, 24),
				Vector2i(88, 23)
			]
		_:
			return MELEE_SPAWN_POINTS

func _current_world_mixed_spawn_points() -> Array[Vector2i]:
	match _world_chunk_layout_index:
		WORLD_CHUNK_LAYOUT_LEFT_FORK:
			return [
				Vector2i(22, 15),
				Vector2i(30, 17),
				Vector2i(42, 11),
				Vector2i(47, 14)
			]
		WORLD_CHUNK_LAYOUT_RIGHT_FORK:
			return [
				Vector2i(46, 16),
				Vector2i(52, 16),
				Vector2i(66, 17),
				Vector2i(92, 21),
				Vector2i(74, 16)
			]
		WORLD_CHUNK_LAYOUT_HIGHLINE:
			return [
				Vector2i(22, 15),
				Vector2i(42, 11),
				Vector2i(48, 12),
				Vector2i(64, 7),
				Vector2i(57, 11)
			]
		WORLD_CHUNK_LAYOUT_RECOVERY:
			return [
				Vector2i(22, 15),
				Vector2i(36, 25),
				Vector2i(52, 24),
				Vector2i(76, 26),
				Vector2i(70, 22)
			]
		_:
			return MIXED_SPAWN_POINTS

func _current_world_ranged_spawn_points() -> Array[Vector2i]:
	match _world_chunk_layout_index:
		WORLD_CHUNK_LAYOUT_LEFT_FORK:
			return [
				Vector2i(34, 11),
				Vector2i(42, 11),
				Vector2i(50, 8)
			]
		WORLD_CHUNK_LAYOUT_RIGHT_FORK:
			return [
				Vector2i(50, 8),
				Vector2i(68, 11),
				Vector2i(104, 19),
				Vector2i(76, 20)
			]
		WORLD_CHUNK_LAYOUT_HIGHLINE:
			return [
				Vector2i(34, 11),
				Vector2i(50, 8),
				Vector2i(72, 6),
				Vector2i(66, 13)
			]
		WORLD_CHUNK_LAYOUT_RECOVERY:
			return [
				Vector2i(34, 11),
				Vector2i(50, 8),
				Vector2i(92, 25),
				Vector2i(60, 22)
			]
		_:
			return RANGED_SPAWN_POINTS

func _current_world_route_specs() -> Array[Dictionary]:
	match _world_chunk_layout_index:
		WORLD_CHUNK_LAYOUT_LEFT_FORK:
			return [
				{
					"name": "LeftForkRoute",
					"points": LEFT_FORK_ROUTE_POINTS,
					"color": _biome_route_safe_color,
					"width": 8.5
				},
				{
					"name": "LeftAscentRoute",
					"points": LEFT_ASCENT_ROUTE_POINTS,
					"color": _biome_route_safe_color.lerp(_biome_route_risk_color, 0.22),
					"width": 6.5
				},
				{
					"name": "FarLeftTraverse",
					"points": FAR_LEFT_ROUTE_POINTS,
					"color": _biome_route_recovery_color.lerp(_biome_route_safe_color, 0.18),
					"width": 7.0
				},
				{
					"name": "CrestRoute",
					"points": HIGHLINE_ROUTE_POINTS,
					"color": _biome_route_risk_color,
					"width": 7.0
				},
				{
					"name": "RecoveryRoute",
					"points": RECOVERY_ROUTE_POINTS,
					"color": _biome_route_recovery_color,
					"width": 6.0
				}
			]
		WORLD_CHUNK_LAYOUT_RIGHT_FORK:
			return [
				{
					"name": "RightForkRoute",
					"points": RIGHT_FORK_ROUTE_POINTS,
					"color": _biome_route_safe_color,
					"width": 8.5
				},
				{
					"name": "RightAscentRoute",
					"points": RIGHT_ASCENT_ROUTE_POINTS,
					"color": _biome_route_safe_color.lerp(_biome_route_risk_color, 0.22),
					"width": 6.5
				},
				{
					"name": "FarRightTraverse",
					"points": FAR_RIGHT_ROUTE_POINTS,
					"color": _biome_route_recovery_color.lerp(_biome_route_safe_color, 0.18),
					"width": 7.0
				},
				{
					"name": "DescentRoute",
					"points": SAFE_ROUTE_POINTS,
					"color": _biome_route_risk_color,
					"width": 7.0
				},
				{
					"name": "RecoveryRoute",
					"points": RECOVERY_ROUTE_POINTS,
					"color": _biome_route_recovery_color,
					"width": 6.0
				}
			]
		WORLD_CHUNK_LAYOUT_HIGHLINE:
			return [
				{
					"name": "HighlineRoute",
					"points": HIGHLINE_ROUTE_POINTS,
					"color": _biome_route_safe_color,
					"width": 8.0
				},
				{
					"name": "VerticalRoute",
					"points": HIGHLINE_VERTICAL_ROUTE_POINTS,
					"color": _biome_route_risk_color.lerp(_biome_route_safe_color, 0.16),
					"width": 6.5
				},
				{
					"name": "HighRidgeRoute",
					"points": HIGH_RIDGE_ROUTE_POINTS,
					"color": _biome_route_safe_color.lerp(_biome_route_risk_color, 0.20),
					"width": 7.0
				},
				{
					"name": "RiskRoute",
					"points": RISK_ROUTE_POINTS,
					"color": _biome_route_risk_color,
					"width": 7.5
				},
				{
					"name": "RecoveryRoute",
					"points": RECOVERY_ROUTE_POINTS,
					"color": _biome_route_recovery_color,
					"width": 6.0
				}
			]
		WORLD_CHUNK_LAYOUT_RECOVERY:
			return [
				{
					"name": "RecoveryRoute",
					"points": RECOVERY_ROUTE_POINTS,
					"color": _biome_route_recovery_color,
					"width": 8.0
				},
				{
					"name": "RecoverySpine",
					"points": RECOVERY_ROUTE_POINTS,
					"color": _biome_route_recovery_color.lerp(_biome_route_safe_color, 0.18),
					"width": 6.5
				},
				{
					"name": "LowBasinRoute",
					"points": LOW_BASIN_ROUTE_POINTS,
					"color": _biome_route_recovery_color.lerp(_biome_route_risk_color, 0.22),
					"width": 7.0
				},
				{
					"name": "CrossRoute",
					"points": SAFE_ROUTE_POINTS,
					"color": _biome_route_safe_color,
					"width": 7.0
				},
				{
					"name": "RiskRoute",
					"points": RISK_ROUTE_POINTS,
					"color": _biome_route_risk_color,
					"width": 6.5
				}
			]
		_:
			return [
				{
					"name": "SafeRoute",
					"points": SAFE_ROUTE_POINTS,
					"color": _biome_route_safe_color,
					"width": 8.0
				},
				{
					"name": "RiskRoute",
					"points": RISK_ROUTE_POINTS,
					"color": _biome_route_risk_color,
					"width": 7.0
				},
				{
					"name": "RecoveryRoute",
					"points": RECOVERY_ROUTE_POINTS,
					"color": _biome_route_recovery_color,
					"width": 6.0
				}
			]

func get_world_chunk_layout_name() -> String:
	return _world_chunk_layout_name

func get_world_chunk_pool_name() -> String:
	return _world_chunk_pool_name

func get_world_encounter_profile_name() -> String:
	return _world_encounter_profile_name

func get_meta_discovery_points() -> int:
	return _meta_discovery_points

func get_world_challenge_variant_name() -> String:
	return _current_challenge_variant_name

func get_world_landmark_name() -> String:
	return _current_world_landmark_name()

func get_world_chunk_sequence_label() -> String:
	return _string_list(_world_chunk_sequence)

func get_world_chunk_category_sequence_label() -> String:
	return _current_world_chunk_category_summary()

func get_world_chunk_category_counts() -> Dictionary:
	var category_counts: Dictionary = {
		WORLD_CHUNK_CATEGORY_RECOVERY: 0,
		WORLD_CHUNK_CATEGORY_TRAVERSAL: 0,
		WORLD_CHUNK_CATEGORY_ESCALATION: 0,
		WORLD_CHUNK_CATEGORY_PRESSURE: 0,
		WORLD_CHUNK_CATEGORY_CLIMAX: 0
	}

	for chunk_category: String in _world_chunk_category_sequence:
		category_counts[chunk_category] = int(category_counts.get(chunk_category, 0)) + 1

	return category_counts

func get_world_chunk_ecology_counts() -> Dictionary:
	return _world_chunk_ecology_counts.duplicate()

func _string_list(items: Array[String]) -> String:
	if items.is_empty():
		return "none"

	var text: String = ""
	for index: int in range(items.size()):
		if index > 0:
			text += " -> "
		text += items[index]

	return text

func _current_world_landmark_name() -> String:
	match _world_chunk_layout_index:
		WORLD_CHUNK_LAYOUT_LEFT_FORK:
			return "pressure_landmark"
		WORLD_CHUNK_LAYOUT_RIGHT_FORK:
			return "survival_landmark"
		WORLD_CHUNK_LAYOUT_HIGHLINE:
			return "vertical_landmark"
		WORLD_CHUNK_LAYOUT_RECOVERY:
			return "recovery_landmark"
		_:
			return "anchor_landmark"

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

	camera.zoom = Vector2(0.92, 0.92)
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
	if director.has_method("configure_challenge_variant"):
		director.call("configure_challenge_variant", _current_challenge_variant_name)
	if director.has_method("configure_world_chunk_profile"):
		director.call(
			"configure_world_chunk_profile",
			_world_chunk_pool_name,
			_world_encounter_profile_name,
			_world_chunk_category_sequence,
			_world_chunk_ecology_counts
		)
	_enemy_director = director

# ============================================================================
# AUDIO
# ============================================================================

func _setup_audio_feedback() -> void:
	_audio_atmosphere_player = _create_audio_player("AtmosphereAudio", AUDIO_ATMOSPHERE_VOLUME_DB)
	_audio_combat_player = _create_audio_player("CombatAudio", AUDIO_COMBAT_VOLUME_DB)
	_audio_movement_player = _create_audio_player("MovementAudio", AUDIO_MOVEMENT_VOLUME_DB)
	_audio_status_player = _create_audio_player("StatusAudio", AUDIO_STATUS_VOLUME_DB)
	_audio_atmosphere_phase = 0.0
	_audio_atmosphere_pulse_phase = 0.0

func _create_audio_player(player_name: String, volume_db: float) -> AudioStreamPlayer:
	var audio_player: AudioStreamPlayer = AudioStreamPlayer.new()
	audio_player.name = player_name
	audio_player.volume_db = volume_db

	var generator: AudioStreamGenerator = AudioStreamGenerator.new()
	generator.mix_rate = AUDIO_MIX_RATE
	generator.buffer_length = AUDIO_BUFFER_LENGTH
	audio_player.stream = generator

	add_child(audio_player)
	audio_player.play()
	return audio_player

func play_world_audio_cue(cue_name: String, intensity: float = 1.0) -> void:
	var cue_intensity: float = clamp(intensity, 0.35, 1.8)
	match cue_name:
		"player_fire":
			_play_audio_cue(_audio_combat_player, 540.0, 0.07, AUDIO_COMBAT_VOLUME_DB, cue_intensity, 0.18)
		"player_jump":
			_play_audio_cue(_audio_movement_player, 400.0, 0.08, AUDIO_MOVEMENT_VOLUME_DB, cue_intensity, 0.16)
		"player_land":
			_play_audio_cue(_audio_movement_player, 180.0, 0.09, AUDIO_MOVEMENT_VOLUME_DB, cue_intensity, 0.10)
		"player_hurt":
			_play_audio_cue(_audio_combat_player, 140.0, 0.10, AUDIO_COMBAT_VOLUME_DB - 2.0, cue_intensity, 0.24)
		"enemy_windup":
			_play_audio_cue(_audio_combat_player, 260.0, 0.09, AUDIO_COMBAT_VOLUME_DB, cue_intensity, 0.22)
		"ranged_windup":
			_play_audio_cue(_audio_combat_player, 320.0, 0.09, AUDIO_COMBAT_VOLUME_DB, cue_intensity, 0.18)
		"swarm_windup":
			_play_audio_cue(_audio_combat_player, 220.0, 0.08, AUDIO_COMBAT_VOLUME_DB, cue_intensity, 0.20)
		"boss_windup":
			_play_audio_cue(_audio_combat_player, 170.0, 0.13, AUDIO_COMBAT_VOLUME_DB + 1.0, cue_intensity, 0.26)
		"boss_phase":
			_play_audio_cue(_audio_status_player, 330.0, 0.11, AUDIO_STATUS_VOLUME_DB, cue_intensity, 0.22)
		"level_up":
			_play_audio_cue(_audio_status_player, 660.0, 0.12, AUDIO_STATUS_VOLUME_DB, cue_intensity, 0.24)
		"stage_reward":
			_play_audio_cue(_audio_status_player, 520.0, 0.12, AUDIO_REWARD_VOLUME_DB, cue_intensity, 0.20)
		"boss_reward":
			_play_audio_cue(_audio_status_player, 620.0, 0.14, AUDIO_REWARD_VOLUME_DB, cue_intensity, 0.22)
		_:
			pass

func _play_audio_cue(audio_player: AudioStreamPlayer, frequency: float, duration: float, volume_db: float, intensity: float, harmonic_mix: float) -> void:
	if audio_player == null:
		return

	var generator: AudioStreamGenerator = audio_player.stream as AudioStreamGenerator
	if generator == null:
		return

	var playback: AudioStreamGeneratorPlayback = audio_player.get_stream_playback() as AudioStreamGeneratorPlayback
	if playback == null:
		audio_player.play()
		playback = audio_player.get_stream_playback() as AudioStreamGeneratorPlayback
		if playback == null:
			return

	playback.clear_buffer()
	audio_player.volume_db = volume_db
	if not audio_player.playing:
		audio_player.play()

	var sample_rate: float = max(generator.mix_rate, 11025.0)
	var frame_count: int = min(int(ceil(duration * sample_rate)), playback.get_frames_available())
	if frame_count <= 0:
		return

	var amplitude: float = pow(10.0, volume_db / 20.0) * intensity
	var phase: float = 0.0
	var phase_step: float = frequency / sample_rate
	var attack_frames: int = max(1, int(float(frame_count) * 0.12))
	var release_frames: int = max(1, int(float(frame_count) * 0.20))
	for frame_index: int in range(frame_count):
		var attack_strength: float = min(1.0, float(frame_index) / float(attack_frames))
		var release_strength: float = min(1.0, float(frame_count - frame_index) / float(release_frames))
		var envelope: float = min(attack_strength, release_strength)
		var primary_wave: float = sin(phase * TAU)
		var harmonic_wave: float = sin(phase * TAU * 2.0)
		var sample: float = (primary_wave * (1.0 - harmonic_mix) + harmonic_wave * harmonic_mix * 0.5) * envelope * amplitude
		playback.push_frame(Vector2(sample, sample))
		phase = fmod(phase + phase_step, 1.0)

func _update_survival_audio(_delta: float) -> void:
	_fill_atmosphere_audio_buffer()

func _fill_atmosphere_audio_buffer() -> void:
	if _audio_atmosphere_player == null:
		return

	var generator: AudioStreamGenerator = _audio_atmosphere_player.stream as AudioStreamGenerator
	if generator == null:
		return

	var playback: AudioStreamGeneratorPlayback = _audio_atmosphere_player.get_stream_playback() as AudioStreamGeneratorPlayback
	if playback == null:
		return

	var frames_available: int = playback.get_frames_available()
	if frames_available <= 0:
		return

	var pacing_state: String = "recovery"
	var boss_state: String = "none"
	var boss_survival_state: String = "none"
	if _enemy_director != null and is_instance_valid(_enemy_director):
		if _enemy_director.has_method("get_pacing_state"):
			pacing_state = String(_enemy_director.call("get_pacing_state"))
		if _enemy_director.has_method("get_boss_encounter_state"):
			boss_state = String(_enemy_director.call("get_boss_encounter_state"))
		if _enemy_director.has_method("get_boss_survival_state"):
			boss_survival_state = String(_enemy_director.call("get_boss_survival_state"))

	var base_frequency: float = _current_ambient_frequency()
	var variant_frequency_bonus: float = _current_variant_audio_frequency_bonus()
	var intensity_boost: float = _current_ambient_intensity(pacing_state, boss_state, boss_survival_state)
	var sample_rate: float = max(generator.mix_rate, 11025.0)
	var phase_step: float = max(base_frequency + variant_frequency_bonus, 18.0) / sample_rate
	var pulse_step: float = _current_ambient_pulse_frequency(pacing_state) / sample_rate
	var amplitude: float = pow(10.0, AUDIO_ATMOSPHERE_VOLUME_DB / 20.0) * intensity_boost
	var phase_mix: float = _current_ambient_harmonic_mix(pacing_state, boss_state)

	for frame_index: int in range(frames_available):
		var pulse_strength: float = 0.5 + 0.5 * sin(_audio_atmosphere_pulse_phase * TAU)
		var carrier_wave: float = sin(_audio_atmosphere_phase * TAU)
		var harmonic_wave: float = sin(_audio_atmosphere_phase * TAU * 2.0)
		var stereo_offset: float = 0.012 if _current_challenge_variant_name == CHALLENGE_VARIANT_TRAVERSAL else 0.0
		var sample: float = (carrier_wave * (1.0 - phase_mix) + harmonic_wave * phase_mix * 0.45) * pulse_strength * amplitude
		playback.push_frame(Vector2(sample * (1.0 - stereo_offset), sample * (1.0 + stereo_offset)))
		_audio_atmosphere_phase = fmod(_audio_atmosphere_phase + phase_step, 1.0)
		_audio_atmosphere_pulse_phase = fmod(_audio_atmosphere_pulse_phase + pulse_step, 1.0)

func _current_ambient_frequency() -> float:
	match _current_biome_stage:
		"mid":
			return 68.0
		"late":
			return 78.0
		"endless":
			return 74.0
		_:
			return 58.0

func _current_variant_audio_frequency_bonus() -> float:
	match _current_challenge_variant_name:
		CHALLENGE_VARIANT_SURGE:
			return 8.0
		CHALLENGE_VARIANT_ENDURANCE:
			return -5.0
		CHALLENGE_VARIANT_TRAVERSAL:
			return 4.0
		CHALLENGE_VARIANT_ECOLOGY:
			return 5.0
		_:
			return 0.0

func _current_ambient_pulse_frequency(pacing_state: String) -> float:
	match pacing_state:
		"pressure":
			return 2.8
		"climax":
			return 3.8
		"build":
			return 2.0
		_:
			return 1.4

func _current_ambient_harmonic_mix(pacing_state: String, boss_state: String) -> float:
	var harmonic_mix: float = 0.12
	match _current_biome_stage:
		"late":
			harmonic_mix += 0.04
		"endless":
			harmonic_mix += 0.05
		_:
			pass

	match pacing_state:
		"pressure":
			harmonic_mix += 0.04
		"climax":
			harmonic_mix += 0.06
		_:
			pass

	if boss_state != "none":
		harmonic_mix += 0.08

	return clamp(harmonic_mix, 0.08, 0.32)

func _current_ambient_intensity(pacing_state: String, boss_state: String, boss_survival_state: String) -> float:
	var intensity: float = 0.55
	match _current_biome_stage:
		"mid":
			intensity += 0.06
		"late":
			intensity += 0.11
		"endless":
			intensity += 0.13
		_:
			pass

	match _current_challenge_variant_name:
		CHALLENGE_VARIANT_SURGE:
			intensity += 0.08
		CHALLENGE_VARIANT_ENDURANCE:
			intensity -= 0.04
		CHALLENGE_VARIANT_ECOLOGY:
			intensity += 0.03
		_:
			pass

	match pacing_state:
		"pressure":
			intensity += 0.08
		"climax":
			intensity += 0.14
		_:
			pass

	if boss_state != "none":
		intensity += 0.11

	if boss_survival_state == "climax":
		intensity += 0.06

	return clamp(intensity, 0.36, 0.96)

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
	var loop_state: String = "none"
	var loop_index: int = 0
	var loop_progress: float = 0.0
	var finale_state: String = "none"
	var boss_state: String = "none"
	var boss_role: String = "none"
	var boss_phase: int = 0
	var boss_survival_state: String = "none"
	var player_build_identity: String = "none"
	var player_build_archetype: String = "none"
	var player_meta_discovery_points: int = 0
	var player_mastery_goal_count: int = 0
	var challenge_variant: String = _current_challenge_variant_name
	var chunk_categories: String = "none"
	var chunk_pool: String = _world_chunk_pool_name
	var encounter_profile: String = _world_encounter_profile_name
	var landmark_name: String = "none"
	var validation_state: String = "stable"
	if _enemy_director != null and is_instance_valid(_enemy_director):
		if _enemy_director.has_method("get_pacing_state"):
			pacing_state = String(_enemy_director.call("get_pacing_state"))
		if _enemy_director.has_method("get_encounter_composition"):
			encounter_state = String(_enemy_director.call("get_encounter_composition"))
		if _enemy_director.has_method("get_run_loop_state"):
			loop_state = String(_enemy_director.call("get_run_loop_state"))
		if _enemy_director.has_method("get_run_loop_index"):
			loop_index = int(_enemy_director.call("get_run_loop_index"))
		if _enemy_director.has_method("get_run_loop_progress"):
			loop_progress = float(_enemy_director.call("get_run_loop_progress"))
		if _enemy_director.has_method("get_stage_finale_state"):
			finale_state = String(_enemy_director.call("get_stage_finale_state"))
		if _enemy_director.has_method("get_boss_encounter_state"):
			boss_state = String(_enemy_director.call("get_boss_encounter_state"))
		if _enemy_director.has_method("get_boss_encounter_role"):
			boss_role = String(_enemy_director.call("get_boss_encounter_role"))
		if _enemy_director.has_method("get_boss_encounter_phase"):
			boss_phase = int(_enemy_director.call("get_boss_encounter_phase"))
		if _enemy_director.has_method("get_boss_survival_state"):
			boss_survival_state = String(_enemy_director.call("get_boss_survival_state"))

	var player_node: Node = get_tree().get_first_node_in_group("player")
	if player_node != null:
		if player_node.has_method("get_build_identity"):
			player_build_identity = String(player_node.call("get_build_identity"))
		if player_node.has_method("get_build_archetype_label"):
			player_build_archetype = String(player_node.call("get_build_archetype_label"))
		if player_node.has_method("get_meta_discovery_points"):
			player_meta_discovery_points = int(player_node.call("get_meta_discovery_points"))
		if player_node.has_method("get_mastery_goal_count"):
			player_mastery_goal_count = int(player_node.call("get_mastery_goal_count"))

	chunk_categories = _current_world_chunk_category_summary()
	landmark_name = get_world_landmark_name()
	if not _current_world_chunk_plan_is_stable(_world_chunk_plan):
		validation_state = "fallback"

	print("Level rects: %s | spawn hooks: %s | reward hooks: %s | biome: %s" % [
		_all_level_rects().size(),
		director_spawns_root.get_child_count(),
		reward_hooks_root.get_child_count(),
		_current_biome_stage
	])
	print("Arena pressure | pacing: %s | encounter: %s | loop: %s #%d (%.2f) | finale: %s | boss: %s (%s p%d %s) | player: %s / %s | meta: %d | mastery: %d | variant: %s | landmark: %s | validation: %s | layout: %s | pool: %s" % [
		pacing_state,
		encounter_state,
		loop_state,
		loop_index,
		loop_progress,
		finale_state,
		boss_state,
		boss_role,
		boss_phase,
		boss_survival_state,
		player_build_identity,
		player_build_archetype,
		player_meta_discovery_points,
		player_mastery_goal_count,
		challenge_variant,
		landmark_name,
		validation_state,
		_world_chunk_layout_name,
		chunk_pool
	])
	print("Chunk sequence: %s" % _string_list(_world_chunk_sequence))
	print("Chunk categories: %s" % chunk_categories)
	print("Encounter profile: %s" % encounter_profile)
