extends CanvasLayer

signal upgrade_selected(upgrade_id: StringName)

# ============================================================================
# CONSTANTS
# ============================================================================

# ============================================================================
# NODE REFERENCES
# ============================================================================

@onready var _title_label: Label = $Overlay/PanelContainer/MarginContainer/VBoxContainer/TitleLabel
@onready var _subtitle_label: Label = $Overlay/PanelContainer/MarginContainer/VBoxContainer/SubtitleLabel
@onready var _damage_button: Button = $Overlay/PanelContainer/MarginContainer/VBoxContainer/Choices/DamageButton
@onready var _attack_speed_button: Button = $Overlay/PanelContainer/MarginContainer/VBoxContainer/Choices/AttackSpeedButton
@onready var _move_speed_button: Button = $Overlay/PanelContainer/MarginContainer/VBoxContainer/Choices/MoveSpeedButton

var _choice_buttons: Array[Button] = []
var _choice_options: Array = []
var _build_identity: StringName = &"balanced"
var _build_archetype: String = "Balanced"
var _meta_discovery_points: int = 0
var _mastery_goal_count: int = 0

# ============================================================================
# GODOT LIFECYCLE
# ============================================================================

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	layer = 20
	_choice_buttons = [_damage_button, _attack_speed_button, _move_speed_button]
	for button: Button in _choice_buttons:
		_connect_button(button)

# ============================================================================
# UI
# ============================================================================

func setup_selection(level: int, upgrade_options: Array = [], build_identity: StringName = &"balanced", build_archetype: String = "Balanced", meta_discovery_points: int = 0, mastery_goal_count: int = 0) -> void:
	_title_label.text = "LEVEL UP"
	_build_identity = build_identity
	_build_archetype = build_archetype
	_meta_discovery_points = meta_discovery_points
	_mastery_goal_count = mastery_goal_count
	var subtitle_text: String = "Level %d - Choose one upgrade" % level
	if _build_identity != &"balanced":
		subtitle_text += "  [%s" % String(_build_identity).capitalize()
		if _build_archetype != "Balanced":
			subtitle_text += " / %s" % _build_archetype
		subtitle_text += "]"
	elif _build_archetype != "Balanced":
		subtitle_text += "  [%s]" % _build_archetype

	if _meta_discovery_points > 0:
		subtitle_text += "  [Discovery %d" % _meta_discovery_points
		if _meta_discovery_points != 1:
			subtitle_text += "s"
		if _mastery_goal_count > 0:
			subtitle_text += " / Mastery %d" % _mastery_goal_count
		subtitle_text += "]"
	elif _mastery_goal_count > 0:
		subtitle_text += "  [Mastery %d]" % _mastery_goal_count

	_subtitle_label.text = subtitle_text
	if upgrade_options.is_empty():
		upgrade_options = [
			{"id": &"damage_up", "title": "Damage Up", "description": "Projectiles hit harder."},
			{"id": &"attack_speed_up", "title": "Attack Speed Up", "description": "Fire more often."},
			{"id": &"move_speed_up", "title": "Move Speed Up", "description": "Run and sprint faster."}
		]

	_choice_options = upgrade_options

	for button_index: int in range(_choice_buttons.size()):
		var button: Button = _choice_buttons[button_index]
		if button_index >= _choice_options.size():
			button.visible = false
			button.disabled = true
			continue

		var option: Dictionary = _choice_options[button_index]
		button.visible = true
		button.disabled = false
		var button_title: String = String(option["title"])
		if String(option.get("rarity", "common")) == "rare":
			button_title = "[RARE] %s" % button_title
		button.text = "%s\n%s" % [button_title, option["description"]]
		button.set_meta("upgrade_id", option["id"])

func _connect_button(button: Button) -> void:
	button.pressed.connect(_on_upgrade_button_pressed.bind(button))

func _on_upgrade_button_pressed(button: Button) -> void:
	if not button.has_meta("upgrade_id"):
		return

	var upgrade_id: StringName = button.get_meta("upgrade_id")
	upgrade_selected.emit(upgrade_id)

# ============================================================================
# DEBUG
# ============================================================================
