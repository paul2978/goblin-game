extends Area2D
class_name Projectile

# ============================================================================
# CONSTANTS
# ============================================================================

const PROJECTILE_SIZE: Vector2 = Vector2(16.0, 6.0)
const HIT_CONFIRM_TIME: float = 0.06
const PROJECTILE_COLOR: Color = Color(1.0, 0.86, 0.32, 1.0)
const HIT_CONFIRM_COLOR: Color = Color(1.0, 1.0, 1.0, 1.0)

# ============================================================================
# EXPORTED VARIABLES
# ============================================================================

@export var speed: float = 840.0
@export var lifetime: float = 1.1
@export var damage: int = 1
@export var knockback_force: float = 140.0

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
var _hit_confirm_timer: float = 0.0
var _has_hit: bool = false

# ============================================================================
# GODOT LIFECYCLE
# ============================================================================

func _ready() -> void:
	_lifetime_timer = lifetime
	body_entered.connect(_on_body_entered)
	_update_visuals()

func _physics_process(delta: float) -> void:
	if _has_hit:
		_update_hit_confirm(delta)
		return

	_move_projectile(delta)
	_update_lifetime(delta)

# ============================================================================
# MOVEMENT
# ============================================================================

func setup_projectile(start_position: Vector2, facing_direction: float) -> void:
	global_position = start_position
	_direction = Vector2(sign(facing_direction), 0.0)
	if is_zero_approx(_direction.x):
		_direction = Vector2.RIGHT

	rotation = _direction.angle()

func _move_projectile(delta: float) -> void:
	var velocity: Vector2 = _direction * speed
	global_position += velocity * delta

func _update_lifetime(delta: float) -> void:
	_lifetime_timer = max(_lifetime_timer - delta, 0.0)
	if _lifetime_timer <= 0.0:
		queue_free()

# ============================================================================
# COMBAT
# ============================================================================

func _on_body_entered(body: Node) -> void:
	if _has_hit:
		return

	if body.is_in_group("player"):
		return

	if body.is_in_group("enemy") and body.has_method("take_projectile_hit"):
		body.take_projectile_hit(damage, _direction * knockback_force)
	
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
		_sprite.self_modulate = HIT_CONFIRM_COLOR
		_sprite.scale = Vector2(1.4, 1.1)
		return

	_sprite.self_modulate = PROJECTILE_COLOR
	_sprite.scale = Vector2(1.0, 1.0)

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
	image.fill(PROJECTILE_COLOR)
	return ImageTexture.create_from_image(image)

# ============================================================================
# DEBUG
# ============================================================================
