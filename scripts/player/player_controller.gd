extends CharacterBody2D

################################################################################
# EXPORTED TUNING
################################################################################

@export var move_speed: float = 220.0
@export var sprint_speed: float = 320.0
@export var acceleration: float = 1400.0
@export var friction: float = 1800.0
@export var jump_velocity: float = -420.0
@export var gravity: float = 1200.0
@export var max_health: int = 100

################################################################################
# PLATFORMING ASSISTS
################################################################################

const COYOTE_TIME_SECONDS: float = 0.12
const JUMP_BUFFER_SECONDS: float = 0.12
const JUMP_CUT_MULTIPLIER: float = 0.5

################################################################################
# INPUT SETUP
################################################################################

const INPUT_ACTIONS: Dictionary = {
	&"move_left": [KEY_A],
	&"move_right": [KEY_D],
	&"jump": [KEY_SPACE],
	&"sprint": [KEY_SHIFT]
}

################################################################################
# RUNTIME STATE
################################################################################

var _coyote_timer: float = 0.0
var _jump_buffer_timer: float = 0.0
var _jump_was_released: bool = false
var _health: int = 0
var _hurt_flash_timer: float = 0.0

@onready var _sprite: Sprite2D = $Sprite2D

################################################################################
# LIFECYCLE
################################################################################

func _ready() -> void:
	_health = max_health
	add_to_group("player")
	_ensure_input_map()

func _physics_process(delta: float) -> void:
	_update_jump_timers(delta)
	_apply_horizontal_movement(delta)
	_apply_gravity(delta)
	_try_start_jump()
	_apply_variable_jump_height()
	move_and_slide()
	_refresh_floor_state()
	_update_hurt_flash(delta)

################################################################################
# INPUT AND TIMERS
################################################################################

func _update_jump_timers(delta: float) -> void:
	_jump_was_released = Input.is_action_just_released(&"jump")

	if Input.is_action_just_pressed(&"jump"):
		_jump_buffer_timer = JUMP_BUFFER_SECONDS
	else:
		_jump_buffer_timer = max(_jump_buffer_timer - delta, 0.0)

	if is_on_floor():
		_coyote_timer = COYOTE_TIME_SECONDS
	else:
		_coyote_timer = max(_coyote_timer - delta, 0.0)

################################################################################
# HORIZONTAL MOVEMENT
################################################################################

func _apply_horizontal_movement(delta: float) -> void:
	var input_axis: float = Input.get_axis(&"move_left", &"move_right")
	var max_speed: float = sprint_speed if Input.is_action_pressed(&"sprint") else move_speed
	var target_velocity_x: float = input_axis * max_speed

	if not is_zero_approx(input_axis):
		velocity.x = move_toward(velocity.x, target_velocity_x, acceleration * delta)
		return

	velocity.x = move_toward(velocity.x, 0.0, friction * delta)

################################################################################
# VERTICAL MOVEMENT
################################################################################

func _apply_gravity(delta: float) -> void:
	if is_on_floor() and velocity.y > 0.0:
		velocity.y = 0.0
		return

	velocity.y += gravity * delta

func _try_start_jump() -> void:
	if _jump_buffer_timer <= 0.0:
		return

	if _coyote_timer <= 0.0:
		return

	velocity.y = jump_velocity
	_jump_buffer_timer = 0.0
	_coyote_timer = 0.0

func _apply_variable_jump_height() -> void:
	if not _jump_was_released:
		return

	if velocity.y >= 0.0:
		return

	velocity.y *= JUMP_CUT_MULTIPLIER

func _refresh_floor_state() -> void:
	if is_on_floor():
		_coyote_timer = COYOTE_TIME_SECONDS

func _update_hurt_flash(delta: float) -> void:
	if _hurt_flash_timer <= 0.0:
		_sprite.modulate = Color(1, 1, 1, 1)
		return

	_hurt_flash_timer = max(_hurt_flash_timer - delta, 0.0)
	_sprite.modulate = Color(1.0, 0.55, 0.55, 1.0)

func apply_contact_damage(amount: int, source_position: Vector2) -> void:
	_health = max(_health - amount, 0)
	_hurt_flash_timer = 0.12

	var knockback_direction: float = sign(global_position.x - source_position.x)
	if is_zero_approx(knockback_direction):
		knockback_direction = 1.0

	velocity.x = knockback_direction * 180.0
	velocity.y = min(velocity.y, -180.0)

################################################################################
# INPUT MAP BOOTSTRAP
################################################################################

func _ensure_input_map() -> void:
	for action_name: StringName in INPUT_ACTIONS.keys():
		if not InputMap.has_action(action_name):
			InputMap.add_action(action_name)

		for keycode_variant: Variant in INPUT_ACTIONS[action_name]:
			var keycode: Key = int(keycode_variant)
			if _action_has_key(action_name, keycode):
				continue

			var input_event: InputEventKey = InputEventKey.new()
			input_event.keycode = keycode
			input_event.physical_keycode = keycode
			InputMap.action_add_event(action_name, input_event)

func _action_has_key(action_name: StringName, keycode: Key) -> bool:
	for event: InputEvent in InputMap.action_get_events(action_name):
		if event is InputEventKey:
			var key_event: InputEventKey = event
			if key_event.physical_keycode == keycode or key_event.keycode == keycode:
				return true

	return false
