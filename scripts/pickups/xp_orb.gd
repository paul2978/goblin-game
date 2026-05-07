extends Area2D

# ============================================================================
# CONSTANTS
# ============================================================================

const ORB_TEXTURE_SIZE: int = 18
const ORB_BASE_COLOR: Color = Color(0.40, 0.96, 1.0, 1.0)
const ORB_PULSE_COLOR: Color = Color(0.85, 1.0, 1.0, 1.0)
const ORB_COLLECT_COLOR: Color = Color(1.0, 1.0, 1.0, 1.0)

# ============================================================================
# EXPORTED VARIABLES
# ============================================================================

@export var xp_value: int = 4
@export var float_height: float = 5.0
@export var float_speed: float = 4.0
@export var attraction_radius: float = 140.0
@export var attract_speed: float = 230.0

# ============================================================================
# NODE REFERENCES
# ============================================================================

@onready var _sprite: Sprite2D = $Sprite2D
@onready var _collision_shape: CollisionShape2D = $CollisionShape2D

# ============================================================================
# RUNTIME VARIABLES
# ============================================================================

var _player: Node2D = null
var _float_timer: float = 0.0
var _is_collected: bool = false

# ============================================================================
# GODOT LIFECYCLE
# ============================================================================

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_ensure_orb_texture()
	_update_visuals()

func _physics_process(delta: float) -> void:
	if _is_collected:
		return

	_refresh_player_reference()
	_update_float_motion(delta)
	_update_collection_motion(delta)
	_update_visuals()

# ============================================================================
# XP
# ============================================================================

func setup_orb(spawn_position: Vector2, xp_amount: int) -> void:
	global_position = spawn_position
	xp_value = xp_amount

# ============================================================================
# COLLECTION
# ============================================================================

func _refresh_player_reference() -> void:
	if is_instance_valid(_player):
		return

	_player = get_tree().get_first_node_in_group("player") as Node2D

func _update_float_motion(delta: float) -> void:
	_float_timer += delta * float_speed

	var float_offset_y: float = sin(_float_timer) * float_height
	_sprite.position.y = float_offset_y

func _update_collection_motion(delta: float) -> void:
	if _player == null:
		return

	var direction_to_player: Vector2 = _player.global_position - global_position
	var distance_to_player: float = direction_to_player.length()
	if distance_to_player > attraction_radius:
		return

	var current_speed: float = attract_speed

	if distance_to_player <= 0.001:
		return

	var move_direction: Vector2 = direction_to_player / distance_to_player
	global_position += move_direction * current_speed * delta

func _on_body_entered(body: Node) -> void:
	if _is_collected:
		return

	if not body.is_in_group("player"):
		return

	if body.has_method("collect_xp_orb"):
		body.collect_xp_orb(xp_value)

	_is_collected = true
	_collision_shape.disabled = true
	_sprite.self_modulate = ORB_COLLECT_COLOR
	queue_free()

# ============================================================================
# VISUALS
# ============================================================================

func _update_visuals() -> void:
	if _is_collected:
		_sprite.self_modulate = ORB_COLLECT_COLOR
		return

	var pulse_alpha: float = 0.5 + 0.5 * sin(_float_timer * 1.5)
	_sprite.self_modulate = ORB_BASE_COLOR.lerp(ORB_PULSE_COLOR, pulse_alpha)
	_sprite.scale = Vector2(1.0, 1.0) + Vector2.ONE * pulse_alpha * 0.08

func _ensure_orb_texture() -> void:
	if _sprite.texture != null:
		return

	_sprite.texture = _create_orb_texture()

func _create_orb_texture() -> Texture2D:
	var image: Image = Image.create(ORB_TEXTURE_SIZE, ORB_TEXTURE_SIZE, false, Image.FORMAT_RGBA8)
	var center: Vector2 = Vector2(ORB_TEXTURE_SIZE * 0.5, ORB_TEXTURE_SIZE * 0.5)
	var radius: float = ORB_TEXTURE_SIZE * 0.5

	for y: int in range(ORB_TEXTURE_SIZE):
		for x: int in range(ORB_TEXTURE_SIZE):
			var pixel_position: Vector2 = Vector2(float(x) + 0.5, float(y) + 0.5)
			var distance_to_center: float = pixel_position.distance_to(center)
			var normalized_distance: float = clamp(distance_to_center / radius, 0.0, 1.0)
			var alpha: float = 1.0 - normalized_distance

			if alpha <= 0.0:
				image.set_pixel(x, y, Color(1.0, 1.0, 1.0, 0.0))
				continue

			var pixel_color: Color = Color(1.0, 1.0, 1.0, alpha)
			image.set_pixel(x, y, pixel_color)

	return ImageTexture.create_from_image(image)

# ============================================================================
# DEBUG
# ============================================================================
