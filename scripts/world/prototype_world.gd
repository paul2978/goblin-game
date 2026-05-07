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
	Rect2i(40, 18, 16, 2),
	Rect2i(45, 16, 6, 2)
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
	Rect2i(46, 5, 5, 1)
]

const CLIMB_RECTS: Array[Rect2i] = [
	Rect2i(34, 20, 2, 4),
	Rect2i(60, 20, 2, 4)
]

const LANDMARK_RECTS: Array[Rect2i] = [
	Rect2i(14, 16, 2, 4),
	Rect2i(48, 12, 2, 6),
	Rect2i(80, 16, 2, 4)
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
@onready var left_limit: Marker2D = $CameraBounds/LeftLimit
@onready var top_limit: Marker2D = $CameraBounds/TopLimit
@onready var right_limit: Marker2D = $CameraBounds/RightLimit
@onready var bottom_limit: Marker2D = $CameraBounds/BottomLimit

func _ready() -> void:
	_setup_tile_map()
	_clear_tile_map()
	_update_world_bounds()
	_position_player_spawn()
	_create_spawn_hooks()
	_create_reward_hooks()
	_build_level_geometry()
	_setup_background()
	_setup_player()
	_setup_enemy_director()

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

func _clear_children(parent: Node) -> void:
	for child: Node in parent.get_children():
		child.queue_free()

func _build_level_geometry() -> void:
	_clear_children(collision_root)
	_paint_level_rects(_all_level_rects())
	_create_level_colliders(_all_level_rects())

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
	image.fill(GROUND_COLOR)

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
	canvas_modulate.color = Color(0.82, 0.85, 0.90, 1.0)
	_rebuild_layer_children(sky_layer)
	_rebuild_layer_children(far_layer)
	_rebuild_layer_children(mid_layer)
	_rebuild_layer_children(fog_layer)
	_rebuild_layer_children(foreground_layer)
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

	gradient.colors = PackedColorArray([SKY_COLOR_TOP, SKY_COLOR_BOTTOM])
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
		FAR_RUINS_COLOR,
		[
			Vector2(0, 600), Vector2(180, 520), Vector2(360, 560), Vector2(540, 430),
			Vector2(720, 500), Vector2(980, 340), Vector2(1220, 430), Vector2(1500, 300),
			Vector2(1780, 430), Vector2(2060, 310), Vector2(2360, 400), Vector2(2700, 290),
			Vector2(3072, 360), Vector2(3072, 960), Vector2(0, 960)
		]
	)
	_add_ruin_shape(
		far_layer,
		Color(FAR_RUINS_COLOR.r, FAR_RUINS_COLOR.g, FAR_RUINS_COLOR.b, 0.75),
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
		MID_RUINS_COLOR,
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
	high_fog.color = FOG_COLOR
	fog_layer.add_child(high_fog)

	low_fog.position = Vector2(0, 520)
	low_fog.size = Vector2(WORLD_WIDTH_TILES * TILE_SIZE, 210)
	low_fog.color = Color(FOG_COLOR.r, FOG_COLOR.g, FOG_COLOR.b, 0.30)
	fog_layer.add_child(low_fog)

func _add_foreground_landmarks() -> void:
	_add_ruin_shape(
		foreground_layer,
		FOREGROUND_RUIN_COLOR,
		[
			Vector2(90, 960), Vector2(90, 520), Vector2(170, 520), Vector2(170, 960)
		]
	)
	_add_ruin_shape(
		foreground_layer,
		FOREGROUND_RUIN_COLOR,
		[
			Vector2(1510, 960), Vector2(1510, 360), Vector2(1600, 360), Vector2(1600, 960)
		]
	)
	_add_ruin_shape(
		foreground_layer,
		FOREGROUND_RUIN_COLOR,
		[
			Vector2(2890, 960), Vector2(2890, 470), Vector2(2990, 470), Vector2(2990, 960)
		]
	)
	_add_ruin_shape(
		foreground_layer,
		Color(FOREGROUND_RUIN_COLOR.r, FOREGROUND_RUIN_COLOR.g, FOREGROUND_RUIN_COLOR.b, 0.55),
		[
			Vector2(0, 900), Vector2(400, 820), Vector2(780, 870), Vector2(1180, 780),
			Vector2(1560, 860), Vector2(1920, 790), Vector2(2320, 870), Vector2(2700, 800),
			Vector2(3072, 860), Vector2(3072, 960), Vector2(0, 960)
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
	director.setup($Gameplay, enemy_spawns_root, enemy_scene)

# ============================================================================
# DEBUG
# ============================================================================

func _unhandled_input(event: InputEvent) -> void:
	if event is not InputEventKey:
		return

	var key_event: InputEventKey = event
	if not key_event.pressed or key_event.keycode != KEY_F3:
		return

	print("Level rects: %s | spawn hooks: %s | reward hooks: %s" % [
		_all_level_rects().size(),
		director_spawns_root.get_child_count(),
		reward_hooks_root.get_child_count()
	])
