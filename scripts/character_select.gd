class_name CharacterSelect
extends Control


@export_category("Navegação")
@export_file("*.tscn") var game_scene_path: String = (
	"res://scenes/main.tscn"
)

@export_file("*.tscn") var menu_scene_path: String = (
	"res://scenes/cena7.tscn"
)


@onready var pedro_button: Button = $PedroButton
@onready var maria_button: Button = $MariaButton
@onready var back_button: Button = $BackButton


func _ready() -> void:
	pedro_button.pressed.connect(
		_on_character_selected.bind(GameState.Character.PEDRO)
	)

	maria_button.pressed.connect(
		_on_character_selected.bind(GameState.Character.MARIA)
	)

	back_button.pressed.connect(_on_back_pressed)


func _on_character_selected(
	character: GameState.Character
) -> void:
	GameState.selected_character = character
	SceneTransition.change_scene(game_scene_path)


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file(menu_scene_path)
