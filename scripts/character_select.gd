class_name CharacterSelect
extends Control


@export_category("Navegação")
@export_file("*.tscn") var game_scene_path: String = (
	"res://scenes/main.tscn"
)

@export_file("*.tscn") var menu_scene_path: String = (
	"res://scenes/cena1.tscn"
)


const DESIGN_SIZE: Vector2 = Vector2(1080.0, 1920.0)
const PEDRO_BUTTON_DESIGN_RECT := Rect2(85.0, 700.0, 421.0, 600.0)
const MARIA_BUTTON_DESIGN_RECT := Rect2(573.0, 700.0, 422.0, 600.0)
const BACK_BUTTON_DESIGN_RECT := Rect2(419.0, 1751.0, 254.0, 96.0)

@onready var background: TextureRect = $Background
@onready var pedro_button: Button = $PedroButton
@onready var maria_button: Button = $MariaButton
@onready var back_button: Button = $BackButton


func _ready() -> void:
	_apply_responsive_layout()
	resized.connect(_apply_responsive_layout)

	pedro_button.pressed.connect(
		_on_character_selected.bind(GameState.Character.PEDRO)
	)

	maria_button.pressed.connect(
		_on_character_selected.bind(GameState.Character.MARIA)
	)

	back_button.pressed.connect(_on_back_pressed)


func _apply_responsive_layout() -> void:
	var viewport_size: Vector2 = get_viewport_rect().size
	position = Vector2.ZERO
	size = viewport_size
	var scale_factor: float = minf(viewport_size.x / DESIGN_SIZE.x, viewport_size.y / DESIGN_SIZE.y)
	var offset: Vector2 = (viewport_size - DESIGN_SIZE * scale_factor) / 2.0

	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	background.offset_left = 0.0
	background.offset_top = 0.0
	background.offset_right = 0.0
	background.offset_bottom = 0.0
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED

	_set_button_rect(pedro_button, _scale_rect(PEDRO_BUTTON_DESIGN_RECT, scale_factor, offset))
	_set_button_rect(maria_button, _scale_rect(MARIA_BUTTON_DESIGN_RECT, scale_factor, offset))
	_set_button_rect(back_button, _scale_rect(BACK_BUTTON_DESIGN_RECT, scale_factor, offset))


func _scale_rect(rect: Rect2, scale_factor: float, offset: Vector2) -> Rect2:
	return Rect2(
		offset + rect.position * scale_factor,
		rect.size * scale_factor
	)


func _set_button_rect(button: Button, rect: Rect2) -> void:
	button.position = rect.position
	button.size = rect.size


func _on_character_selected(
	character: GameState.Character
) -> void:
	GameState.selected_character = character
	SceneTransition.change_scene(game_scene_path)


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file(menu_scene_path)
