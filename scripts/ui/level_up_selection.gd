extends CanvasLayer

signal upgrade_selected(upgrade_id: StringName)

# ============================================================================
# CONSTANTS
# ============================================================================

const DAMAGE_UPGRADE_ID: StringName = &"damage_up"
const ATTACK_SPEED_UPGRADE_ID: StringName = &"attack_speed_up"
const MOVE_SPEED_UPGRADE_ID: StringName = &"move_speed_up"

# ============================================================================
# NODE REFERENCES
# ============================================================================

@onready var _title_label: Label = $Overlay/PanelContainer/MarginContainer/VBoxContainer/TitleLabel
@onready var _subtitle_label: Label = $Overlay/PanelContainer/MarginContainer/VBoxContainer/SubtitleLabel
@onready var _damage_button: Button = $Overlay/PanelContainer/MarginContainer/VBoxContainer/Choices/DamageButton
@onready var _attack_speed_button: Button = $Overlay/PanelContainer/MarginContainer/VBoxContainer/Choices/AttackSpeedButton
@onready var _move_speed_button: Button = $Overlay/PanelContainer/MarginContainer/VBoxContainer/Choices/MoveSpeedButton

# ============================================================================
# GODOT LIFECYCLE
# ============================================================================

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	layer = 20
	_connect_button(_damage_button, DAMAGE_UPGRADE_ID)
	_connect_button(_attack_speed_button, ATTACK_SPEED_UPGRADE_ID)
	_connect_button(_move_speed_button, MOVE_SPEED_UPGRADE_ID)

# ============================================================================
# UI
# ============================================================================

func setup_selection(level: int) -> void:
	_title_label.text = "LEVEL UP"
	_subtitle_label.text = "Level %d - Choose one upgrade" % level
	_damage_button.text = "Damage Up\nIncrease projectile damage."
	_attack_speed_button.text = "Attack Speed Up\nFire more often."
	_move_speed_button.text = "Move Speed Up\nRun and sprint faster."

func _connect_button(button: Button, upgrade_id: StringName) -> void:
	button.pressed.connect(_on_upgrade_button_pressed.bind(upgrade_id))

func _on_upgrade_button_pressed(upgrade_id: StringName) -> void:
	upgrade_selected.emit(upgrade_id)

# ============================================================================
# DEBUG
# ============================================================================
