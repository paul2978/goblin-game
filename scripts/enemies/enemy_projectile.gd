extends Area2D
class_name EnemyProjectile

# ============================================================================
# CONSTANTS
# ============================================================================

const PROJECTILE_SIZE: Vector2 = Vector2(20.0, 10.0)
const PROJECTILE_COLOR: Color = Color(0.52, 0.82, 1.0, 1.0)
const PROJECTILE_HEAD_COLOR: Color = Color(0.90, 0.98, 1.0, 1.0)
const PROJECTILE_TAIL_COLOR: Color = Color(0.24, 0.48, 0.74, 1.0)
const SPAWN_FLASH_TIME: float = 0.07
const HIT_COLOR: Color = Color(1.0, 1.0, 1.0, 1.0)
const HIT_CONFIRM_TIME: float = 0.05

# ============================================================================
# EXPORTED VARIABLES
# ============================================================================

@export var speed: float = 320.0
@export var lifetime: float = 2.0
@export var damage: int = 6

# ============================================================================
# NODE REFERENCES
# ============================================================================

@onready var _sprite: Sprite2D = _get_or_create_sprite()
@onready var _collision_shape: CollisionShape2D = _get_or_create_collision_shape()

# ============================================================================
# RUNTIME VARIABLES
# ============================================================================

var _direction: Vector2 = Vector2.RIGHT
var _lifetime_timer: float = 0.0
var _spawn_flash_timer: float = 0.0
var _hit_confirm_timer: float = 0.0
var _has_hit: bool = false

# ============================================================================
# GODOT LIFECYCLE
# ============================================================================

func _ready() -> void:
	_lifetime_timer = lifetime
	_spawn_flash_timer = SPAWN_FLASH_TIME
	body_entered.connect(_on_body_entered)
	_update_visuals()

func _physics_process(delta: float) -> void:
	if _has_hit:
		_update_hit_confirm(delta)
		return

	_move_projectile(delta)
	_update_lifetime(delta)
	_update_spawn_flash(delta)

# ============================================================================
# PROJECTILES
# ============================================================================

func setup_projectile(start_position: Vector2, target_position: Vector2) -> void:
	global_position = start_position

	var direction_vector: Vector2 = target_position - start_position
	if direction_vector.length_squared() <= 0.001:
		direction_vector = Vector2.RIGHT

	_direction = direction_vector.normalized()
	rotation = _direction.angle()

func _move_projectile(delta: float) -> void:
	var movement: Vector2 = _direction * speed * delta
	global_position += movement

func _update_lifetime(delta: float) -> void:
	_lifetime_timer = max(_lifetime_timer - delta, 0.0)
	if _lifetime_timer <= 0.0:
		queue_free()

func _update_spawn_flash(delta: float) -> void:
	_spawn_flash_timer = max(_spawn_flash_timer - delta, 0.0)
	_update_visuals()

# ============================================================================
# COMBAT
# ============================================================================

func _on_body_entered(body: Node) -> void:
	if _has_hit:
		return

	if body.is_in_group("player") and body.has_method("apply_contact_damage"):
		body.apply_contact_damage(damage, global_position)

	_start_hit_confirm()

func _start_hit_confirm() -> void:
	_has_hit = true
	_hit_confirm_timer = HIT_CONFIRM_TIME
	_collision_shape.disabled = true
	_update_visuals()

func _update_hit_confirm(delta: float) -> void:
	_hit_confirm_timer = max(_hit_confirm_timer - delta, 0.0)
	if _hit_confirm_timer <= 0.0:
		queue_free()

# ============================================================================
# VISUALS
# ============================================================================

func _update_visuals() -> void:
	if _has_hit:
		_sprite.self_modulate = HIT_COLOR
		_sprite.scale = Vector2(1.2, 0.95)
		return

	var flash_strength: float = 0.0
	if _spawn_flash_timer > 0.0:
		flash_strength = _spawn_flash_timer / SPAWN_FLASH_TIME

	var visual_color: Color = PROJECTILE_COLOR
	var scale_multiplier: float = 1.0
	if flash_strength > 0.0:
		visual_color = PROJECTILE_COLOR.lerp(PROJECTILE_HEAD_COLOR, flash_strength)
		scale_multiplier = lerp(1.0, 1.18, flash_strength)

	_sprite.self_modulate = visual_color
	_sprite.scale = Vector2(scale_multiplier, 1.0 - (scale_multiplier - 1.0) * 0.35)

func _get_or_create_sprite() -> Sprite2D:
	var existing_sprite: Sprite2D = get_node_or_null("Sprite2D") as Sprite2D
	if existing_sprite != null:
		return existing_sprite

	var sprite: Sprite2D = Sprite2D.new()
	sprite.name = "Sprite2D"
	sprite.texture = _create_projectile_texture()
	add_child(sprite)
	return sprite

func _get_or_create_collision_shape() -> CollisionShape2D:
	var existing_shape: CollisionShape2D = get_node_or_null("CollisionShape2D") as CollisionShape2D
	if existing_shape != null:
		return existing_shape

	var collision_shape: CollisionShape2D = CollisionShape2D.new()
	var shape: RectangleShape2D = RectangleShape2D.new()
	shape.size = PROJECTILE_SIZE
	collision_shape.name = "CollisionShape2D"
	collision_shape.shape = shape
	add_child(collision_shape)
	return collision_shape

func _create_projectile_texture() -> Texture2D:
	var image: Image = Image.create(int(PROJECTILE_SIZE.x), int(PROJECTILE_SIZE.y), false, Image.FORMAT_RGBA8)
	image.fill(Color(0.0, 0.0, 0.0, 0.0))

	var width: int = int(PROJECTILE_SIZE.x)
	var height: int = int(PROJECTILE_SIZE.y)
	var center_y: int = height / 2
	for x: int in range(width):
		var x_ratio: float = float(x) / float(max(width - 1, 1))
		var band_half_height: int = 1
		if x_ratio > 0.22:
			band_half_height = 2
		if x_ratio > 0.60:
			band_half_height = 3

		var column_color: Color = PROJECTILE_TAIL_COLOR.lerp(PROJECTILE_HEAD_COLOR, x_ratio)
		if x_ratio > 0.70:
			column_color = PROJECTILE_COLOR.lerp(PROJECTILE_HEAD_COLOR, (x_ratio - 0.70) / 0.30)

		for y: int in range(center_y - band_half_height, center_y + band_half_height + 1):
			if y < 0 or y >= height:
				continue

			image.set_pixel(x, y, column_color)

	return ImageTexture.create_from_image(image)

# ============================================================================
# DEBUG
# ============================================================================
