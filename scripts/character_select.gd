class_name CharacterSelect
extends Control


@export_category("Navegação")
@export_file("*.tscn") var game_scene_path: String = (
	"res://scenes/main.tscn"
)

@export_file("*.tscn") var menu_scene_path: String = (
	"res://scenes/main_menu.tscn"
)


@onready var gabriel_button: TextureButton = $GabrielButton
@onready var laura_button: TextureButton = $LauraButton
@onready var back_button: TextureButton = $BackButton


func _ready() -> void:
	gabriel_button.pressed.connect(
		_on_character_selected.bind(GameState.Character.GABRIEL)
	)

	laura_button.pressed.connect(
		_on_character_selected.bind(GameState.Character.LAURA)
	)

	back_button.pressed.connect(_on_back_pressed)


func _on_character_selected(
	character: GameState.Character
) -> void:
	GameState.selected_character = character
	get_tree().change_scene_to_file(game_scene_path)


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file(menu_scene_path)
