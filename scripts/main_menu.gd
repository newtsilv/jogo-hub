class_name MainMenu
extends Control


@export_category("Navegação")
@export_file("*.tscn") var next_scene_path: String = (
	"res://scenes/character_select.tscn"
)


@onready var play_button: TextureButton = $PlayButton
@onready var quit_button: TextureButton = $QuitButton


func _ready() -> void:
	play_button.pressed.connect(_on_play_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

	# Jogos rodando no navegador não podem se fechar sozinhos.
	if OS.has_feature("web"):
		quit_button.hide()


func _on_play_pressed() -> void:
	get_tree().change_scene_to_file(next_scene_path)


func _on_quit_pressed() -> void:
	get_tree().quit()
